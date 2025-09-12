from beanie import Document, Indexed
from pydantic import Field
from datetime import datetime
from typing import Optional, List, Dict
from enum import Enum


class ExerciseType(str, Enum):
    COMPOUND = "compound"
    ISOLATION = "isolation"
    CARDIO = "cardio"
    PLYOMETRIC = "plyometric"
    BODYWEIGHT = "bodyweight"


class MuscleGroup(str, Enum):
    CHEST = "가슴"
    BACK = "등"
    LEGS = "다리"
    SHOULDERS = "어깨"
    ARMS = "팔"
    CORE = "코어"
    FULL_BODY = "전신"


class Domain(str, Enum):
    HEALTH = "health"
    CROSSFIT = "crossfit"
    BOTH = "both"


class Exercise(Document):
    # Basic Info
    name: str = Field(description="Exercise name")
    user_id: Indexed(str) = Field(description="User who created this exercise")

    # Classification
    domain: Domain = Field(default=Domain.HEALTH)
    muscle_group: MuscleGroup
    exercise_type: ExerciseType

    # Exercise Parameters
    rep_range: str = Field(description="Recommended rep range (e.g., '8-12')")
    rest_seconds: str = Field(description="Rest time range (e.g., '90-120')")
    target_rpe: float = Field(default=8.0, ge=1.0, le=10.0, description="Target RPE")

    # Equipment & Setup
    equipment: Optional[List[str]] = Field(default_factory=list, description="Required equipment")
    setup_instructions: Optional[str] = Field(description="How to set up the exercise")
    warmup_instructions: Optional[str] = Field(description="Warmup recommendations")

    # Weight & Progression
    unit: str = Field(default="kg", description="Weight unit")
    increment: Optional[float] = Field(description="Progression increment")
    estimated_1rm: Optional[float] = Field(description="Current estimated 1RM")

    # Form & Safety
    form_cues: Optional[List[str]] = Field(default_factory=list, description="Form coaching cues")
    common_mistakes: Optional[List[str]] = Field(default_factory=list, description="Common mistakes to avoid")
    safety_notes: Optional[str] = Field(description="Important safety information")

    # Variations & Alternatives
    variations: Optional[List[str]] = Field(default_factory=list, description="Exercise variations")
    alternatives: Optional[List[str]] = Field(default_factory=list, description="Alternative exercises")

    # Scheduling
    exclude_until: Optional[datetime] = Field(description="Exclude from recommendations until this date")
    min_rest_days: int = Field(default=1, description="Minimum rest days between sessions")

    # Metadata
    visibility: str = Field(default="private", description="private, shared, or public")
    tags: Optional[List[str]] = Field(default_factory=list, description="Custom tags")
    notes: Optional[str] = Field(description="Personal notes")

    # AI Enhancement
    ai_analysis: Optional[Dict] = Field(description="AI-generated exercise analysis")
    difficulty_rating: Optional[int] = Field(ge=1, le=5, description="Difficulty rating 1-5")

    # Status
    is_active: bool = Field(default=True)
    is_favorite: bool = Field(default=False)

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "exercises"
        indexes = [
            [("user_id", 1), ("muscle_group", 1)],
            [("user_id", 1), ("is_active", 1)],
            [("domain", 1), ("muscle_group", 1)],
        ]
