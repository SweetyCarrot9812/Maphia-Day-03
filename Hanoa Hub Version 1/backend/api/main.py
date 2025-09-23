"""
이미지 분석 파이프라인 FastAPI 애플리케이션
Image Analysis Pipeline FastAPI Application

계층적 이미지 분석, 민감 정보 필터링, 보정 시스템이 통합된 REST API
"""

import asyncio
import logging
import time
from contextlib import asynccontextmanager
from typing import Dict, List, Optional

import uvicorn
from fastapi import FastAPI, HTTPException, BackgroundTasks, Depends, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, StreamingResponse
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

# 로컬 모듈들
from models.schemas import (
    ImageAnalysisRequest, ImageAnalysisResult, BatchAnalysisRequest,
    JobResponse, BatchJobResponse, JobStatus, JobPriority, DomainType,
    PipelineConfig, ProcessingMetrics, SystemHealth
)
from analyzers.enhanced_image_analyzer import EnhancedImageAnalyzer
from queue.task_manager import TaskQueue, get_task_queue
from monitoring.metrics import MetricsCollector


# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class MetricsMiddleware(BaseHTTPMiddleware):
    """메트릭 수집 미들웨어"""

    def __init__(self, app, metrics_collector):
        super().__init__(app)
        self.metrics_collector = metrics_collector

    async def dispatch(self, request: Request, call_next):
        start_time = time.time()

        # 요청 카운터 증가
        self.metrics_collector.increment_request_counter(
            method=request.method,
            endpoint=request.url.path
        )

        try:
            response = await call_next(request)

            # 응답 시간 기록
            processing_time = time.time() - start_time
            self.metrics_collector.record_response_time(
                endpoint=request.url.path,
                duration=processing_time
            )

            # 상태 코드별 카운터
            self.metrics_collector.increment_response_counter(
                status_code=response.status_code
            )

            return response

        except Exception as e:
            # 오류 카운터 증가
            self.metrics_collector.increment_error_counter(
                endpoint=request.url.path,
                error_type=type(e).__name__
            )
            raise


# 전역 변수들
task_queue: Optional[TaskQueue] = None
image_analyzer: Optional[EnhancedImageAnalyzer] = None
metrics_collector: Optional[MetricsCollector] = None
pipeline_config: PipelineConfig = PipelineConfig()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """애플리케이션 라이프사이클 관리"""
    # 시작 시 초기화
    global task_queue, image_analyzer, metrics_collector

    logger.info("이미지 분석 파이프라인 시작...")

    try:
        # 메트릭 수집기 초기화
        metrics_collector = MetricsCollector()

        # 이미지 분석기 초기화
        analyzer_config = {
            'filter_config': {
                'enable_face_detection': pipeline_config.enable_face_detection,
                'enable_nsfw_detection': pipeline_config.enable_nsfw_detection,
                'enable_ocr_pii': pipeline_config.enable_ocr_pii
            },
            'embedding_model': 'ViT-B/32',
            'calibration_dir': './calibration/data',
            'enable_auto_update': True
        }
        image_analyzer = EnhancedImageAnalyzer(analyzer_config)

        # 태스크 큐 초기화
        task_queue = get_task_queue()

        # 태스크 처리기 설정
        async def process_analysis_task(request: ImageAnalysisRequest, progress_callback):
            """분석 태스크 처리기"""
            try:
                # 진행률 업데이트
                await progress_callback(0.1)

                # 이미지 분석 실행
                result = await image_analyzer.analyze_image(
                    image_input=request.image_data or request.image_url,
                    domain=request.domain,
                    enable_sensitive_filter=request.enable_sensitive_filter,
                    generate_embeddings=True,
                    max_analysis_level=request.max_analysis_level
                )

                await progress_callback(1.0)
                return result

            except Exception as e:
                logger.error(f"분석 태스크 처리 실패: {e}")
                raise

        task_queue.set_task_processor(process_analysis_task)

        # 워커 시작
        await task_queue.start_workers()

        logger.info("이미지 분석 파이프라인이 성공적으로 시작되었습니다.")

        yield

    except Exception as e:
        logger.error(f"초기화 실패: {e}")
        raise

    finally:
        # 종료 시 정리
        logger.info("이미지 분석 파이프라인 종료 중...")

        if task_queue:
            await task_queue.stop_workers()

        logger.info("이미지 분석 파이프라인이 종료되었습니다.")


