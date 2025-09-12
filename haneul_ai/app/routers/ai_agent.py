"""
Haneul AI Agent - AI Agent Router
API endpoints for AI-powered task analysis and priority scoring
"""

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List
import json

from app.database import get_db, TaskModel, calculate_priority_score, format_tags_for_db
from app.models.schemas import (
    Task, TaskCreate, PriorityAnalysis, TagSuggestion, 
    APIResponse, TaskListResponse
)
from app.services.ai_service import AIService
from app.services.obsidian_service import ObsidianService
from app.services.persona_manager import persona_manager, PersonaType
from loguru import logger

router = APIRouter()


@router.post("/analyze", response_model=PriorityAnalysis)
async def analyze_priority(
    content: str,
    context: str = "",
    ai_service: AIService = Depends(AIService)
):
    """
    AI를 사용하여 작업의 우선순위를 분석합니다.
    
    - **content**: 분석할 작업 내용
    - **context**: 추가 컨텍스트 (선택사항)
    """
    try:
        analysis = await ai_service.analyze_priority(content, context)
        return analysis
    except Exception as e:
        logger.error(f"Priority analysis failed: {e}")
        raise HTTPException(status_code=500, detail="우선순위 분석 중 오류가 발생했습니다")


@router.post("/suggest-tags", response_model=TagSuggestion)
async def suggest_tags(
    content: str,
    ai_service: AIService = Depends(AIService)
):
    """
    AI를 사용하여 내용에 적절한 태그를 제안합니다.
    
    - **content**: 태그를 제안할 내용
    """
    try:
        suggestion = await ai_service.suggest_tags(content)
        return suggestion
    except Exception as e:
        logger.error(f"Tag suggestion failed: {e}")
        raise HTTPException(status_code=500, detail="태그 제안 중 오류가 발생했습니다")


