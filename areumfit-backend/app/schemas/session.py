from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class SetBase(BaseModel):
    exercise_id: str = Field(..., min_length=1)
    weight: Optional[float] = Field(None, ge=0)
    reps: Optional[int] = Field(None, ge=1, le=100)
    distance: Optional[float] = Field(None, ge=0)
    duration: Optional[int] = Field(None, ge=1)  # seconds
    rpe: Optional[float] = Field(None, ge=1.0, le=10.0)
    notes: Optional[str] = Field(None, max_length=200)


class SetCreate(SetBase):
    pass


class SetResponse(SetBase):
    id: str
    session_id: str
    created_at: datetime

    class Config:
        from_attributes = True


class SessionBase(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    mode: str = Field(..., description="health, crossfit, custom")
    notes: Optional[str] = Field(None, max_length=500)


class SessionCreate(SessionBase):
    user_id: str = Field(..., min_length=1)


class SessionUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=100)
    mode: Optional[str] = None
    notes: Optional[str] = Field(None, max_length=500)
    completed: Optional[bool] = None


class SessionResponse(SessionBase):
    id: str
    user_id: str
    date: datetime
    completed: bool
    created_at: datetime
    updated_at: Optional[datetime] = None
    sets: Optional[List[SetResponse]] = []

    class Config:
        from_attributes = True


class SessionListResponse(BaseModel):
    sessions: List[SessionResponse]
    total: int
    page: int
    size: int
    pages: int
