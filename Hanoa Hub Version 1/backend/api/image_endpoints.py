"""
이미지 분석 파이프라인 API 엔드포인트
FastAPI endpoints for image upload, analysis, and problem generation
"""

from typing import List, Dict, Any, Optional
from datetime import datetime
import uuid
import base64
import io
import os
import json
import hashlib

from fastapi import APIRouter, HTTPException, File, UploadFile, Form, BackgroundTasks
from pydantic import BaseModel
from PIL import Image
import numpy as np

from analyzers.image_hierarchical_analyzer import ImageHierarchicalAnalyzer, ImageAnalysisResult
from templates.problem_generator import ProblemGenerator
from rag_engine_multi_domain import multi_domain_rag_engine
from filters.sensitive_filter import SensitiveContentFilter
from calibration.confidence_calibrator import ConfidenceCalibrator
from monitoring.api_cost_tracker import APICostTracker


# Pydantic Models
class ImageUploadResponse(BaseModel):
    """이미지 업로드 응답"""
    image_id: str
    filename: str
    size: int
    format: str
    dimensions: tuple
    upload_time: str
    storage_path: str
    message: str


class ImageAnalysisRequest(BaseModel):
    """이미지 분석 요청"""
    image_id: Optional[str] = None
    image_base64: Optional[str] = None
    domain: str = "medical"
    analyze_depth: str = "standard"  # standard, detailed, full
    generate_problems: bool = False
    problem_count: Optional[int] = 3


class ImageAnalysisResponse(BaseModel):
    """이미지 분석 응답"""
    image_id: str
    analysis_result: Dict[str, Any]
    filtered_content: Optional[Dict[str, Any]] = None
    problems_generated: Optional[List[Dict[str, Any]]] = None
    model_used: str
    confidence_score: float
    escalation_reason: Optional[str] = None
    processing_time: float
    estimated_cost: float


class ProblemGenerationRequest(BaseModel):
    """문제 생성 요청"""
    image_analysis: Dict[str, Any]
    problem_type: str = "multiple_choice"  # multiple_choice, true_false, short_answer
    difficulty: str = "medium"  # easy, medium, hard
    count: int = 3
    language: str = "ko"


class ProblemGenerationResponse(BaseModel):
    """문제 생성 응답"""
    problems: List[Dict[str, Any]]
    image_id: str
    generation_time: float
    model_used: str
    template_used: str


# Create router
router = APIRouter(prefix="/api/v1", tags=["Image Analysis Pipeline"])

# Initialize services
image_analyzer = ImageHierarchicalAnalyzer()
problem_generator = ProblemGenerator()
sensitive_filter = SensitiveContentFilter()
confidence_calibrator = ConfidenceCalibrator()
cost_tracker = APICostTracker()


@router.post("/images/upload", response_model=ImageUploadResponse)
async def upload_image(
    file: UploadFile = File(...),
    domain: str = Form("medical"),
    background_tasks: BackgroundTasks = None
):
    """
    이미지 업로드 엔드포인트
    - 이미지 파일을 업로드하고 저장
    - 기본 메타데이터 추출
    - ChromaDB에 인덱싱 준비
    """
    try:
        # 파일 크기 검증 (최대 10MB)
        contents = await file.read()
        file_size = len(contents)

        if file_size > 10 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="파일 크기가 10MB를 초과합니다")

        # 이미지 검증
        try:
            image = Image.open(io.BytesIO(contents))
            image_format = image.format
            width, height = image.size
        except Exception as e:
            raise HTTPException(status_code=400, detail="유효한 이미지 파일이 아닙니다")

        # 이미지 ID 생성 (해시 기반)
        image_hash = hashlib.sha256(contents).hexdigest()[:16]
        image_id = f"img_{image_hash}_{uuid.uuid4().hex[:8]}"

        # 저장 경로 설정
        storage_dir = "storage/images"
        os.makedirs(storage_dir, exist_ok=True)

        # 파일 저장
        file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
        storage_path = os.path.join(storage_dir, f"{image_id}.{file_extension}")

        with open(storage_path, 'wb') as f:
            f.write(contents)

        # 메타데이터 저장
        metadata = {
            'image_id': image_id,
            'filename': file.filename,
            'size': file_size,
            'format': image_format,
            'dimensions': (width, height),
            'domain': domain,
            'upload_time': datetime.now().isoformat(),
            'storage_path': storage_path
        }

        # ChromaDB에 메타데이터 저장 (백그라운드)
        if background_tasks:
            background_tasks.add_task(
                store_image_metadata,
                image_id,
                metadata
            )

        return ImageUploadResponse(
            image_id=image_id,
            filename=file.filename,
            size=file_size,
            format=image_format,
            dimensions=(width, height),
            upload_time=metadata['upload_time'],
            storage_path=storage_path,
            message="이미지가 성공적으로 업로드되었습니다"
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"이미지 업로드 실패: {str(e)}")


