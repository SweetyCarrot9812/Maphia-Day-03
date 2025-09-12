from beanie import Document, Indexed
from pydantic import Field
from datetime import datetime, date
from typing import Optional, List, Dict
from enum import Enum


class SessionMode(str, Enum):
    HEALTH = "health"
    CROSSFIT = "crossfit"
    CARDIO = "cardio"
    RECOVERY = "recovery"


class SessionStatus(str, Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    SKIPPED = "skipped"


class Session(Document):
    # Basic Info
    user_id: Indexed(str)
    session_date: date = Field(default_factory=date.today)
    mode: SessionMode = Field(default=SessionMode.HEALTH)
    status: SessionStatus = Field(default=SessionStatus.PLANNED)

    # Session Details
    name: Optional[str] = Field(description="Custom session name")
    planned_duration_minutes: Optional[int] = Field(description="Planned session duration")
    actual_duration_minutes: Optional[int] = Field(description="Actual session duration")

    # Workout Plan
    planned_exercises: Optional[List[str]] = Field(default_factory=list, description="Planned exercise IDs")
    completed_exercises: Optional[List[str]] = Field(default_factory=list, description="Completed exercise IDs")

    # Session Metrics
    total_volume_kg: Optional[float] = Field(default=0.0, description="Total weight lifted")
    total_sets: Optional[int] = Field(default=0, description="Total number of sets")
    total_reps: Optional[int] = Field(default=0, description="Total number of reps")
    average_rpe: Optional[float] = Field(description="Average RPE across all sets")
    max_rpe: Optional[float] = Field(description="Maximum RPE in session")

    # Pre/Post Session
    pre_session_notes: Optional[str] = Field(description="Notes before starting")
    post_session_notes: Optional[str] = Field(description="Notes after completion")
    energy_level_pre: Optional[int] = Field(ge=1, le=10, description="Energy level before (1-10)")
    energy_level_post: Optional[int] = Field(ge=1, le=10, description="Energy level after (1-10)")
    mood_pre: Optional[str] = Field(description="Mood before session")
    mood_post: Optional[str] = Field(description="Mood after session")

    # Physical State
    body_weight_kg: Optional[float] = Field(description="Body weight on session day")
    sleep_hours: Optional[float] = Field(description="Hours of sleep previous night")
    stress_level: Optional[int] = Field(ge=1, le=10, description="Stress level (1-10)")
    soreness_areas: Optional[List[str]] = Field(default_factory=list, description="Areas of soreness")

    # Environment
    location: Optional[str] = Field(description="Workout location")
    weather: Optional[str] = Field(description="Weather conditions")
    temperature_celsius: Optional[float] = Field(description="Temperature in Celsius")

    # AI Recommendations
    ai_recommendations: Optional[Dict] = Field(description="AI-generated recommendations")
    ai_session_analysis: Optional[Dict] = Field(description="AI analysis of completed session")

    # Progress Tracking
    new_personal_records: Optional[List[Dict]] = Field(default_factory=list, description="PRs achieved this session")
    improvement_notes: Optional[List[str]] = Field(default_factory=list, description="Areas of improvement noted")

    # Session Rating
    overall_rating: Optional[int] = Field(ge=1, le=5, description="Overall session rating (1-5)")
    difficulty_rating: Optional[int] = Field(ge=1, le=5, description="Session difficulty (1-5)")
    satisfaction_rating: Optional[int] = Field(ge=1, le=5, description="Satisfaction with session (1-5)")

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    started_at: Optional[datetime] = Field(description="When session actually started")
    completed_at: Optional[datetime] = Field(description="When session was completed")

    class Settings:
        name = "sessions"
        indexes = [[("user_id", 1), ("session_date", -1)], [("user_id", 1), ("status", 1)], [("session_date", -1)]]
