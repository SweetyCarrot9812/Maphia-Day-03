from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Optional, Dict, Any
import logging
from datetime import datetime, date
import uuid

from app.schemas.session import (
    SessionCreate,
    SessionUpdate,
    SessionResponse,
    SessionListResponse,
    SetCreate,
    SetResponse,
)

router = APIRouter()
logger = logging.getLogger(__name__)

# Mock data for development
MOCK_SESSIONS = [
    {
        "id": "session_1",
        "user_id": "demo_user",
        "name": "상체 운동",
        "mode": "health",
        "date": datetime(2025, 1, 23, 10, 0, 0),
        "completed": True,
        "notes": "좋은 운동이었음",
        "created_at": datetime(2025, 1, 23, 10, 0, 0),
        "updated_at": None,
        "sets": [],
    }
]

MOCK_SETS = [
    {
        "id": "set_1",
        "session_id": "session_1",
        "exercise_id": "1",
        "weight": 80.0,
        "reps": 10,
        "distance": None,
        "duration": None,
        "rpe": 8.0,
        "notes": "좋은 세트",
        "created_at": datetime(2025, 1, 23, 10, 5, 0),
    }
]


@router.get("", response_model=SessionListResponse)
async def get_sessions(
    user_id: str = Query(..., description="사용자 ID"),
    mode: Optional[str] = Query(None, description="운동 모드 필터"),
    completed: Optional[bool] = Query(None, description="완료 상태 필터"),
    date_from: Optional[date] = Query(None, description="시작 날짜 (YYYY-MM-DD)"),
    date_to: Optional[date] = Query(None, description="종료 날짜 (YYYY-MM-DD)"),
    page: int = Query(default=1, ge=1, description="페이지 번호"),
    size: int = Query(default=20, ge=1, le=100, description="페이지 크기"),
):
    """
    운동 세션 목록 조회

    사용자의 운동 세션을 필터링하여 조회합니다.
    """
    try:
        # Filter sessions (mock implementation)
        filtered_sessions = [s for s in MOCK_SESSIONS if s["user_id"] == user_id]

        if mode:
            filtered_sessions = [s for s in filtered_sessions if s["mode"] == mode]

        if completed is not None:
            filtered_sessions = [s for s in filtered_sessions if s["completed"] == completed]

        if date_from:
            filtered_sessions = [s for s in filtered_sessions if s["date"].date() >= date_from]

        if date_to:
            filtered_sessions = [s for s in filtered_sessions if s["date"].date() <= date_to]

        # Add sets to each session
        for session in filtered_sessions:
            session_sets = [s for s in MOCK_SETS if s["session_id"] == session["id"]]
            session["sets"] = [SetResponse(**s) for s in session_sets]

        # Pagination
        total = len(filtered_sessions)
        start = (page - 1) * size
        end = start + size
        paginated_sessions = filtered_sessions[start:end]

        return SessionListResponse(
            sessions=[SessionResponse(**s) for s in paginated_sessions],
            total=total,
            page=page,
            size=size,
            pages=(total + size - 1) // size,
        )

    except Exception as e:
        logger.error(f"Error fetching sessions: {e}")
        raise HTTPException(status_code=500, detail="세션 목록 조회 중 오류가 발생했습니다.")


@router.get("/{session_id}", response_model=SessionResponse)
async def get_session(session_id: str):
    """
    특정 세션 조회
    """
    try:
        # Find session (mock implementation)
        session = next((s for s in MOCK_SESSIONS if s["id"] == session_id), None)

        if not session:
            raise HTTPException(status_code=404, detail="세션을 찾을 수 없습니다.")

        # Add sets
        session_sets = [s for s in MOCK_SETS if s["session_id"] == session_id]
        session = session.copy()
        session["sets"] = [SetResponse(**s) for s in session_sets]

        return SessionResponse(**session)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching session {session_id}: {e}")
        raise HTTPException(status_code=500, detail="세션 조회 중 오류가 발생했습니다.")


@router.post("", response_model=SessionResponse, status_code=201)
async def create_session(session: SessionCreate):
    """
    새 운동 세션 시작
    """
    try:
        # Create new session (mock implementation)
        new_session = {
            "id": str(uuid.uuid4()),
            "user_id": session.user_id,
            "name": session.name,
            "mode": session.mode,
            "date": datetime.now(),
            "completed": False,
            "notes": session.notes,
            "created_at": datetime.now(),
            "updated_at": None,
            "sets": [],
        }

        MOCK_SESSIONS.append(new_session)

        logger.info(f"Created new session for user {session.user_id}")

        return SessionResponse(**new_session)

    except Exception as e:
        logger.error(f"Error creating session: {e}")
        raise HTTPException(status_code=500, detail="세션 생성 중 오류가 발생했습니다.")


