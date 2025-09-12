from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class ChatMessage(BaseModel):
    role: str = Field(..., description="user or assistant")
    content: str = Field(..., min_length=1, max_length=2000)
    timestamp: Optional[datetime] = Field(default=None)


class ChatRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    message: str = Field(..., min_length=1, max_length=2000)
    context: Optional[dict] = Field(default=None)
    session_id: Optional[str] = Field(default=None)


class ChatResponse(BaseModel):
    message: str
    session_id: str
    timestamp: datetime

    class Config:
        from_attributes = True


class ChatHistoryRequest(BaseModel):
    user_id: str = Field(..., min_length=1)
    session_id: Optional[str] = Field(default=None)
    limit: int = Field(default=50, ge=1, le=100)


class ChatHistoryResponse(BaseModel):
    messages: List[ChatMessage]
    session_id: str
    total: int