# FastAPI 앱 생성
app = FastAPI(
    title="이미지 분석 파이프라인 API",
    description="계층적 이미지 분석, 민감 정보 필터링, 보정 시스템이 통합된 REST API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 도메인으로 제한
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 메트릭 미들웨어 추가 (나중에 metrics_collector가 초기화된 후)
@app.middleware("http")
async def add_metrics_middleware(request: Request, call_next):
    if metrics_collector:
        middleware = MetricsMiddleware(app, metrics_collector)
        return await middleware.dispatch(request, call_next)
    else:
        return await call_next(request)


# === 의존성 함수들 ===

def get_image_analyzer() -> EnhancedImageAnalyzer:
    """이미지 분석기 의존성"""
    if image_analyzer is None:
        raise HTTPException(status_code=500, detail="이미지 분석기가 초기화되지 않았습니다.")
    return image_analyzer


def get_task_queue_dep() -> TaskQueue:
    """태스크 큐 의존성"""
    if task_queue is None:
        raise HTTPException(status_code=500, detail="태스크 큐가 초기화되지 않았습니다.")
    return task_queue


def get_metrics_collector() -> MetricsCollector:
    """메트릭 수집기 의존성"""
    if metrics_collector is None:
        raise HTTPException(status_code=500, detail="메트릭 수집기가 초기화되지 않았습니다.")
    return metrics_collector


# === API 엔드포인트들 ===

@app.get("/", tags=["기본"])
async def root():
    """루트 엔드포인트"""
    return {
        "message": "이미지 분석 파이프라인 API",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/health", tags=["기본"], response_model=SystemHealth)
async def health_check():
    """헬스 체크"""
    try:
        # 시스템 상태 확인
        system_health = SystemHealth()

        # 태스크 큐 상태 확인
        if task_queue:
            queue_stats = task_queue.get_queue_stats()
            system_health.queue_status = "healthy" if queue_stats['running'] else "down"
            system_health.pending_jobs = queue_stats.get('total_pending', 0)
            system_health.processing_jobs = queue_stats.get('processing', 0)
        else:
            system_health.queue_status = "down"

        # 전체 상태 결정
        if (system_health.api_status == "healthy" and
            system_health.queue_status == "healthy" and
            system_health.database_status == "healthy"):
            overall_status = "healthy"
        else:
            overall_status = "degraded"

        # HTTP 상태 코드 설정
        status_code = 200 if overall_status == "healthy" else 503

        return JSONResponse(
            content=system_health.dict(),
            status_code=status_code
        )

    except Exception as e:
        logger.error(f"헬스 체크 실패: {e}")
        return JSONResponse(
            content={"status": "error", "message": str(e)},
            status_code=500
        )


@app.post("/analyze", tags=["이미지 분석"], response_model=str)
async def analyze_image(
    request: ImageAnalysisRequest,
    priority: JobPriority = JobPriority.NORMAL,
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """
    이미지 분석 작업 제출

    비동기로 이미지를 분석하고 작업 ID를 반환합니다.
    """
    try:
        job_id = await queue.submit_job(request, priority)
        logger.info(f"분석 작업 제출: {job_id}")
        return job_id

    except Exception as e:
        logger.error(f"분석 작업 제출 실패: {e}")
        raise HTTPException(status_code=500, detail=f"작업 제출 실패: {str(e)}")


@app.post("/analyze/sync", tags=["이미지 분석"], response_model=ImageAnalysisResult)
async def analyze_image_sync(
    request: ImageAnalysisRequest,
    analyzer: EnhancedImageAnalyzer = Depends(get_image_analyzer)
):
    """
    동기식 이미지 분석

    즉시 분석 결과를 반환합니다 (소규모 이미지 전용).
    """
    try:
        result = await analyzer.analyze_image(
            image_input=request.image_data or request.image_url,
            domain=request.domain,
            enable_sensitive_filter=request.enable_sensitive_filter,
            generate_embeddings=True,
            max_analysis_level=request.max_analysis_level
        )

        logger.info(f"동기 분석 완료: {result.image_id}")
        return result

    except Exception as e:
        logger.error(f"동기 분석 실패: {e}")
        raise HTTPException(status_code=500, detail=f"분석 실패: {str(e)}")


@app.post("/analyze/upload", tags=["이미지 분석"], response_model=str)
async def analyze_uploaded_image(
    file: UploadFile = File(...),
    domain: DomainType = Form(DomainType.MEDICAL),
    priority: JobPriority = Form(JobPriority.NORMAL),
    enable_sensitive_filter: bool = Form(True),
    generate_problems: bool = Form(True),
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """
    업로드된 이미지 분석

    파일 업로드를 통한 이미지 분석 작업 제출.
    """
    try:
        # 파일 검증
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="이미지 파일만 업로드 가능합니다.")

        # 파일 크기 검증 (설정에서 가져옴)
        max_size = pipeline_config.max_image_size_mb * 1024 * 1024
        file_size = len(await file.read())
        await file.seek(0)  # 파일 포인터 리셋

        if file_size > max_size:
            raise HTTPException(
                status_code=413,
                detail=f"파일 크기가 너무 큽니다. 최대 {pipeline_config.max_image_size_mb}MB까지 지원됩니다."
            )

        # 파일을 base64로 변환
        import base64
        file_bytes = await file.read()
        file_base64 = base64.b64encode(file_bytes).decode('utf-8')

        # 분석 요청 생성
        request = ImageAnalysisRequest(
            image_data=file_base64,
            domain=domain,
            enable_sensitive_filter=enable_sensitive_filter,
            generate_problems=generate_problems
        )

        job_id = await queue.submit_job(request, priority)
        logger.info(f"업로드 파일 분석 작업 제출: {job_id}")
        return job_id

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"업로드 파일 분석 실패: {e}")
        raise HTTPException(status_code=500, detail=f"업로드 분석 실패: {str(e)}")


@app.post("/analyze/batch", tags=["이미지 분석"], response_model=str)
async def analyze_batch(
    request: BatchAnalysisRequest,
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """
    일괄 이미지 분석

    여러 이미지를 한 번에 분석합니다.
    """
    try:
        batch_id = await queue.submit_batch_job(request.images, request.batch_name)
        logger.info(f"일괄 분석 작업 제출: {batch_id}, {len(request.images)}개 이미지")
        return batch_id

    except Exception as e:
        logger.error(f"일괄 분석 실패: {e}")
        raise HTTPException(status_code=500, detail=f"일괄 분석 실패: {str(e)}")


@app.get("/jobs/{job_id}", tags=["작업 관리"], response_model=JobResponse)
async def get_job_status(
    job_id: str,
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """작업 상태 조회"""
    try:
        job_status = await queue.get_job_status(job_id)

        if job_status is None:
            raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다.")

        return job_status

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"작업 상태 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"상태 조회 실패: {str(e)}")


@app.get("/jobs/{job_id}/result", tags=["작업 관리"], response_model=ImageAnalysisResult)
async def get_job_result(
    job_id: str,
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """작업 결과 조회 (완료된 작업만)"""
    try:
        job_status = await queue.get_job_status(job_id)

        if job_status is None:
            raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다.")

        if job_status.status != JobStatus.COMPLETED:
            raise HTTPException(
                status_code=400,
                detail=f"작업이 완료되지 않았습니다. 현재 상태: {job_status.status}"
            )

        if job_status.result is None:
            raise HTTPException(status_code=500, detail="결과 데이터가 없습니다.")

        return job_status.result

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"작업 결과 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"결과 조회 실패: {str(e)}")


@app.delete("/jobs/{job_id}", tags=["작업 관리"])
async def cancel_job(
    job_id: str,
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """작업 취소"""
    try:
        success = await queue.cancel_job(job_id)

        if not success:
            raise HTTPException(status_code=404, detail="작업을 찾을 수 없거나 취소할 수 없습니다.")

        logger.info(f"작업 취소: {job_id}")
        return {"message": "작업이 취소되었습니다.", "job_id": job_id}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"작업 취소 실패: {e}")
        raise HTTPException(status_code=500, detail=f"작업 취소 실패: {str(e)}")


@app.get("/batch/{batch_id}", tags=["작업 관리"], response_model=BatchJobResponse)
async def get_batch_status(
    batch_id: str,
    queue: TaskQueue = Depends(get_task_queue_dep)
):
    """배치 작업 상태 조회"""
    try:
        batch_status = await queue.get_batch_status(batch_id)

        if batch_status is None:
            raise HTTPException(status_code=404, detail="배치 작업을 찾을 수 없습니다.")

        return batch_status

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"배치 상태 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"배치 상태 조회 실패: {str(e)}")


@app.get("/queue/stats", tags=["모니터링"])
async def get_queue_stats(queue: TaskQueue = Depends(get_task_queue_dep)):
    """큐 통계 조회"""
    try:
        stats = queue.get_queue_stats()
        return stats

    except Exception as e:
        logger.error(f"큐 통계 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"통계 조회 실패: {str(e)}")


@app.get("/metrics", tags=["모니터링"], response_model=ProcessingMetrics)
async def get_metrics(collector: MetricsCollector = Depends(get_metrics_collector)):
    """시스템 메트릭 조회"""
    try:
        metrics = collector.get_current_metrics()
        return metrics

    except Exception as e:
        logger.error(f"메트릭 조회 실패: {e}")
        raise HTTPException(status_code=500, detail=f"메트릭 조회 실패: {str(e)}")


@app.get("/config", tags=["설정"], response_model=PipelineConfig)
async def get_config():
    """현재 파이프라인 설정 조회"""
    return pipeline_config


@app.put("/config", tags=["설정"], response_model=PipelineConfig)
async def update_config(new_config: PipelineConfig):
    """파이프라인 설정 업데이트"""
    try:
        global pipeline_config

        # 기본 검증
        if new_config.confidence_threshold_mini > new_config.confidence_threshold_advanced:
            raise HTTPException(
                status_code=400,
                detail="Mini 임계값이 Advanced 임계값보다 클 수 없습니다."
            )

        # 설정 업데이트
        new_config.updated_at = datetime.now()
        pipeline_config = new_config

        logger.info("파이프라인 설정이 업데이트되었습니다.")
        return pipeline_config

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"설정 업데이트 실패: {e}")
        raise HTTPException(status_code=500, detail=f"설정 업데이트 실패: {str(e)}")


# === WebSocket 엔드포인트 (실시간 상태 업데이트) ===

@app.websocket("/ws/jobs/{job_id}")
async def websocket_job_status(websocket, job_id: str):
    """작업 상태 실시간 업데이트 WebSocket"""
    await websocket.accept()

    try:
        while True:
            # 작업 상태 조회
            if task_queue:
                job_status = await task_queue.get_job_status(job_id)
                if job_status:
                    await websocket.send_json(job_status.dict())

                    # 완료/실패 시 연결 종료
                    if job_status.status in [JobStatus.COMPLETED, JobStatus.FAILED, JobStatus.CANCELLED]:
                        break
                else:
                    await websocket.send_json({"error": "작업을 찾을 수 없습니다."})
                    break

            await asyncio.sleep(1)  # 1초마다 업데이트

    except Exception as e:
        logger.error(f"WebSocket 오류: {e}")
    finally:
        await websocket.close()


# === 에러 핸들러 ===

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """전역 예외 처리기"""
    logger.error(f"예상치 못한 오류: {exc}", exc_info=True)

    # 메트릭 업데이트
    if metrics_collector:
        metrics_collector.increment_error_counter(
            endpoint=request.url.path,
            error_type=type(exc).__name__
        )

    return JSONResponse(
        status_code=500,
        content={"detail": "내부 서버 오류가 발생했습니다."}
    )


# === 개발용 실행 코드 ===

if __name__ == "__main__":
    uvicorn.run(
        "api.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )