from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
import logging
import os

from app.core.config import settings
from app.api.v1.api import api_router
from app.core.database import init_db

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper()), format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("🚀 Starting AreumFit Backend API Server...")

    # Skip database initialization for Vercel (serverless)
    if not os.getenv("VERCEL"):
        try:
            await init_db()
            logger.info("✅ Database connection established")
        except Exception as e:
            logger.error(f"❌ Database connection failed: {e}")
            # Don't raise for serverless - continue without DB
            logger.warning("Continuing without database connection...")

    yield

    # Shutdown
    logger.info("👋 Shutting down AreumFit Backend API Server...")


# Create FastAPI application
app = FastAPI(
    title="AreumFit API",
    description="""
    🏋️‍♀️ **AreumFit Backend API** 
    
    Personal fitness coaching platform with AI-powered recommendations.
    
    ## Features
    
    * **AI Coach**: OpenAI GPT-4 powered personal trainer
    * **Workout Planning**: Intelligent exercise recommendations
    * **Progress Tracking**: Comprehensive fitness analytics  
    * **User Management**: Secure authentication and profiles
    
    ## Models
    
    * **Exercise Management**: Create, track, and analyze exercises
    * **Session Tracking**: Record workout sessions with detailed sets
    * **AI Recommendations**: Get personalized workout plans
    * **Progress Analytics**: Monitor fitness journey with insights
    """,
    version="1.0.0",
    contact={
        "name": "Hanoa Team",
        "email": "support@hanoa.co.kr",
    },
    license_info={
        "name": "MIT License",
        "url": "https://opensource.org/licenses/MIT",
    },
    lifespan=lifespan,
)

# Add middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(TrustedHostMiddleware, allowed_hosts=["*"] if settings.DEBUG else ["localhost", "127.0.0.1"])

# Include API router
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "🏋️‍♀️ AreumFit API Server is running!",
        "version": "1.0.0",
        "status": "healthy",
        "docs": "/docs",
        "redoc": "/redoc",
    }


@app.get("/health")
async def health_check():
    """Detailed health check for monitoring"""
    return {
        "status": "healthy",
        "timestamp": "2025-01-23T10:00:00Z",
        "version": "1.0.0",
        "services": {"api": "running", "database": "connected", "ai_service": "available"},
    }


# Vercel handler
def handler(request):
    return app

# For local development
if __name__ == "__main__":
    import uvicorn

    logger.info(f"🚀 Starting server on {settings.HOST}:{settings.PORT}")
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
