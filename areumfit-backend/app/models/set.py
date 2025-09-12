from beanie import Document, Indexed
from pydantic import Field
from datetime import datetime
from typing import Optional, Dict, Any
from enum import Enum


class SetType(str, Enum):
    WORKING = "working"  # 메인 워킹셋
    WARMUP = "warmup"  # 워밍업 세트
    DROPSET = "dropset"  # 드롭셋
    RESTPAUSE = "rest_pause"  # 레스트 폴즈
    CLUSTER = "cluster"  # 클러스터 세트
    BACK_OFF = "back_off"  # 백오프 세트


class Set(Document):
    # Basic Info
    session_id: Indexed(str) = Field(description="Session ID this set belongs to")
    exercise_id: Indexed(str) = Field(description="Exercise ID")
    exercise_name: str = Field(description="Exercise name for quick reference")

    # Set Details
    set_number: int = Field(ge=1, description="Set number in the exercise sequence")
    set_type: SetType = Field(default=SetType.WORKING, description="Type of set")

    # Performance Metrics
    weight_kg: Optional[float] = Field(default=None, ge=0, description="Weight used in kg")
    reps: Optional[int] = Field(default=None, ge=0, description="Number of repetitions")
    reps_target: Optional[int] = Field(default=None, ge=1, description="Target reps for this set")

    # Cardio/Endurance Metrics
    distance_meters: Optional[float] = Field(default=None, ge=0, description="Distance covered in meters")
    duration_seconds: Optional[int] = Field(default=None, ge=0, description="Duration in seconds")
    calories_burned: Optional[int] = Field(default=None, ge=0, description="Estimated calories burned")

    # Intensity Metrics
    rpe: Optional[float] = Field(default=None, ge=1, le=10, description="Rate of Perceived Exertion (1-10)")
    rpe_target: Optional[float] = Field(default=None, ge=1, le=10, description="Target RPE for this set")
    heart_rate_avg: Optional[int] = Field(default=None, ge=40, le=220, description="Average heart rate during set")
    heart_rate_max: Optional[int] = Field(default=None, ge=40, le=220, description="Maximum heart rate during set")

    # Timing
    rest_before_seconds: Optional[int] = Field(default=None, ge=0, description="Rest time before this set")
    rest_after_seconds: Optional[int] = Field(default=None, ge=0, description="Rest time after this set")
    execution_time_seconds: Optional[int] = Field(default=None, ge=0, description="Time to complete the set")

    # Performance Qualifiers
    completed: bool = Field(default=True, description="Whether the set was completed")
    failure_point: Optional[int] = Field(default=None, description="Rep at which failure occurred")
    assisted: bool = Field(default=False, description="Whether assistance was provided")
    form_breakdown: bool = Field(default=False, description="Whether form broke down during set")

    # Technical Details
    tempo: Optional[str] = Field(default=None, description="Tempo notation (e.g., '3-1-2-1')")
    range_of_motion: Optional[str] = Field(default=None, description="Range of motion notes")
    equipment_used: Optional[str] = Field(default=None, description="Specific equipment used")
    grip_type: Optional[str] = Field(default=None, description="Grip type used")

    # Personal Records
    is_personal_record: bool = Field(default=False, description="Whether this set achieved a PR")
    pr_type: Optional[str] = Field(default=None, description="Type of PR (weight, reps, volume)")
    previous_best: Optional[Dict[str, Any]] = Field(default=None, description="Previous best for comparison")

    # Contextual Notes
    notes: Optional[str] = Field(default=None, description="Additional notes about the set")
    environmental_factors: Optional[str] = Field(
        default=None, description="Environmental factors affecting performance"
    )
    pre_set_feeling: Optional[str] = Field(default=None, description="How the athlete felt before the set")
    post_set_feeling: Optional[str] = Field(default=None, description="How the athlete felt after the set")

    # Validation & Quality
    form_rating: Optional[int] = Field(default=None, ge=1, le=5, description="Form quality rating (1-5)")
    confidence_level: Optional[int] = Field(default=None, ge=1, le=5, description="Confidence in the set (1-5)")

    # AI Analysis
    ai_analysis: Optional[Dict[str, Any]] = Field(default=None, description="AI-generated analysis of the set")
    recommendations: Optional[str] = Field(default=None, description="AI recommendations based on this set")

    # Progression Tracking
    volume_kg: Optional[float] = Field(default=None, description="Total volume (weight × reps)")
    relative_intensity: Optional[float] = Field(default=None, description="% of 1RM if known")
    tonnage_contribution: Optional[float] = Field(default=None, description="Contribution to session tonnage")

    # Timestamps
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    performed_at: Optional[datetime] = Field(default=None, description="When the set was actually performed")

    # Computed Properties
    def calculate_volume(self) -> float:
        """Calculate volume (weight × reps)"""
        if self.weight_kg and self.reps:
            return self.weight_kg * self.reps
        return 0.0

    def calculate_intensity_load(self) -> Optional[float]:
        """Calculate intensity load (volume × RPE)"""
        if self.volume_kg and self.rpe:
            return self.volume_kg * self.rpe
        return None

    def is_above_target(self) -> bool:
        """Check if performance exceeded targets"""
        if self.reps_target and self.reps:
            return self.reps > self.reps_target
        return False

    class Settings:
        name = "sets"
        indexes = [
            [("session_id", 1), ("set_number", 1)],
            [("exercise_id", 1), ("performed_at", -1)],
            [("session_id", 1), ("exercise_id", 1)],
            [("is_personal_record", 1), ("performed_at", -1)],
        ]