@router.post("/tasks", response_model=Task)
async def create_task_with_ai(
    task_data: TaskCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    ai_service: AIService = Depends(AIService),
    obsidian_service: ObsidianService = Depends(ObsidianService)
):
    """
    AI 분석을 포함하여 새 작업을 생성합니다.
    
    - **task_data**: 작업 데이터
    - AI가 자동으로 우선순위를 분석하고 태그를 제안합니다
    """
    try:
        # AI 우선순위 분석
        if task_data.urgency == 0 or task_data.importance == 0:
            analysis = await ai_service.analyze_priority(task_data.content)
            urgency = analysis.urgency
            importance = analysis.importance
            ai_reasoning = analysis.reasoning
            suggested_tags = analysis.suggested_tags
        else:
            urgency = task_data.urgency
            importance = task_data.importance
            ai_reasoning = None
            suggested_tags = []
        
        # 태그 병합 (사용자 입력 + AI 제안)
        all_tags = list(set(task_data.tags + suggested_tags))
        
        # 우선순위 점수 계산
        priority_score = calculate_priority_score(urgency, importance)
        
        # 데이터베이스에 저장
        db_task = TaskModel(
            title=task_data.title,
            content=task_data.content,
            urgency=urgency,
            importance=importance,
            priority_score=priority_score,
            tags=format_tags_for_db(all_tags),
            estimated_time=task_data.estimated_time,
            obsidian_file_path=task_data.obsidian_file_path,
            ai_reasoning=ai_reasoning
        )
        
        db.add(db_task)
        db.commit()
        db.refresh(db_task)
        
        # 백그라운드에서 Obsidian 파일 생성
        background_tasks.add_task(
            obsidian_service.create_note_from_task,
            db_task
        )
        
        # 응답 데이터 구성
        task = Task(
            id=db_task.id,
            title=db_task.title,
            content=db_task.content,
            urgency=db_task.urgency,
            importance=db_task.importance,
            priority_score=db_task.priority_score,
            status=db_task.status,
            tags=json.loads(db_task.tags) if db_task.tags else [],
            estimated_time=db_task.estimated_time,
            obsidian_file_path=db_task.obsidian_file_path,
            ai_reasoning=db_task.ai_reasoning,
            created_at=db_task.created_at,
            updated_at=db_task.updated_at
        )
        
        logger.info(f"Created task with AI analysis: {task.title} (score: {priority_score})")
        return task
        
    except Exception as e:
        logger.error(f"Task creation failed: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="작업 생성 중 오류가 발생했습니다")


@router.get("/tasks", response_model=TaskListResponse)
async def get_tasks_by_priority(
    status: str = None,
    min_priority: int = 0,
    max_priority: int = 20,
    page: int = 1,
    page_size: int = 20,
    db: Session = Depends(get_db)
):
    """
    우선순위 순으로 작업 목록을 조회합니다.
    
    - **status**: 작업 상태 필터 (inbox, todo, in_progress, completed)
    - **min_priority**: 최소 우선순위 점수
    - **max_priority**: 최대 우선순위 점수
    - **page**: 페이지 번호
    - **page_size**: 페이지 크기
    """
    try:
        query = db.query(TaskModel)
        
        # 필터 적용
        if status:
            query = query.filter(TaskModel.status == status)
        
        query = query.filter(
            TaskModel.priority_score >= min_priority,
            TaskModel.priority_score <= max_priority
        )
        
        # 총 개수
        total = query.count()
        
        # 우선순위 내림차순으로 정렬 및 페이징
        tasks_db = (
            query
            .order_by(TaskModel.priority_score.desc(), TaskModel.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )
        
        # Task 객체로 변환
        tasks = []
        for task_db in tasks_db:
            task = Task(
                id=task_db.id,
                title=task_db.title,
                content=task_db.content,
                urgency=task_db.urgency,
                importance=task_db.importance,
                priority_score=task_db.priority_score,
                status=task_db.status,
                tags=json.loads(task_db.tags) if task_db.tags else [],
                estimated_time=task_db.estimated_time,
                obsidian_file_path=task_db.obsidian_file_path,
                ai_reasoning=task_db.ai_reasoning,
                created_at=task_db.created_at,
                updated_at=task_db.updated_at
            )
            tasks.append(task)
        
        return TaskListResponse(
            success=True,
            message="작업 목록 조회 완료",
            data=tasks,
            total=total,
            page=page,
            page_size=page_size
        )
        
    except Exception as e:
        logger.error(f"Task list retrieval failed: {e}")
        raise HTTPException(status_code=500, detail="작업 목록 조회 중 오류가 발생했습니다")


@router.get("/tasks/top-priority")
async def get_top_priority_tasks(
    limit: int = 3,
    db: Session = Depends(get_db)
):
    """
    최고 우선순위 작업들을 조회합니다 (알림용).
    
    - **limit**: 반환할 작업 수 (기본: 3)
    """
    try:
        tasks_db = (
            db.query(TaskModel)
            .filter(TaskModel.status.in_(["todo", "in_progress"]))
            .order_by(TaskModel.priority_score.desc())
            .limit(limit)
            .all()
        )
        
        tasks = []
        for task_db in tasks_db:
            task = Task(
                id=task_db.id,
                title=task_db.title,
                content=task_db.content,
                urgency=task_db.urgency,
                importance=task_db.importance,
                priority_score=task_db.priority_score,
                status=task_db.status,
                tags=json.loads(task_db.tags) if task_db.tags else [],
                estimated_time=task_db.estimated_time,
                obsidian_file_path=task_db.obsidian_file_path,
                ai_reasoning=task_db.ai_reasoning,
                created_at=task_db.created_at,
                updated_at=task_db.updated_at
            )
            tasks.append(task)
        
        return {
            "success": True,
            "message": f"상위 {len(tasks)}개 우선순위 작업",
            "data": tasks
        }
        
    except Exception as e:
        logger.error(f"Top priority tasks retrieval failed: {e}")
        raise HTTPException(status_code=500, detail="우선순위 작업 조회 중 오류가 발생했습니다")


@router.post("/reanalyze/{task_id}")
async def reanalyze_task(
    task_id: int,
    db: Session = Depends(get_db),
    ai_service: AIService = Depends(AIService)
):
    """
    기존 작업의 우선순위를 다시 분석합니다.
    
    - **task_id**: 재분석할 작업 ID
    """
    try:
        # 작업 조회
        task_db = db.query(TaskModel).filter(TaskModel.id == task_id).first()
        if not task_db:
            raise HTTPException(status_code=404, detail="작업을 찾을 수 없습니다")
        
        # AI 재분석
        analysis = await ai_service.analyze_priority(task_db.content)
        
        # 데이터베이스 업데이트
        task_db.urgency = analysis.urgency
        task_db.importance = analysis.importance
        task_db.priority_score = calculate_priority_score(analysis.urgency, analysis.importance)
        task_db.ai_reasoning = analysis.reasoning
        
        # 기존 태그 + 새 제안 태그 병합
        existing_tags = json.loads(task_db.tags) if task_db.tags else []
        all_tags = list(set(existing_tags + analysis.suggested_tags))
        task_db.tags = format_tags_for_db(all_tags)
        
        db.commit()
        
        return {
            "success": True,
            "message": "작업 재분석 완료",
            "data": {
                "new_priority_score": task_db.priority_score,
                "urgency": analysis.urgency,
                "importance": analysis.importance,
                "reasoning": analysis.reasoning,
                "suggested_tags": analysis.suggested_tags
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Task reanalysis failed: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail="작업 재분석 중 오류가 발생했습니다")


# ============ Multi-Persona Endpoints (GPT-5 업그레이드) ============

@router.get("/personas")
async def get_available_personas():
    """
    사용 가능한 AI 페르소나 목록을 조회합니다.
    """
    try:
        personas = persona_manager.get_available_personas()
        return {
            "success": True,
            "message": "페르소나 목록 조회 완료",
            "data": personas,
            "total_personas": len(personas)
        }
    except Exception as e:
        logger.error(f"Persona list retrieval failed: {e}")
        raise HTTPException(status_code=500, detail="페르소나 목록 조회 중 오류가 발생했습니다")


@router.post("/personas/{persona_type}/analyze")
async def analyze_with_persona(
    persona_type: str,
    content: str,
    context: str = ""
):
    """
    특정 페르소나로 우선순위를 분석합니다.
    
    - **persona_type**: 페르소나 타입 (productivity, fitness, auto)
    - **content**: 분석할 내용
    - **context**: 추가 맥락 (선택사항)
    """
    try:
        # 페르소나 타입 변환
        if persona_type == "productivity":
            selected_persona = PersonaType.PRODUCTIVITY
        elif persona_type == "fitness":
            selected_persona = PersonaType.FITNESS
        elif persona_type == "auto":
            selected_persona = PersonaType.AUTO
        else:
            raise HTTPException(status_code=400, detail="지원하지 않는 페르소나 타입입니다")
        
        # 페르소나별 분석 실행
        analysis, used_persona = await persona_manager.analyze_priority(
            content, context, selected_persona
        )
        
        return {
            "success": True,
            "message": f"{used_persona.value} 페르소나 분석 완료",
            "data": {
                "analysis": analysis.dict(),
                "used_persona": used_persona.value,
                "model": "gpt-5"
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Persona-specific analysis failed: {e}")
        raise HTTPException(status_code=500, detail="페르소나 분석 중 오류가 발생했습니다")


@router.post("/personas/{persona_type}/suggest")
async def get_persona_suggestion(
    persona_type: str,
    content: str,
    context: str = ""
):
    """
    특정 페르소나의 맞춤형 제안을 받습니다.
    
    - **persona_type**: 페르소나 타입 (productivity, fitness, auto)
    - **content**: 제안 요청 내용
    - **context**: 추가 맥락 (선택사항)
    """
    try:
        # 페르소나 타입 변환
        if persona_type == "productivity":
            selected_persona = PersonaType.PRODUCTIVITY
        elif persona_type == "fitness":
            selected_persona = PersonaType.FITNESS
        elif persona_type == "auto":
            selected_persona = PersonaType.AUTO
        else:
            raise HTTPException(status_code=400, detail="지원하지 않는 페르소나 타입입니다")
        
        # 페르소나별 제안 생성
        suggestion, used_persona = await persona_manager.generate_suggestion(
            content, context, selected_persona
        )
        
        return {
            "success": True,
            "message": f"{used_persona.value} 페르소나 제안 생성 완료",
            "data": {
                "suggestion": suggestion,
                "used_persona": used_persona.value,
                "model": "gpt-5"
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Persona suggestion failed: {e}")
        raise HTTPException(status_code=500, detail="페르소나 제안 생성 중 오류가 발생했습니다")


@router.post("/personas/detect")
async def detect_best_persona(content: str, context: str = ""):
    """
    콘텐츠에 가장 적합한 페르소나를 자동 감지합니다.
    
    - **content**: 분석할 내용
    - **context**: 추가 맥락 (선택사항)
    """
    try:
        detected_persona = persona_manager.detect_persona(content, context)
        persona_info = persona_manager.get_persona_info(detected_persona)
        
        return {
            "success": True,
            "message": "페르소나 자동 감지 완료",
            "data": {
                "detected_persona": detected_persona.value,
                "persona_info": persona_info,
                "confidence": "high"  # 향후 신뢰도 점수 추가 가능
            }
        }
        
    except Exception as e:
        logger.error(f"Persona detection failed: {e}")
        raise HTTPException(status_code=500, detail="페르소나 감지 중 오류가 발생했습니다")