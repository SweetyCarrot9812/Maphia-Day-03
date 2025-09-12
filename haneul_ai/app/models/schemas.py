"""
Haneul AI Agent - Pydantic Schemas
Data models for API requests and responses
"""

from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


class Priority(str, Enum):
    """Priority levels"""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    URGENT = "urgent"


class TaskStatus(str, Enum):
    """Task status"""
    INBOX = "inbox"
    TODO = "todo"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    ARCHIVED = "archived"


class NotificationFrequency(str, Enum):
    """Notification frequency options"""
    DAILY = "daily"
    TWICE_DAILY = "twice"
    WEEKLY = "weekly"
    DISABLED = "disabled"


# Base schemas
class TaskBase(BaseModel):
    """Base task schema"""
    title: str = Field(..., min_length=1, max_length=500)
    content: str = Field(..., min_length=1)
    urgency: int = Field(..., ge=1, le=10, description="Urgency score 1-10")
    importance: int = Field(..., ge=1, le=10, description="Importance score 1-10")
    tags: List[str] = Field(default_factory=list)
    estimated_time: Optional[str] = Field(None, description="Estimated time to complete")


class TaskCreate(TaskBase):
    """Schema for creating new tasks"""
    obsidian_file_path: Optional[str] = None


class TaskUpdate(BaseModel):
    """Schema for updating tasks"""
    title: Optional[str] = Field(None, min_length=1, max_length=500)
    content: Optional[str] = None
    urgency: Optional[int] = Field(None, ge=1, le=10)
    importance: Optional[int] = Field(None, ge=1, le=10)
    status: Optional[TaskStatus] = None
    tags: Optional[List[str]] = None
    estimated_time: Optional[str] = None


class Task(TaskBase):
    """Full task schema with metadata"""
    id: int
    status: TaskStatus = TaskStatus.INBOX
    priority_score: int = Field(..., description="Calculated priority score (urgency + importance)")
    created_at: datetime
    updated_at: datetime
    obsidian_file_path: Optional[str] = None
    ai_reasoning: Optional[str] = None
    
    class Config:
        from_attributes = True


# AI Analysis schemas
class PriorityAnalysis(BaseModel):
    """AI priority analysis result"""
    urgency: int = Field(..., ge=1, le=10)
    importance: int = Field(..., ge=1, le=10)
    total_score: int = Field(..., ge=2, le=20)
    reasoning: str
    suggested_tags: List[str]
    estimated_time: str


class TagSuggestion(BaseModel):
    """Tag suggestion result"""
    recommended_tags: List[str]
    category: str
    confidence: float = Field(..., ge=0.0, le=1.0)


# Obsidian schemas
class ObsidianNote(BaseModel):
    """Obsidian note structure"""
    title: str
    content: str
    file_path: str
    created_date: datetime
    modified_date: datetime
    tags: List[str] = Field(default_factory=list)
    front_matter: Dict[str, Any] = Field(default_factory=dict)


class ObsidianSync(BaseModel):
    """Obsidian synchronization request"""
    vault_path: str
    folder_filter: Optional[List[str]] = None
    file_pattern: Optional[str] = None


# Notification schemas
class NotificationSettings(BaseModel):
    """User notification preferences"""
    email_enabled: bool = True
    email_address: str
    notification_time: str = Field(..., pattern=r"^([01]?[0-9]|2[0-3]):[0-5][0-9]$")
    frequency: NotificationFrequency = NotificationFrequency.DAILY
    priority_threshold: int = Field(5, ge=1, le=20)
    include_calendar: bool = True


class NotificationContent(BaseModel):
    """Notification content"""
    subject: str
    body: str
    tasks: List[Task]
    calendar_events: Optional[List[Dict[str, Any]]] = None


# Dashboard schemas
class DashboardStats(BaseModel):
    """Dashboard statistics"""
    total_tasks: int
    completed_tasks: int
    in_progress_tasks: int
    high_priority_tasks: int
    completion_rate: float = Field(..., ge=0.0, le=1.0)
    avg_priority_score: float


class ProjectSummary(BaseModel):
    """Project summary for dashboard"""
    project_name: str
    task_count: int
    completed_count: int
    avg_priority: float
    last_activity: datetime


# API Response schemas
class APIResponse(BaseModel):
    """Standard API response"""
    success: bool
    message: str
    data: Optional[Any] = None


class TaskListResponse(APIResponse):
    """Task list API response"""
    data: List[Task]
    total: int
    page: int
    page_size: int


# Health check schema
class HealthCheck(BaseModel):
    """Health check response"""
    status: str
    timestamp: datetime
    version: str
    obsidian_vault: Optional[str] = None
    ai_service: bool
    email_service: bool
    database: bool