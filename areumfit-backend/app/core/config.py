from pydantic import BaseModel, Field
from pydantic_settings import BaseSettings
from typing import List, Optional
import os
from pathlib import Path


class Settings(BaseSettings):
    """Application settings with environment variable support"""

    # API Configuration
    API_V1_PREFIX: str = "/api/v1"
    DEBUG: bool = Field(default=True)
    HOST: str = Field(default="0.0.0.0")
    PORT: int = Field(default=8000)

    # CORS Configuration
    CORS_ORIGINS: List[str] = Field(
        default=["http://localhost:3000", "http://localhost:8080", "http://127.0.0.1:3000", "http://127.0.0.1:8080"]
    )

    # OpenAI Configuration
    OPENAI_API_KEY: str = Field(default="", description="OpenAI API key")
    OPENAI_MODEL: str = Field(default="gpt-4o", description="OpenAI model to use")
    OPENAI_TEMPERATURE: float = Field(default=0.7, ge=0.0, le=2.0)
    OPENAI_MAX_TOKENS: int = Field(default=2000, ge=1, le=4096)


    # Authentication
    JWT_SECRET_KEY: str = Field(default="your-secret-key-change-in-production")
    JWT_ALGORITHM: str = Field(default="HS256")
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=1440)  # 24 hours

    # Redis Configuration
    REDIS_URL: str = Field(default="redis://localhost:6379")

    # Logging
    LOG_LEVEL: str = Field(default="INFO")

    # AI Coach Configuration
    AI_COACH_SYSTEM_PROMPT: str = Field(
        default="""
    당신은 전문 헬스 트레이너이자 크로스핏 코치입니다. 
    사용자의 운동 관련 질문에 친근하고 전문적으로 답변해주세요.

    역할:
    - 운동 프로그램 조언
    - 폼 교정 가이드  
    - 영양 및 회복 조언
    - 동기부여 및 격려
    - 부상 예방 조언

    말투: 친근하되 전문적이고, 한국어로 응답
    """.strip()
    )

    # Exercise Recommendation Configuration
    RPE_TARGET_MIN: float = Field(default=7.0)
    RPE_TARGET_MAX: float = Field(default=8.5)
    PROGRESSION_INCREMENT_KG: float = Field(default=2.5)
    DELOAD_PERCENTAGE: float = Field(default=0.9)
    SUCCESS_RATE_THRESHOLD: float = Field(default=0.8)

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Create global settings instance
settings = Settings()




class AIConfig(BaseModel):
    """AI service configuration"""

    openai_api_key: str = settings.OPENAI_API_KEY
    model: str = settings.OPENAI_MODEL
    temperature: float = settings.OPENAI_TEMPERATURE
    max_tokens: int = settings.OPENAI_MAX_TOKENS
    system_prompt: str = settings.AI_COACH_SYSTEM_PROMPT

    @property
    def is_configured(self) -> bool:
        """Check if AI service is properly configured"""
        return bool(self.openai_api_key and self.openai_api_key != "")


class ExerciseConfig(BaseModel):
    """Exercise and progression configuration"""

    rpe_target_min: float = settings.RPE_TARGET_MIN
    rpe_target_max: float = settings.RPE_TARGET_MAX
    progression_increment: float = settings.PROGRESSION_INCREMENT_KG
    deload_percentage: float = settings.DELOAD_PERCENTAGE
    success_rate_threshold: float = settings.SUCCESS_RATE_THRESHOLD


# Create configuration instances
ai_config = AIConfig()
exercise_config = ExerciseConfig()
