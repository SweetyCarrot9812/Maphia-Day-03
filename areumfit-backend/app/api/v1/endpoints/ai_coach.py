from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any
import logging
from datetime import datetime
import uuid

from app.schemas.ai_coach import ChatRequest, ChatResponse, ChatHistoryRequest, ChatHistoryResponse
from app.services.ai_coach_service import AICoachService

router = APIRouter()
logger = logging.getLogger(__name__)


# Dependency to get AI Coach service
def get_ai_coach_service() -> AICoachService:
    return AICoachService()


@router.post("/chat", response_model=ChatResponse)
async def chat_with_coach(request: ChatRequest, ai_service: AICoachService = Depends(get_ai_coach_service)):
    """
    AI 코치와 채팅하기

    사용자의 운동 관련 질문에 AI 코치가 전문적이고 친근하게 답변합니다.
    """
    try:
        # Generate session ID if not provided
        session_id = request.session_id or str(uuid.uuid4())

        # Get AI response
        response_message = await ai_service.chat_with_coach(
            user_id=request.user_id,
            message=request.message,
            context=request.context,
            conversation_history=[],  # TODO: Implement conversation history storage
        )

        return ChatResponse(message=response_message, session_id=session_id, timestamp=datetime.now())

    except Exception as e:
        logger.error(f"Error in AI coach chat: {e}")
        raise HTTPException(status_code=500, detail="AI 코치와의 대화 중 오류가 발생했습니다.")


@router.get("/chat/history", response_model=ChatHistoryResponse)
async def get_chat_history(user_id: str, session_id: str = None, limit: int = 50):
    """
    채팅 기록 조회

    TODO: 실제 채팅 기록 저장/조회 기능 구현 필요
    현재는 빈 기록을 반환합니다.
    """
    # TODO: Implement actual chat history retrieval from database
    return ChatHistoryResponse(messages=[], session_id=session_id or str(uuid.uuid4()), total=0)


@router.post("/quick-advice")
async def get_quick_advice(request: Dict[str, Any], ai_service: AICoachService = Depends(get_ai_coach_service)):
    """
    빠른 조언 요청

    운동 중 빠른 질문에 대한 간단한 답변을 제공합니다.
    """
    try:
        user_id = request.get("user_id")
        question = request.get("question")

        if not user_id or not question:
            raise HTTPException(status_code=400, detail="user_id와 question이 필요합니다.")

        # Add context for quick advice
        context = {
            "type": "quick_advice",
            "current_exercise": request.get("current_exercise"),
            "current_weight": request.get("current_weight"),
            "current_reps": request.get("current_reps"),
        }

        advice = await ai_service.chat_with_coach(user_id=user_id, message=f"빠른 질문: {question}", context=context)

        return {"advice": advice, "timestamp": datetime.now().isoformat()}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in quick advice: {e}")
        raise HTTPException(status_code=500, detail="빠른 조언 생성 중 오류가 발생했습니다.")


@router.get("/status")
async def get_ai_coach_status(ai_service: AICoachService = Depends(get_ai_coach_service)):
    """AI 코치 서비스 상태 확인"""
    return {
        "available": ai_service.is_available,
        "model": "gpt-4o" if ai_service.is_available else "fallback",
        "features": {"chat": True, "workout_recommendations": ai_service.is_available, "quick_advice": True},
    }
