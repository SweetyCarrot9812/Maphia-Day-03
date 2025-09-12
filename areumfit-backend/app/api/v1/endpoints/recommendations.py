from fastapi import APIRouter, HTTPException, Depends, Query
from typing import Dict, Any, Optional
import logging
from datetime import datetime

from app.schemas.recommendation import RecommendationRequest, WorkoutPlanResponse, UserConditionRequest
from app.services.ai_coach_service import AICoachService

router = APIRouter()
logger = logging.getLogger(__name__)


def get_ai_coach_service() -> AICoachService:
    return AICoachService()


@router.post("/workout-plan", response_model=Dict[str, Any])
async def generate_workout_plan(
    request: RecommendationRequest, ai_service: AICoachService = Depends(get_ai_coach_service)
):
    """
    AI 기반 맞춤 운동 계획 생성

    사용자의 현재 컨디션과 운동 기록을 바탕으로
    오늘의 최적화된 운동 계획을 추천합니다.
    """
    try:
        # Generate workout recommendation
        recommendation = await ai_service.generate_workout_recommendation(
            user_id=request.user_id,
            current_condition=request.current_condition,
            workout_history=[],  # TODO: Fetch from database
            user_profile={},  # TODO: Fetch from database
        )

        # Add metadata
        recommendation["generated_at"] = datetime.now().isoformat()
        recommendation["user_id"] = request.user_id
        recommendation["version"] = "1.0"

        return recommendation

    except Exception as e:
        logger.error(f"Error generating workout plan: {e}")
        raise HTTPException(status_code=500, detail="운동 계획 생성 중 오류가 발생했습니다.")


@router.post("/condition")
async def save_user_condition(request: UserConditionRequest):
    """
    사용자 컨디션 저장

    오늘의 컨디션 정보를 저장하여 운동 추천에 활용합니다.
    """
    try:
        # TODO: Save to database
        condition_data = {
            "user_id": request.user_id,
            "date": datetime.now().date().isoformat(),
            "energy": request.energy,
            "soreness": request.soreness,
            "sleep_hours": request.sleep_hours,
            "stress": request.stress,
            "motivation": request.motivation,
            "notes": request.notes,
            "created_at": datetime.now().isoformat(),
        }

        logger.info(f"Saved condition data for user {request.user_id}")

        return {"message": "컨디션 정보가 저장되었습니다.", "data": condition_data}

    except Exception as e:
        logger.error(f"Error saving user condition: {e}")
        raise HTTPException(status_code=500, detail="컨디션 정보 저장 중 오류가 발생했습니다.")


@router.get("/condition/{user_id}")
async def get_user_condition(user_id: str, date: Optional[str] = Query(None, description="YYYY-MM-DD format")):
    """
    사용자 컨디션 조회

    특정 날짜의 컨디션 정보를 조회합니다.
    날짜를 지정하지 않으면 오늘의 컨디션을 반환합니다.
    """
    try:
        target_date = date or datetime.now().date().isoformat()

        # TODO: Fetch from database
        # For now, return mock data
        condition = {
            "user_id": user_id,
            "date": target_date,
            "energy": "good",
            "soreness": "light",
            "sleep_hours": 7,
            "stress": "moderate",
            "motivation": "high",
            "notes": "",
            "created_at": datetime.now().isoformat(),
        }

        return condition

    except Exception as e:
        logger.error(f"Error fetching user condition: {e}")
        raise HTTPException(status_code=500, detail="컨디션 정보 조회 중 오류가 발생했습니다.")


@router.get("/history/{user_id}")
async def get_recommendation_history(
    user_id: str, limit: int = Query(default=30, ge=1, le=100), offset: int = Query(default=0, ge=0)
):
    """
    추천 기록 조회

    사용자의 과거 운동 추천 기록을 조회합니다.
    """
    try:
        # TODO: Fetch from database
        # For now, return mock data
        history = []

        return {"user_id": user_id, "recommendations": history, "total": len(history), "limit": limit, "offset": offset}

    except Exception as e:
        logger.error(f"Error fetching recommendation history: {e}")
        raise HTTPException(status_code=500, detail="추천 기록 조회 중 오류가 발생했습니다.")


@router.post("/feedback")
async def submit_recommendation_feedback(request: Dict[str, Any]):
    """
    추천 피드백 제출

    운동 추천에 대한 사용자 피드백을 수집하여
    향후 추천 품질을 개선합니다.
    """
    try:
        user_id = request.get("user_id")
        recommendation_id = request.get("recommendation_id")
        rating = request.get("rating")  # 1-5 scale
        feedback = request.get("feedback", "")

        if not all([user_id, recommendation_id, rating]):
            raise HTTPException(status_code=400, detail="user_id, recommendation_id, rating이 필요합니다.")

        if not (1 <= rating <= 5):
            raise HTTPException(status_code=400, detail="rating은 1-5 사이의 값이어야 합니다.")

        # TODO: Save to database
        feedback_data = {
            "user_id": user_id,
            "recommendation_id": recommendation_id,
            "rating": rating,
            "feedback": feedback,
            "submitted_at": datetime.now().isoformat(),
        }

        logger.info(f"Received feedback for recommendation {recommendation_id}")

        return {"message": "피드백이 성공적으로 제출되었습니다.", "data": feedback_data}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error submitting feedback: {e}")
        raise HTTPException(status_code=500, detail="피드백 제출 중 오류가 발생했습니다.")
