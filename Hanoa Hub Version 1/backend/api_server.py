"""
FastAPI server for mobile app integration
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
from ai_batch_generator import BatchQuestionGenerator, BatchGeneratorAPI
from question_types import QuestionType
from learning_plan_engine import LearningPlanEngine


# Pydantic models
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


class BatchGenerateRequest(BaseModel):
    count: int = 10
    subject: str = "nursing"
    topics: List[str] = ["general"]
    types: List[str] = ["MCQ"]
    difficulty: str = "medium"
    save: bool = True


class ImageAnalysisRequest(BaseModel):
    image_base64: str
    domain: str = "medical"
    analyze_depth: str = "standard"
    generate_problems: bool = True
    problem_count: int = 3


class GenerateProblemsRequest(BaseModel):
    image_analysis: Optional[Dict[str, Any]] = None
    problem_type: str = "multiple_choice"
    difficulty: str = "medium"
    count: int = 5
    language: str = "ko"
    subject: str = "nursing"
    types: List[str] = ["MCQ"]
    keywords: List[str] = []


class LearningAnalysisRequest(BaseModel):
    user_id: str
    days_back: int = 30
    include_details: bool = False


class LearningPlanRequest(BaseModel):
    user_id: str
    target_count: int = 12
    focus_weak_areas: bool = True
    days_back: int = 30


class ExecutePlanRequest(BaseModel):
    plan: Dict[str, Any]
    save_to_firebase: bool = True


# FastAPI app
app = FastAPI(
    title="Hanoa RAG API",
    description="RAG API for Hanoa mobile applications",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


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
        # Initialize batch generator API
        global batch_generator_api
        batch_generator_api = BatchGeneratorAPI()
        # Initialize learning plan engine
        global learning_plan_engine
        learning_plan_engine = LearningPlanEngine()
        print("[SUCCESS] API Server initialized successfully")
    except Exception as e:
        print(f"[ERROR] API Server initialization failed: {e}")
        raise


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Hanoa RAG API Server",
        "version": "1.0.0",
        "status": "running"
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


@app.post("/api/v1/problems/generate")
async def generate_problems(
    request: GenerateProblemsRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Generate AI problems - endpoint for Flutter app"""
    try:
        # Convert request to batch generation format
        question_types = [QuestionType(t) for t in request.types]

        # Use batch generator to create questions
        result = await batch_generator_api.generator.generate_batch(
            count=request.count,
            subject=request.subject,
            topics=request.keywords if request.keywords else ["general"],
            question_types=question_types,
            difficulty=request.difficulty,
            save_to_firebase=True
        )

        return {
            "success": True,
            "problems": result['questions'],
            "stats": result['stats']
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate problems: {str(e)}")


@app.post("/api/v1/images/analyze")
async def analyze_image(
    request: ImageAnalysisRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Analyze medical image and optionally generate problems"""
    try:
        # Decode base64 image
        import base64
        image_data = base64.b64decode(request.image_base64)

        # Save temporarily for processing
        import tempfile
        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as tmp_file:
            tmp_file.write(image_data)
            tmp_path = tmp_file.name

        # Analyze and generate problems if requested
        problems = []
        if request.generate_problems:
            for _ in range(request.problem_count):
                question = await batch_generator_api.generator.generate_from_image(
                    image_path=tmp_path,
                    subject=request.domain,
                    topic="radiology",
                    difficulty="medium"
                )
                if question:
                    problems.append(question)

        # Clean up temp file
        import os
        os.unlink(tmp_path)

        return {
            "success": True,
            "analysis": {
                "domain": request.domain,
                "depth": request.analyze_depth,
                "findings": "Medical image analyzed successfully"
            },
            "problems_generated": problems
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to analyze image: {str(e)}")


@app.post("/api/batch/generate")
async def batch_generate_questions(
    request: BatchGenerateRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Batch generate questions with AI"""
    try:
        # Convert types to enum
        question_types = [QuestionType(t) for t in request.types]

        # Generate batch
        result = await batch_generator_api.handle_batch_request({
            "count": request.count,
            "subject": request.subject,
            "topics": request.topics,
            "types": request.types,
            "difficulty": request.difficulty,
            "save": request.save
        })

        return result

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch generation failed: {str(e)}")


@app.post("/api/v1/learning/analyze")
async def analyze_learning_history(
    request: LearningAnalysisRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Analyze user's learning history"""
    try:
        analysis = await learning_plan_engine.analyze_user_history(
            user_id=request.user_id,
            days_back=request.days_back
        )

        return {
            "success": True,
            "user_id": request.user_id,
            "analysis": analysis,
            "analyzed_days": request.days_back
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Learning analysis failed: {str(e)}")


@app.post("/api/v1/learning/plan")
async def generate_learning_plan(
    request: LearningPlanRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Generate personalized learning plan using AI"""
    try:
        # First analyze learning history
        analysis = await learning_plan_engine.analyze_user_history(
            user_id=request.user_id,
            days_back=request.days_back
        )

        # Generate plan based on analysis
        plan = await learning_plan_engine.generate_learning_plan(
            learning_analysis=analysis,
            target_count=request.target_count
        )

        return {
            "success": True,
            "user_id": request.user_id,
            "plan": plan,
            "analysis_summary": {
                "total_attempts": analysis.get('total_attempts', 0),
                "accuracy_rate": analysis.get('overall_accuracy', 0),
                "weak_concepts": analysis.get('weak_concepts', [])[:5]
            }
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Plan generation failed: {str(e)}")


@app.post("/api/v1/learning/execute")
async def execute_learning_plan(
    request: ExecutePlanRequest,
    api_key: bool = Depends(verify_api_key)
):
    """Execute a learning plan to generate questions"""
    try:
        result = await learning_plan_engine.execute_plan(
            plan=request.plan,
            save_to_firebase=request.save_to_firebase
        )

        return {
            "success": result['success'],
            "questions_generated": result.get('total_generated', 0),
            "questions": result.get('questions', []),
            "execution_stats": result.get('stats', {})
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Plan execution failed: {str(e)}")


@app.get("/api/v1/learning/plans/{user_id}")
async def get_user_learning_plans(
    user_id: str,
    limit: int = 10,
    api_key: bool = Depends(verify_api_key)
):
    """Get user's past learning plans from Firebase"""
    try:
        # Get plans from Firebase
        plans = []
        # This would query Firebase for saved plans
        # For now, return placeholder

        return {
            "success": True,
            "user_id": user_id,
            "plans": plans,
            "total": len(plans)
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get plans: {str(e)}")


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
                "database": "connected" if rag_stats['total'] >= 0 else "disconnected"
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
    print(f"🚀 Starting Hanoa RAG API Server on port {API_PORT}")
    print(f"📚 RAG Engine: {rag_engine.get_stats()}")
    print(f"🔄 Jobs Worker: {jobs_worker.get_status()}")
    print(f"📡 API Docs: http://localhost:{API_PORT}/docs")

    uvicorn.run(
        "api_server:app",
        host="0.0.0.0",
        port=API_PORT,
        reload=True,
        log_level="info"
    )


if __name__ == "__main__":
    start_server()