@router.patch("/{session_id}", response_model=SessionResponse)
async def update_session(session_id: str, session_update: SessionUpdate):
    """
    세션 정보 수정
    """
    try:
        # Find and update session (mock implementation)
        session_index = next((i for i, s in enumerate(MOCK_SESSIONS) if s["id"] == session_id), None)

        if session_index is None:
            raise HTTPException(status_code=404, detail="세션을 찾을 수 없습니다.")

        # Update fields
        session = MOCK_SESSIONS[session_index]
        update_data = session_update.model_dump(exclude_unset=True)

        for field, value in update_data.items():
            if value is not None:
                session[field] = value

        session["updated_at"] = datetime.now()

        # Add sets
        session_sets = [s for s in MOCK_SETS if s["session_id"] == session_id]
        session = session.copy()
        session["sets"] = [SetResponse(**s) for s in session_sets]

        logger.info(f"Updated session {session_id}")

        return SessionResponse(**session)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating session {session_id}: {e}")
        raise HTTPException(status_code=500, detail="세션 수정 중 오류가 발생했습니다.")


@router.post("/{session_id}/sets", response_model=SetResponse, status_code=201)
async def add_set_to_session(session_id: str, set_data: SetCreate):
    """
    세션에 세트 추가
    """
    try:
        # Check if session exists
        session = next((s for s in MOCK_SESSIONS if s["id"] == session_id), None)
        if not session:
            raise HTTPException(status_code=404, detail="세션을 찾을 수 없습니다.")

        # Create new set (mock implementation)
        new_set = {
            "id": str(uuid.uuid4()),
            "session_id": session_id,
            "exercise_id": set_data.exercise_id,
            "weight": set_data.weight,
            "reps": set_data.reps,
            "distance": set_data.distance,
            "duration": set_data.duration,
            "rpe": set_data.rpe,
            "notes": set_data.notes,
            "created_at": datetime.now(),
        }

        MOCK_SETS.append(new_set)

        logger.info(f"Added set to session {session_id}")

        return SetResponse(**new_set)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error adding set to session {session_id}: {e}")
        raise HTTPException(status_code=500, detail="세트 추가 중 오류가 발생했습니다.")


@router.delete("/{session_id}")
async def delete_session(session_id: str):
    """
    세션 삭제
    """
    try:
        session_index = next((i for i, s in enumerate(MOCK_SESSIONS) if s["id"] == session_id), None)

        if session_index is None:
            raise HTTPException(status_code=404, detail="세션을 찾을 수 없습니다.")

        # Delete session and its sets
        deleted_session = MOCK_SESSIONS.pop(session_index)
        MOCK_SETS[:] = [s for s in MOCK_SETS if s["session_id"] != session_id]

        logger.info(f"Deleted session {session_id}")

        return {"message": "세션이 삭제되었습니다.", "deleted_session_id": session_id}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting session {session_id}: {e}")
        raise HTTPException(status_code=500, detail="세션 삭제 중 오류가 발생했습니다.")


@router.get("/{session_id}/analytics")
async def get_session_analytics(session_id: str):
    """
    세션 분석 데이터 조회
    """
    try:
        # Find session
        session = next((s for s in MOCK_SESSIONS if s["id"] == session_id), None)
        if not session:
            raise HTTPException(status_code=404, detail="세션을 찾을 수 없습니다.")

        # Get session sets
        session_sets = [s for s in MOCK_SETS if s["session_id"] == session_id]

        # Calculate analytics
        if not session_sets:
            total_volume = 0
            total_sets = 0
            avg_rpe = 0
            duration_minutes = 0
        else:
            total_volume = sum((s.get("weight", 0) or 0) * (s.get("reps", 0) or 0) for s in session_sets)
            total_sets = len(session_sets)
            rpe_values = [s.get("rpe") for s in session_sets if s.get("rpe")]
            avg_rpe = sum(rpe_values) / len(rpe_values) if rpe_values else 0

            # Estimate duration (mock calculation)
            duration_minutes = total_sets * 3  # 3 minutes per set average

        analytics = {
            "session_id": session_id,
            "total_sets": total_sets,
            "total_volume": round(total_volume, 2),
            "average_rpe": round(avg_rpe, 2),
            "duration_minutes": duration_minutes,
            "exercises_count": len(set(s.get("exercise_id") for s in session_sets)),
            "completion_rate": 100 if session["completed"] else 0,
        }

        return analytics

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting session analytics {session_id}: {e}")
        raise HTTPException(status_code=500, detail="세션 분석 데이터 조회 중 오류가 발생했습니다.")
