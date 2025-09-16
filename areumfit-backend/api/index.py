"""
Vercel serverless function entry point for AreumFit API
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import os

# Create simple FastAPI app for testing
app = FastAPI(
    title="AreumFit API",
    description="Personal fitness coaching platform with AI-powered recommendations",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "message": "🏋️‍♀️ AreumFit API Server is running!",
        "version": "1.0.0",
        "status": "healthy",
        "environment": "vercel" if os.getenv("VERCEL") else "local",
        "docs": "/docs",
        "redoc": "/redoc",
    }

@app.get("/health")
async def health_check():
    """Detailed health check for monitoring"""
    return {
        "status": "healthy",
        "version": "1.0.0",
        "environment": "vercel" if os.getenv("VERCEL") else "local",
        "services": {
            "api": "running",
            "database": "not_configured",
            "ai_service": "available"
        },
    }

# Test API endpoints
@app.get("/api/v1/test")
async def test_endpoint():
    """Simple test endpoint"""
    return {"message": "API is working!", "environment": os.getenv("VERCEL", "local")}

# Export for Vercel
def handler(request):
    return app

# For backwards compatibility
application = app