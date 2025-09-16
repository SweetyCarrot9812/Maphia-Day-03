from beanie import Document, Indexed
from pydantic import BaseModel, Field, EmailStr
from datetime import datetime
from typing import Optional, List
from enum import Enum


class UserRole(str, Enum):
    USER = "user"
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"


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


class UserProfile(BaseModel):
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

    # Medical
    medical_conditions: List[str] = Field(default_factory=list)
    injuries: List[str] = Field(default_factory=list)


class User(Document):
    # Authentication fields (Firebase Auth compatible)
    email: Indexed(EmailStr, unique=True)
    password_hash: Optional[str] = None  # None for OAuth users

    # Basic Info
    full_name: str = Field(..., min_length=1, max_length=100)
    display_name: Optional[str] = Field(None, max_length=50)
    avatar_url: Optional[str] = None

    # OAuth fields (Google Sign-In)
    google_id: Optional[str] = None
    is_oauth_user: bool = Field(default=False)

    # User role and permissions (Firebase Auth style)
    role: UserRole = Field(default=UserRole.USER)
    permissions: List[str] = Field(default_factory=list)
    platform: str = Field(default="areumfit")

    # Profile data
    profile: UserProfile = Field(default_factory=UserProfile)

    # Account status
    is_active: bool = Field(default=True)
    is_verified: bool = Field(default=False)
    email_verified_at: Optional[datetime] = None

    # App Settings
    notifications_enabled: bool = True
    dark_mode: bool = False
    language: str = "ko"
    timezone: str = Field(default="Asia/Seoul")

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    last_login_at: Optional[datetime] = None

    class Settings:
        name = "users"
        indexes = [
            "email",
            "google_id",
            "created_at",
            [("email", 1), ("is_active", 1)],
        ]

    def is_super_admin(self) -> bool:
        """Check if user is super admin (Firebase Auth compatible)"""
        return self.role == UserRole.SUPER_ADMIN or self.email == "tkandpf26@gmail.com"

    def update_profile(self, profile_data: dict):
        """Update user profile"""
        for key, value in profile_data.items():
            if hasattr(self.profile, key):
                setattr(self.profile, key, value)
        self.updated_at = datetime.utcnow()

    def update_last_login(self):
        """Update last login timestamp"""
        self.last_login_at = datetime.utcnow()

    def add_permission(self, permission: str):
        """Add permission to user"""
        if permission not in self.permissions:
            self.permissions.append(permission)

    def remove_permission(self, permission: str):
        """Remove permission from user"""
        if permission in self.permissions:
            self.permissions.remove(permission)

    def has_permission(self, permission: str) -> bool:
        """Check if user has specific permission"""
        return permission in self.permissions or self.is_super_admin()

    def dict(self, **kwargs):
        """Override to exclude sensitive fields"""
        exclude = kwargs.get("exclude", set())
        if isinstance(exclude, set):
            exclude.add("password_hash")
        kwargs["exclude"] = exclude
        return super().dict(**kwargs)
