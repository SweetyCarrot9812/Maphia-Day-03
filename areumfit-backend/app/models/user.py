from beanie import Document, Indexed
from pydantic import Field, EmailStr
from datetime import datetime
from typing import Optional, List
from enum import Enum


class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"


class ExperienceLevel(str, Enum):
    BEGINNER = "beginner"
    INTERMEDIATE = "intermediate"
    ADVANCED = "advanced"


class FitnessGoal(str, Enum):
    WEIGHT_LOSS = "weight_loss"
    MUSCLE_GAIN = "muscle_gain"
    STRENGTH = "strength"
    ENDURANCE = "endurance"
    POSTURE = "posture"
    STRESS_RELIEF = "stress_relief"


class User(Document):
    # Basic Info
    email: Indexed(EmailStr, unique=True)
    username: Indexed(str, unique=True)
    full_name: str
    hashed_password: str

    # Physical Info
    age: Optional[int] = None
    gender: Optional[Gender] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None

    # Fitness Info
    experience_level: ExperienceLevel = ExperienceLevel.BEGINNER
    fitness_goals: List[FitnessGoal] = Field(default_factory=list)

    # Personal Records (1RM in kg)
    pr_squat: Optional[float] = None
    pr_bench: Optional[float] = None
    pr_deadlift: Optional[float] = None

    # Preferences
    preferred_workout_duration: Optional[int] = Field(default=60, description="Minutes")
    preferred_rest_days: List[int] = Field(default_factory=list, description="Days of week (0=Sunday)")

    # App Settings
    notifications_enabled: bool = True
    dark_mode: bool = False
    language: str = "ko"

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None

    # Account Status
    is_active: bool = True
    is_verified: bool = False

    class Settings:
        name = "users"

    def dict(self, **kwargs):
        """Override to exclude sensitive fields"""
        exclude = kwargs.get("exclude", set())
        if isinstance(exclude, set):
            exclude.add("hashed_password")
        kwargs["exclude"] = exclude
        return super().dict(**kwargs)
