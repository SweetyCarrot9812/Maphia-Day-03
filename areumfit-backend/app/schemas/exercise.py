from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class ExerciseBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    muscle_group: str = Field(..., min_length=1, max_length=50)
    type: str = Field(..., description="compound, isolation, cardio")
    rep_range: str = Field(..., description="e.g., '8-12', '5-8'")
    equipment: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = Field(None, max_length=500)
    active: bool = Field(default=True)


class ExerciseCreate(ExerciseBase):
    user_id: str = Field(..., min_length=1)


class ExerciseUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    muscle_group: Optional[str] = Field(None, min_length=1, max_length=50)
    type: Optional[str] = None
    rep_range: Optional[str] = None
    equipment: Optional[str] = Field(None, max_length=50)
    description: Optional[str] = Field(None, max_length=500)
    active: Optional[bool] = None


class ExerciseResponse(ExerciseBase):
    id: str
    user_id: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class ExerciseListResponse(BaseModel):
    exercises: List[ExerciseResponse]
    total: int
    page: int
    size: int
    pages: int
