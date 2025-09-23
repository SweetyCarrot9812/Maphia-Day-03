"""
통합 FastAPI 서버 - 이미지 분석 파이프라인 포함
Integrated FastAPI server with image analysis pipeline
"""

from typing import List, Dict, Any, Optional
from datetime import datetime
import uuid

from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

from config import API_PORT, validate_config
from rag_engine import rag_engine
from jobs_worker import jobs_worker

# 이미지 엔드포인트 임포트
from api.image_endpoints import router as image_router


# Pydantic models for existing endpoints
class QuestionData(BaseModel):
    questionText: str
    choices: List[str]
    correctAnswer: str
    explanation: Optional[str] = ""
    subject: Optional[str] = "기본간호학"
    difficulty: Optional[str] = "보통"
    tags: Optional[List[str]] = []
    createdBy: Optional[str] = "mobile_app"


class ConceptData(BaseModel):
    title: str
    description: str
    category: Optional[str] = "기본간호"
    tags: Optional[List[str]] = []


class SearchRequest(BaseModel):
    query: str
    collection_type: Optional[str] = "both"
    n_results: Optional[int] = 5


class SearchResponse(BaseModel):
    query: str
    results: Dict[str, List[Dict[str, Any]]]
    ai_answer: Optional[str] = None
    total_results: int
    search_time: float


class StatusResponse(BaseModel):
    status: str
    rag_stats: Dict[str, Any]
    jobs_status: Dict[str, Any]
    timestamp: str


# FastAPI app
app = FastAPI(
    title="Hanoa RAG API with Image Analysis",
    description="RAG API + Image Analysis Pipeline for Hanoa applications",
    version="2.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include image analysis router
app.include_router(image_router)


# Dependency for API key validation
async def verify_api_key(api_key: Optional[str] = None):
    """Simple API key verification - extend as needed"""
    # For now, allow all requests
    # In production, implement proper API key validation
    return True


@app.on_event("startup")
async def startup_event():
    """Initialize services on startup"""
    try:
        validate_config()
        print("[SUCCESS] Integrated API Server initialized successfully")
        print("[INFO] Image analysis pipeline endpoints available at /api/v1/images/*")
    except Exception as e:
        print(f"[ERROR] API Server initialization failed: {e}")
        raise


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Hanoa RAG API Server with Image Analysis",
        "version": "2.0.0",
        "status": "running",
        "endpoints": {
            "text": [
                "/api/search",
                "/api/questions",
                "/api/concepts",
                "/api/status"
            ],
            "image": [
                "/api/v1/images/upload",
                "/api/v1/images/analyze",
                "/api/v1/problems/generate"
            ],
            "docs": "/docs"
        }
    }


@app.get("/api/status", response_model=StatusResponse)
async def get_status(api_key: bool = Depends(verify_api_key)):
    """Get system status"""
    try:
        rag_stats = rag_engine.get_stats()
        jobs_status = jobs_worker.get_status()

        return StatusResponse(
            status="healthy",
            rag_stats=rag_stats,
            jobs_status=jobs_status,
            timestamp=datetime.now().isoformat()
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Status check failed: {str(e)}")


@app.post("/api/search", response_model=SearchResponse)
async def search_rag(
    search_request: SearchRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Search RAG database"""
    import time

    start_time = time.time()

    try:
        # Perform search
        results = rag_engine.search(
            query=search_request.query,
            collection_type=search_request.collection_type,
            n_results=search_request.n_results
        )

        # Calculate total results
        total_results = len(results['questions']) + len(results['concepts'])

        # Generate AI answer if results found
        ai_answer = None
        if total_results > 0:
            try:
                context = results['questions'] + results['concepts']
                ai_answer = rag_engine.generate_answer(search_request.query, context[:3])
            except Exception as e:
                print(f"AI answer generation failed: {e}")
                ai_answer = "AI 답변 생성 중 오류가 발생했습니다."

        search_time = time.time() - start_time

        return SearchResponse(
            query=search_request.query,
            results=results,
            ai_answer=ai_answer,
            total_results=total_results,
            search_time=search_time
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")


@app.post("/api/questions")
async def add_question(
    question: QuestionData,
    background_tasks: BackgroundTasks,
    api_key: bool = Depends(verify_api_key)
):
    """Add a new question"""
    try:
        # Prepare question data
        question_data = {
            'id': str(uuid.uuid4()),
            'questionText': question.questionText,
            'choices': question.choices,
            'correctAnswer': question.correctAnswer,
            'explanation': question.explanation,
            'subject': question.subject,
            'difficulty': question.difficulty,
            'tags': question.tags,
            'createdBy': question.createdBy,
            'createdAt': datetime.now().isoformat()
        }

        # Add to RAG system
        question_id = rag_engine.add_question(question_data)

        return {
            "success": True,
            "message": "Question added successfully",
            "question_id": question_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add question: {str(e)}")


@app.post("/api/concepts")
async def add_concept(
    concept: ConceptData,
    background_tasks: BackgroundTasks,
    api_key: bool = Depends(verify_api_key)
):
    """Add a new concept"""
    try:
        # Prepare concept data
        concept_data = {
            'id': str(uuid.uuid4()),
            'title': concept.title,
            'description': concept.description,
            'category': concept.category,
            'tags': concept.tags,
            'createdAt': datetime.now().isoformat()
        }

        # Add to RAG system
        concept_id = rag_engine.add_concept(concept_data)

        return {
            "success": True,
            "message": "Concept added successfully",
            "concept_id": concept_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add concept: {str(e)}")


@app.get("/api/jobs/status")
async def get_jobs_status(api_key: bool = Depends(verify_api_key)):
    """Get jobs processing status"""
    try:
        status = jobs_worker.get_status()
        return {
            "success": True,
            "status": status
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get jobs status: {str(e)}")


# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    try:
        # Basic health checks
        rag_stats = rag_engine.get_stats()
        jobs_status = jobs_worker.get_status()

        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "services": {
                "rag_engine": "active",
                "jobs_worker": "active" if jobs_status.get('worker_running', False) else "inactive",
                "database": "connected" if rag_stats['total'] >= 0 else "disconnected",
                "image_pipeline": "active"
            }
        }

    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }


# Error handlers
@app.exception_handler(404)
async def not_found_handler(request, exc):
    return {
        "error": "Endpoint not found",
        "message": "The requested endpoint does not exist",
        "available_endpoints": [
            "/api/search",
            "/api/questions",
            "/api/concepts",
            "/api/status",
            "/api/jobs/status",
            "/api/v1/images/upload",
            "/api/v1/images/analyze",
            "/api/v1/problems/generate",
            "/health"
        ]
    }


@app.exception_handler(500)
async def internal_error_handler(request, exc):
    return {
        "error": "Internal server error",
        "message": "An unexpected error occurred",
        "timestamp": datetime.now().isoformat()
    }


def start_server():
    """Start the API server"""
    print(f"[START] Starting Hanoa Integrated API Server on port {API_PORT}")
    print(f"[INFO] RAG Engine: {rag_engine.get_stats()}")
    print(f"[INFO] Jobs Worker: {jobs_worker.get_status()}")
    print(f"[INFO] API Docs: http://localhost:{API_PORT}/docs")
    print(f"[SUCCESS] Image Analysis Pipeline integrated successfully")

    uvicorn.run(
        "api_server_integrated:app",
        host="0.0.0.0",
        port=API_PORT,
        reload=True,
        log_level="info"
    )


if __name__ == "__main__":
    start_server()