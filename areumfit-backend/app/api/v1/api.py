from fastapi import APIRouter

from app.api.v1.endpoints import exercises, sessions, recommendations, ai_coach

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(exercises.router, prefix="/exercises", tags=["exercises"])
api_router.include_router(sessions.router, prefix="/sessions", tags=["sessions"])
api_router.include_router(recommendations.router, prefix="/recommendations", tags=["recommendations"])
api_router.include_router(ai_coach.router, prefix="/ai-coach", tags=["ai-coach"])