@router.post("/images/analyze", response_model=ImageAnalysisResponse)
async def analyze_image(
    request: ImageAnalysisRequest,
    background_tasks: BackgroundTasks = None
):
    """
    이미지 분석 엔드포인트
    - 계층적 모델 에스컬레이션 (Gemini Flash → GPT-5 mini → GPT-5)
    - 민감 정보 필터링
    - 신뢰도 보정
    - 문제 생성 (선택적)
    """
    import time
    start_time = time.time()

    try:
        # 이미지 로드
        if request.image_id:
            # 저장된 이미지 로드
            storage_path = f"storage/images/{request.image_id}.*"
            import glob
            files = glob.glob(storage_path)
            if not files:
                raise HTTPException(status_code=404, detail="이미지를 찾을 수 없습니다")

            with open(files[0], 'rb') as f:
                image_data = f.read()

        elif request.image_base64:
            # Base64 인코딩된 이미지 디코딩
            try:
                image_data = base64.b64decode(request.image_base64)
            except Exception:
                raise HTTPException(status_code=400, detail="유효하지 않은 Base64 이미지 데이터")
        else:
            raise HTTPException(status_code=400, detail="image_id 또는 image_base64가 필요합니다")

        # PIL Image로 변환
        image = Image.open(io.BytesIO(image_data))

        # 민감 정보 필터링
        filtered_result = sensitive_filter.check_image(image)
        if filtered_result['contains_sensitive']:
            # 민감 정보가 포함된 경우 처리
            if filtered_result['severity'] == 'high':
                raise HTTPException(
                    status_code=400,
                    detail=f"민감 정보 감지됨: {filtered_result['types']}"
                )

        # 계층적 분석 수행
        analysis_result = image_analyzer.analyze_with_escalation(
            image=image,
            domain=request.domain,
            analyze_depth=request.analyze_depth
        )

        # 신뢰도 보정
        calibrated_confidence = confidence_calibrator.calibrate(
            raw_confidence=analysis_result.confidence_score,
            model=analysis_result.analyzed_by,
            domain=request.domain
        )
        analysis_result.confidence_score = calibrated_confidence

        # API 비용 추적
        estimated_cost = cost_tracker.estimate_cost(
            model=analysis_result.analyzed_by,
            tokens_used=1000  # 예상 토큰 수
        )

        # 문제 생성 (요청된 경우)
        problems_generated = None
        if request.generate_problems:
            problem_request = ProblemGenerationRequest(
                image_analysis=analysis_result.__dict__,
                problem_type="multiple_choice",
                difficulty="medium",
                count=request.problem_count or 3,
                language="ko"
            )

            problems = await generate_problems_from_analysis(problem_request)
            problems_generated = problems['problems']

        # ChromaDB에 분석 결과 저장 (백그라운드)
        if background_tasks:
            background_tasks.add_task(
                store_analysis_result,
                analysis_result,
                request.domain
            )

        processing_time = time.time() - start_time

        return ImageAnalysisResponse(
            image_id=request.image_id or f"temp_{uuid.uuid4().hex[:8]}",
            analysis_result=analysis_result.__dict__,
            filtered_content=filtered_result if filtered_result['contains_sensitive'] else None,
            problems_generated=problems_generated,
            model_used=analysis_result.analyzed_by,
            confidence_score=analysis_result.confidence_score,
            escalation_reason=analysis_result.escalation_reason,
            processing_time=processing_time,
            estimated_cost=estimated_cost
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"이미지 분석 실패: {str(e)}")


