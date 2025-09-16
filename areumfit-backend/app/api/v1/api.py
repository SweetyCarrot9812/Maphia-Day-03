from fastapi import APIRouter

from app.api.v1.endpoints import auth, exercises, sessions, recommendations, ai_coach

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
api_router.include_router(ai_coach.router, prefix="/ai-coach", tags=["AI Coach"])
api_router.include_router(exercises.router, prefix="/exercises", tags=["Exercises"])
api_router.include_router(sessions.router, prefix="/sessions", tags=["Sessions"])
api_router.include_router(recommendations.router, prefix="/recommendations", tags=["Recommendations"])
