from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class ExerciseRecommendationBase(BaseModel):
    name: str = Field(..., min_length=1)
    weight: float = Field(..., ge=0)
    reps: int = Field(..., ge=1, le=100)
    sets: int = Field(..., ge=1, le=20)
    rpe: float = Field(..., ge=1.0, le=10.0)
    rest_seconds: int = Field(..., ge=30, le=600)
    priority: str = Field(..., description="high, medium, low")
    reasoning: str = Field(default="", max_length=500)


class ExerciseRecommendationResponse(ExerciseRecommendationBase):
    exercise_id: Optional[str] = None

    class Config:
        from_attributes = True


class WorkoutPlanBase(BaseModel):
    is_rest_day: bool = Field(default=False)
    primary_muscle_groups: List[str] = Field(default=[])
    daily_reasoning: str = Field(default="", max_length=1000)
    tips: List[str] = Field(default=[])


class WorkoutPlanCreate(WorkoutPlanBase):
    user_id: str = Field(..., min_length=1)
    exercises: List[ExerciseRecommendationBase] = Field(default=[])


class WorkoutPlanResponse(WorkoutPlanBase):
    id: str
    user_id: str
    date: datetime
    exercises: List[ExerciseRecommendationResponse] = Field(default=[])
    created_at: datetime
    is_active: bool = Field(default=True)

    class Config:
        from_attributes = True


class RecommendationRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    current_condition: Optional[Dict[str, Any]] = Field(default=None)
    force_refresh: bool = Field(default=False)


class UserConditionRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    energy: Optional[str] = Field(None, description="poor, fair, good, excellent")
    soreness: Optional[str] = Field(None, description="none, light, moderate, severe")
    sleep_hours: Optional[int] = Field(None, ge=0, le=24)
    stress: Optional[str] = Field(None, description="low, moderate, high")
    motivation: Optional[str] = Field(None, description="low, moderate, high")
    notes: Optional[str] = Field(None, max_length=500)
