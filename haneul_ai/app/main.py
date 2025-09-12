"""
Haneul AI Agent - Main FastAPI Application
Personal AI assistant for Obsidian note management with priority scoring and notifications
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn
from loguru import logger

from app.config.settings import get_settings
from app.routers import ai_agent, obsidian, notifications
from app.database import init_db
from app.scheduler import start_scheduler


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifecycle management"""
    # Startup
    logger.info("🚀 Starting Haneul AI Agent")
    init_db()
    start_scheduler()
    yield
    # Shutdown
    logger.info("🔄 Shutting down Haneul AI Agent")


# FastAPI application instance
app = FastAPI(
    title="Haneul AI Agent",
    description="Personal AI assistant for Obsidian note management with priority scoring and notifications",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(ai_agent.router, prefix="/api/ai", tags=["AI Agent"])
app.include_router(obsidian.router, prefix="/api/obsidian", tags=["Obsidian"])
app.include_router(notifications.router, prefix="/api/notifications", tags=["Notifications"])


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "🌟 Haneul AI Agent is running",
        "status": "healthy",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    settings = get_settings()
    return {
        "status": "healthy",
        "obsidian_vault": settings.obsidian_vault_path,
        "debug_mode": settings.debug,
        "notification_time": settings.notification_time
    }


if __name__ == "__main__":
    settings = get_settings()
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.debug,
        log_level=settings.log_level.lower()
    )