@router.post("/problems/generate", response_model=ProblemGenerationResponse)
async def generate_problems(request: ProblemGenerationRequest):
    """
    문제 생성 엔드포인트
    - 이미지 분석 결과를 기반으로 문제 생성
    - YAML 템플릿 사용
    - 다양한 문제 유형 지원
    """
    import time
    start_time = time.time()

    try:
        # 문제 생성
        problems = problem_generator.generate_from_analysis(
            analysis_data=request.image_analysis,
            problem_type=request.problem_type,
            difficulty=request.difficulty,
            count=request.count,
            language=request.language
        )

        # 각 문제에 메타데이터 추가
        for i, problem in enumerate(problems):
            problem['id'] = f"prob_{uuid.uuid4().hex[:12]}"
            problem['created_at'] = datetime.now().isoformat()
            problem['source_type'] = 'image_analysis'
            problem['difficulty'] = request.difficulty
            problem['problem_number'] = i + 1

        generation_time = time.time() - start_time

        return ProblemGenerationResponse(
            problems=problems,
            image_id=request.image_analysis.get('image_id', 'unknown'),
            generation_time=generation_time,
            model_used="GPT-5-mini",
            template_used=f"{request.problem_type}_{request.difficulty}"
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"문제 생성 실패: {str(e)}")


async def generate_problems_from_analysis(request: ProblemGenerationRequest) -> Dict[str, Any]:
    """분석 결과로부터 문제 생성 (내부 함수)"""
    try:
        problems = problem_generator.generate_from_analysis(
            analysis_data=request.image_analysis,
            problem_type=request.problem_type,
            difficulty=request.difficulty,
            count=request.count,
            language=request.language
        )

        return {'problems': problems}
    except Exception as e:
        print(f"[ERROR] 문제 생성 실패: {e}")
        return {'problems': []}


async def store_image_metadata(image_id: str, metadata: Dict[str, Any]):
    """이미지 메타데이터를 ChromaDB에 저장"""
    try:
        # 이미지 컬렉션 가져오기/생성
        collection = multi_domain_rag_engine.get_or_create_collection('images')

        # 메타데이터 문서 생성
        document = f"""
        Image ID: {image_id}
        Filename: {metadata['filename']}
        Size: {metadata['size']} bytes
        Format: {metadata['format']}
        Dimensions: {metadata['dimensions']}
        Domain: {metadata['domain']}
        Upload Time: {metadata['upload_time']}
        """

        # ChromaDB에 저장
        collection.add(
            documents=[document],
            metadatas=[metadata],
            ids=[image_id]
        )

        print(f"[SUCCESS] 이미지 메타데이터 저장 완료: {image_id}")

    except Exception as e:
        print(f"[ERROR] 이미지 메타데이터 저장 실패: {e}")


async def store_analysis_result(analysis_result: ImageAnalysisResult, domain: str):
    """분석 결과를 ChromaDB에 저장"""
    try:
        # 도메인별 컬렉션 선택
        collection_name = f"{domain}_image_analysis"
        collection = multi_domain_rag_engine.get_or_create_collection(collection_name)

        # 분석 결과 문서 생성
        document = f"""
        Image Analysis Result
        Domain: {analysis_result.domain}
        Main Objects: {', '.join(analysis_result.main_objects)}
        Medical Tags: {', '.join(analysis_result.medical_tags)}
        Descriptive Tags: {', '.join(analysis_result.descriptive_tags)}
        Description: {analysis_result.description}
        Confidence: {analysis_result.confidence_score}
        Model Used: {analysis_result.analyzed_by}
        """

        # ChromaDB에 저장
        collection.add(
            documents=[document],
            metadatas=[analysis_result.__dict__],
            ids=[analysis_result.image_id]
        )

        print(f"[SUCCESS] 분석 결과 저장 완료: {analysis_result.image_id}")

    except Exception as e:
        print(f"[ERROR] 분석 결과 저장 실패: {e}")


# Export router
__all__ = ['router']