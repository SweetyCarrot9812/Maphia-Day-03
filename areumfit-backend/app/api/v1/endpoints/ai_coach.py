from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any, List, Optional
from pydantic import BaseModel
import logging
from datetime import datetime
import uuid

from app.schemas.ai_coach import ChatRequest, ChatResponse, ChatHistoryRequest, ChatHistoryResponse
from app.services.hybrid_ai_service import hybrid_ai_service
from app.services.auth_service import AuthService
from app.core.security import get_current_user_id

router = APIRouter()
logger = logging.getLogger(__name__)


class EnhancedCoachRequest(BaseModel):
    message: str
    context: Optional[Dict[str, Any]] = None
    use_rag: bool = True
    session_id: Optional[str] = None


class WorkoutRecommendationRequest(BaseModel):
    fitness_goals: List[str]
    available_equipment: Optional[List[str]] = None
    preferences: Optional[Dict[str, Any]] = None


class FormAnalysisRequest(BaseModel):
    exercise_name: str
    user_description: str
    video_url: Optional[str] = None


@router.post("/chat", response_model=Dict[str, Any])
async def chat_with_enhanced_coach(
    request: EnhancedCoachRequest,
    current_user_id: str = Depends(get_current_user_id)
):
    """
    RAG-enhanced AI 코치와 채팅하기

    사용자의 운동 관련 질문에 AI 코치가 개인 지식베이스를 참고하여 답변합니다.
    """
    try:
        # Get user profile for context
        user = await AuthService.get_user_by_id(current_user_id)
        if not user:
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        # Build user context
        user_context = {
            "user_id": current_user_id,
            "profile": user.profile.dict(),
            "experience_level": user.profile.experience_level,
            "fitness_goals": user.profile.fitness_goals,
            "preferences": {
                "workout_duration": user.profile.preferred_workout_duration,
                "rest_days": user.profile.preferred_rest_days,
            }
        }

        # Merge with request context
        if request.context:
            user_context.update(request.context)

        # Get enhanced response
        result = await hybrid_ai_service.get_enhanced_response(
            user_query=request.message,
            user_context=user_context,
            use_rag=request.use_rag
        )

        # Add session info
        session_id = request.session_id or str(uuid.uuid4())
        result["session_id"] = session_id
        result["timestamp"] = datetime.now().isoformat()

        return result

    except Exception as e:
        logger.error(f"Error in enhanced AI coach chat: {e}")
        raise HTTPException(
            status_code=500,
            detail="AI 코치와의 대화 중 오류가 발생했습니다."
        )


@router.post("/workout-recommendations")
async def get_workout_recommendations(
    request: WorkoutRecommendationRequest,
    current_user_id: str = Depends(get_current_user_id)
):
    """
    사용자 맞춤 운동 계획을 RAG-enhanced AI로 받습니다.
    """
    try:
        # Get user profile
        user = await AuthService.get_user_by_id(current_user_id)
        if not user:
            raise HTTPException(
                status_code=404,
                detail="User not found"
            )

        user_profile = user.profile.dict()

        # Get hybrid AI recommendations
        result = await hybrid_ai_service.get_workout_recommendations(
            user_profile=user_profile,
            fitness_goals=request.fitness_goals,
            available_equipment=request.available_equipment
        )

        return result

    except Exception as e:
        logger.error(f"Error in workout recommendations: {e}")
        raise HTTPException(
            status_code=500,
            detail="운동 추천 서비스 오류가 발생했습니다."
        )


@router.post("/form-analysis")
async def analyze_workout_form(
    request: FormAnalysisRequest,
    current_user_id: str = Depends(get_current_user_id)
):
    """
    운동 폼을 분석하고 RAG 지식베이스를 참고한 피드백을 제공합니다.
    """
    try:
        result = await hybrid_ai_service.analyze_workout_form(
            exercise_name=request.exercise_name,
            user_description=request.user_description,
            video_url=request.video_url
        )

        return result

    except Exception as e:
        logger.error(f"Error in form analysis: {e}")
        raise HTTPException(
            status_code=500,
            detail="폼 분석 서비스 오류가 발생했습니다."
        )


@router.post("/learn")
async def add_knowledge(
    content: str,
    metadata: Optional[Dict[str, Any]] = None,
    current_user_id: str = Depends(get_current_user_id)
):
    """
    RAG 지식 베이스에 새로운 정보를 추가합니다. (관리자 전용)
    """
    try:
        # Check if user is admin
        user = await AuthService.get_user_by_id(current_user_id)
        if not user or not user.is_super_admin():
            raise HTTPException(
                status_code=403,
                detail="Admin access required"
            )

        # Add to knowledge base
        success = await hybrid_ai_service.rag_service.add_to_knowledge_base(
            content=content,
            metadata=metadata or {"added_by": current_user_id}
        )

        if not success:
            raise HTTPException(
                status_code=500,
                detail="Failed to add to knowledge base"
            )

        return {"message": "Knowledge added successfully"}

    except Exception as e:
        logger.error(f"Error adding knowledge: {e}")
        raise HTTPException(
            status_code=500,
            detail="지식 추가 오류가 발생했습니다."
        )


@router.get("/status")
async def get_ai_coach_status():
    """Enhanced AI 코치 서비스 상태 확인"""
    return {
        "available": True,
        "model": settings.OPENAI_MODEL,
        "features": {
            "chat": True,
            "rag_enhanced": True,
            "workout_recommendations": True,
            "form_analysis": True,
            "knowledge_base": True
        },
        "rag_service": {
            "url": hybrid_ai_service.rag_service.vector_db_url,
            "threshold": hybrid_ai_service.rag_service.similarity_threshold
        }
    }
