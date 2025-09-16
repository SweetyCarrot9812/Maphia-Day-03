from beanie import Document, Indexed
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List
from enum import Enum


class ExerciseType(str, Enum):
    COMPOUND = "compound"
    ISOLATION = "isolation"
    CARDIO = "cardio"
    STRETCH = "stretch"


class MuscleGroup(str, Enum):
    CHEST = "chest"
    BACK = "back"
    SHOULDERS = "shoulders"
    ARMS = "arms"
    LEGS = "legs"
    CORE = "core"
    FULL_BODY = "full_body"


class WorkoutStatus(str, Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    SKIPPED = "skipped"


class SetType(str, Enum):
    NORMAL = "normal"
    WARMUP = "warmup"
    DROP = "drop"
    FAILURE = "failure"
    REST_PAUSE = "rest_pause"


class ExerciseSet(BaseModel):
    set_number: int = Field(..., ge=1)
    set_type: SetType = SetType.NORMAL
    weight_kg: Optional[float] = Field(None, ge=0)
    reps: Optional[int] = Field(None, ge=0)
    duration_seconds: Optional[int] = Field(None, ge=0)  # For time-based exercises
    distance_meters: Optional[float] = Field(None, ge=0)  # For cardio
    rpe: Optional[float] = Field(None, ge=1, le=10)  # Rate of Perceived Exertion
    rest_seconds: Optional[int] = Field(None, ge=0)
    notes: Optional[str] = None
    completed_at: Optional[datetime] = None


class Exercise(Document):
    name: Indexed(str)
    description: Optional[str] = None
    instructions: Optional[List[str]] = Field(default_factory=list)

    # Exercise categorization
    exercise_type: ExerciseType
    primary_muscles: List[MuscleGroup] = Field(default_factory=list)
    secondary_muscles: List[MuscleGroup] = Field(default_factory=list)

    # Equipment and difficulty
    equipment_needed: List[str] = Field(default_factory=list)
    difficulty_level: int = Field(1, ge=1, le=5)

    # Media
    image_urls: List[str] = Field(default_factory=list)
    video_urls: List[str] = Field(default_factory=list)

    # Metadata
    created_by: Optional[str] = None  # User ID who created
    is_custom: bool = Field(default=False)
    is_active: bool = Field(default=True)

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "exercises"
        indexes = [
            "name",
            "exercise_type",
            "primary_muscles",
            "created_by",
            [("name", 1), ("is_active", 1)],
        ]


class WorkoutExercise(BaseModel):
    exercise_id: str = Field(..., description="Reference to Exercise document")
    exercise_name: str = Field(..., description="Cached exercise name")

    # Planned sets
    planned_sets: int = Field(..., ge=1)
    planned_reps: Optional[int] = Field(None, ge=1)
    planned_weight_kg: Optional[float] = Field(None, ge=0)
    planned_duration_seconds: Optional[int] = Field(None, ge=0)

    # Completed sets
    sets: List[ExerciseSet] = Field(default_factory=list)

    # Exercise order in workout
    order: int = Field(..., ge=1)

    # Superset grouping
    superset_group: Optional[str] = None

    # Notes
    notes: Optional[str] = None


class WorkoutSession(Document):
    # User reference
    user_id: Indexed(str)

    # Workout details
    name: str = Field(..., min_length=1)
    description: Optional[str] = None

    # Workout data
    exercises: List[WorkoutExercise] = Field(default_factory=list)

    # Status and timing
    status: WorkoutStatus = WorkoutStatus.PLANNED
    scheduled_at: Optional[datetime] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    duration_seconds: Optional[int] = Field(None, ge=0)

    # Workout metrics
    total_volume_kg: Optional[float] = Field(None, ge=0)  # weight * reps sum
    total_sets: int = Field(default=0)
    average_rpe: Optional[float] = Field(None, ge=1, le=10)
    calories_burned: Optional[int] = Field(None, ge=0)

    # Template and program references
    template_id: Optional[str] = None
    program_id: Optional[str] = None
    week_number: Optional[int] = None
    day_number: Optional[int] = None

    # Location and environment
    location: Optional[str] = None
    weather: Optional[str] = None
    mood_before: Optional[int] = Field(None, ge=1, le=5)
    mood_after: Optional[int] = Field(None, ge=1, le=5)

    # Notes and feedback
    notes: Optional[str] = None
    coach_feedback: Optional[str] = None

    # Tags for categorization
    tags: List[str] = Field(default_factory=list)

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "workout_sessions"
        indexes = [
            "user_id",
            "status",
            "scheduled_at",
            "started_at",
            "completed_at",
            "template_id",
            "program_id",
            [("user_id", 1), ("completed_at", -1)],
            [("user_id", 1), ("status", 1)],
        ]

    def calculate_metrics(self):
        """Calculate workout metrics from exercises"""
        total_volume = 0
        total_sets = 0
        rpe_values = []

        for exercise in self.exercises:
            for set_data in exercise.sets:
                if set_data.weight_kg and set_data.reps:
                    total_volume += set_data.weight_kg * set_data.reps
                total_sets += 1
                if set_data.rpe:
                    rpe_values.append(set_data.rpe)

        self.total_volume_kg = total_volume
        self.total_sets = total_sets
        self.average_rpe = sum(rpe_values) / len(rpe_values) if rpe_values else None

        # Calculate duration if both start and end times exist
        if self.started_at and self.completed_at:
            self.duration_seconds = int((self.completed_at - self.started_at).total_seconds())

        self.updated_at = datetime.utcnow()

    def start_workout(self):
        """Start the workout"""
        self.status = WorkoutStatus.IN_PROGRESS
        self.started_at = datetime.utcnow()
        self.updated_at = datetime.utcnow()

    def complete_workout(self):
        """Complete the workout"""
        self.status = WorkoutStatus.COMPLETED
        self.completed_at = datetime.utcnow()
        self.calculate_metrics()

    def skip_workout(self):
        """Skip the workout"""
        self.status = WorkoutStatus.SKIPPED
        self.updated_at = datetime.utcnow()


class Workout(Document):
    """Workout template/plan"""
    # Basic info
    name: str = Field(..., min_length=1)
    description: Optional[str] = None

    # Template data
    exercises: List[WorkoutExercise] = Field(default_factory=list)

    # Metadata
    created_by: Indexed(str)  # User ID
    difficulty_level: int = Field(1, ge=1, le=5)
    estimated_duration_minutes: Optional[int] = Field(None, ge=1)

    # Categorization
    workout_type: str = Field(default="strength")  # strength, cardio, hybrid, etc.
    target_muscles: List[MuscleGroup] = Field(default_factory=list)
    tags: List[str] = Field(default_factory=list)

    # Usage tracking
    times_used: int = Field(default=0)
    average_rating: Optional[float] = Field(None, ge=1, le=5)

    # Visibility
    is_public: bool = Field(default=False)
    is_active: bool = Field(default=True)

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Settings:
        name = "workouts"
        indexes = [
            "created_by",
            "workout_type",
            "target_muscles",
            "is_public",
            [("created_by", 1), ("is_active", 1)],
            [("is_public", 1), ("average_rating", -1)],
        ]