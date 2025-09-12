"""
Haneul AI Agent - Application Settings
Configuration management using Pydantic Settings
"""

from pydantic_settings import BaseSettings
from pydantic import Field
from typing import Optional
import os
from functools import lru_cache


class Settings(BaseSettings):
    """Application configuration settings"""
    
    # AI APIs
    openai_api_key: str = Field(..., env="OPENAI_API_KEY")
    anthropic_api_key: Optional[str] = Field(None, env="ANTHROPIC_API_KEY")
    
    # Google APIs
    google_client_id: str = Field(..., env="GOOGLE_CLIENT_ID")
    google_client_secret: str = Field(..., env="GOOGLE_CLIENT_SECRET")
    
    # Obsidian Configuration
    obsidian_vault_path: str = Field(..., env="OBSIDIAN_VAULT_PATH")
    obsidian_inbox_folder: str = Field("00-Inbox", env="OBSIDIAN_INBOX_FOLDER")
    obsidian_todo_folder: str = Field("01-Todo", env="OBSIDIAN_TODO_FOLDER")
    obsidian_completed_folder: str = Field("02-Completed", env="OBSIDIAN_COMPLETED_FOLDER")
    
    # Email Configuration
    email_address: str = Field(..., env="EMAIL_ADDRESS")
    notification_time: str = Field("09:00", env="NOTIFICATION_TIME")
    notification_frequency: str = Field("daily", env="NOTIFICATION_FREQUENCY")
    
    # Database
    database_url: str = Field("sqlite:///./haneul_ai.db", env="DATABASE_URL")
    
    # Security
    secret_key: str = Field(..., env="SECRET_KEY")
    encryption_key: Optional[str] = Field(None, env="ENCRYPTION_KEY")
    
    # Application Settings
    debug: bool = Field(True, env="DEBUG")
    log_level: str = Field("INFO", env="LOG_LEVEL")
    priority_threshold: int = Field(5, env="PRIORITY_THRESHOLD")
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    """Get cached application settings"""
    return Settings()


# Global settings instance
settings = get_settings()