from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
import logging
from datetime import datetime
import uuid

from app.schemas.exercise import ExerciseCreate, ExerciseUpdate, ExerciseResponse, ExerciseListResponse

router = APIRouter()
logger = logging.getLogger(__name__)

# Mock data for development
MOCK_EXERCISES = [
    {
        "id": "1",
        "user_id": "demo_user",
        "name": "벤치프레스",
        "muscle_group": "가슴",
        "type": "compound",
        "rep_range": "8-12",
        "equipment": "바벨",
        "description": "상체 기본 복합운동",
        "active": True,
        "created_at": datetime.now(),
        "updated_at": None,
    },
    {
        "id": "2",
        "user_id": "demo_user",
        "name": "스쿼트",
        "muscle_group": "다리",
        "type": "compound",
        "rep_range": "8-15",
        "equipment": "바벨",
        "description": "하체 기본 복합운동",
        "active": True,
        "created_at": datetime.now(),
        "updated_at": None,
    },
    {
        "id": "3",
        "user_id": "demo_user",
        "name": "데드리프트",
        "muscle_group": "등",
        "type": "compound",
        "rep_range": "5-8",
        "equipment": "바벨",
        "description": "전신 복합운동",
        "active": True,
        "created_at": datetime.now(),
        "updated_at": None,
    },
]


@router.get("", response_model=ExerciseListResponse)
async def get_exercises(
    user_id: str = Query(..., description="사용자 ID"),
    muscle_group: Optional[str] = Query(None, description="근육군 필터"),
    type: Optional[str] = Query(None, description="운동 타입 필터"),
    active: Optional[bool] = Query(True, description="활성 운동만 조회"),
    page: int = Query(default=1, ge=1, description="페이지 번호"),
    size: int = Query(default=20, ge=1, le=100, description="페이지 크기"),
):
    """
    운동 목록 조회

    사용자의 운동 목록을 필터링하여 조회합니다.
    """
    try:
        # Filter exercises (mock implementation)
        filtered_exercises = [ex for ex in MOCK_EXERCISES if ex["user_id"] == user_id]

        if muscle_group:
            filtered_exercises = [ex for ex in filtered_exercises if ex["muscle_group"] == muscle_group]

        if type:
            filtered_exercises = [ex for ex in filtered_exercises if ex["type"] == type]

        if active is not None:
            filtered_exercises = [ex for ex in filtered_exercises if ex["active"] == active]

        # Pagination
        total = len(filtered_exercises)
        start = (page - 1) * size
        end = start + size
        paginated_exercises = filtered_exercises[start:end]

        return ExerciseListResponse(
            exercises=[ExerciseResponse(**ex) for ex in paginated_exercises],
            total=total,
            page=page,
            size=size,
            pages=(total + size - 1) // size,
        )

    except Exception as e:
        logger.error(f"Error fetching exercises: {e}")
        raise HTTPException(status_code=500, detail="운동 목록 조회 중 오류가 발생했습니다.")


@router.get("/{exercise_id}", response_model=ExerciseResponse)
async def get_exercise(exercise_id: str):
    """
    특정 운동 조회
    """
    try:
        # Find exercise (mock implementation)
        exercise = next((ex for ex in MOCK_EXERCISES if ex["id"] == exercise_id), None)

        if not exercise:
            raise HTTPException(status_code=404, detail="운동을 찾을 수 없습니다.")

        return ExerciseResponse(**exercise)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching exercise {exercise_id}: {e}")
        raise HTTPException(status_code=500, detail="운동 조회 중 오류가 발생했습니다.")


@router.post("", response_model=ExerciseResponse, status_code=201)
async def create_exercise(exercise: ExerciseCreate):
    """
    새 운동 생성
    """
    try:
        # Create new exercise (mock implementation)
        new_exercise = {
            "id": str(uuid.uuid4()),
            "user_id": exercise.user_id,
            "name": exercise.name,
            "muscle_group": exercise.muscle_group,
            "type": exercise.type,
            "rep_range": exercise.rep_range,
            "equipment": exercise.equipment,
            "description": exercise.description,
            "active": exercise.active,
            "created_at": datetime.now(),
            "updated_at": None,
        }

        MOCK_EXERCISES.append(new_exercise)

        logger.info(f"Created new exercise: {exercise.name} for user {exercise.user_id}")

        return ExerciseResponse(**new_exercise)

    except Exception as e:
        logger.error(f"Error creating exercise: {e}")
        raise HTTPException(status_code=500, detail="운동 생성 중 오류가 발생했습니다.")


@router.patch("/{exercise_id}", response_model=ExerciseResponse)
async def update_exercise(exercise_id: str, exercise_update: ExerciseUpdate):
    """
    운동 정보 수정
    """
    try:
        # Find and update exercise (mock implementation)
        exercise_index = next((i for i, ex in enumerate(MOCK_EXERCISES) if ex["id"] == exercise_id), None)

        if exercise_index is None:
            raise HTTPException(status_code=404, detail="운동을 찾을 수 없습니다.")

        # Update fields
        exercise = MOCK_EXERCISES[exercise_index]
        update_data = exercise_update.model_dump(exclude_unset=True)

        for field, value in update_data.items():
            if value is not None:
                exercise[field] = value

        exercise["updated_at"] = datetime.now()

        logger.info(f"Updated exercise {exercise_id}")

        return ExerciseResponse(**exercise)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating exercise {exercise_id}: {e}")
        raise HTTPException(status_code=500, detail="운동 수정 중 오류가 발생했습니다.")


@router.delete("/{exercise_id}")
async def delete_exercise(exercise_id: str, hard_delete: bool = Query(False)):
    """
    운동 삭제

    hard_delete=False: 소프트 삭제 (active=False)
    hard_delete=True: 하드 삭제 (완전 제거)
    """
    try:
        exercise_index = next((i for i, ex in enumerate(MOCK_EXERCISES) if ex["id"] == exercise_id), None)

        if exercise_index is None:
            raise HTTPException(status_code=404, detail="운동을 찾을 수 없습니다.")

        if hard_delete:
            # Hard delete
            deleted_exercise = MOCK_EXERCISES.pop(exercise_index)
            logger.info(f"Hard deleted exercise {exercise_id}")
        else:
            # Soft delete
            MOCK_EXERCISES[exercise_index]["active"] = False
            MOCK_EXERCISES[exercise_index]["updated_at"] = datetime.now()
            deleted_exercise = MOCK_EXERCISES[exercise_index]
            logger.info(f"Soft deleted exercise {exercise_id}")

        return {"message": "운동이 삭제되었습니다.", "deleted_exercise": ExerciseResponse(**deleted_exercise)}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting exercise {exercise_id}: {e}")
        raise HTTPException(status_code=500, detail="운동 삭제 중 오류가 발생했습니다.")


@router.get("/muscle-groups/list")
async def get_muscle_groups():
    """
    근육군 목록 조회
    """
    muscle_groups = ["가슴", "등", "어깨", "팔", "복근", "다리", "둔근", "종아리", "전신"]

    return {"muscle_groups": muscle_groups, "total": len(muscle_groups)}


@router.get("/types/list")
async def get_exercise_types():
    """
    운동 타입 목록 조회
    """
    exercise_types = [
        {"value": "compound", "label": "복합운동"},
        {"value": "isolation", "label": "고립운동"},
        {"value": "cardio", "label": "유산소"},
        {"value": "stretching", "label": "스트레칭"},
        {"value": "plyometric", "label": "플라이오메트릭"},
    ]

    return {"exercise_types": exercise_types, "total": len(exercise_types)}
