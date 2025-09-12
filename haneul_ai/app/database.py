"""
Haneul AI Agent - Database Configuration
SQLAlchemy setup for task and user data management
"""

from sqlalchemy import create_engine, Column, Integer, String, Text, DateTime, Boolean, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.sql import func
from datetime import datetime
import os

from app.config.settings import get_settings

settings = get_settings()

# Database engine
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if "sqlite" in settings.database_url else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


# Database Models
class TaskModel(Base):
    """Task database model"""
    __tablename__ = "tasks"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(500), nullable=False, index=True)
    content = Column(Text, nullable=False)
    urgency = Column(Integer, nullable=False)  # 1-10
    importance = Column(Integer, nullable=False)  # 1-10
    priority_score = Column(Integer, nullable=False, index=True)  # urgency + importance
    status = Column(String(50), nullable=False, default="inbox", index=True)
    tags = Column(String(1000), default="")  # JSON string of tags
    estimated_time = Column(String(100))
    obsidian_file_path = Column(String(1000))
    ai_reasoning = Column(Text)
    created_at = Column(DateTime, default=func.now(), nullable=False)
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now(), nullable=False)


class UserSettingsModel(Base):
    """User settings database model"""
    __tablename__ = "user_settings"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(100), unique=True, nullable=False, default="default")
    email_enabled = Column(Boolean, default=True)
    email_address = Column(String(255), nullable=False)
    notification_time = Column(String(10), default="09:00")  # HH:MM format
    notification_frequency = Column(String(20), default="daily")
    priority_threshold = Column(Integer, default=5)
    include_calendar = Column(Boolean, default=True)
    obsidian_vault_path = Column(String(1000))
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())


class NotificationLogModel(Base):
    """Notification log for tracking sent notifications"""
    __tablename__ = "notification_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(100), nullable=False, default="default")
    notification_type = Column(String(50), nullable=False)  # email, calendar
    subject = Column(String(500))
    task_count = Column(Integer, default=0)
    sent_at = Column(DateTime, default=func.now())
    success = Column(Boolean, default=True)
    error_message = Column(Text)


class ActivityLogModel(Base):
    """Activity log for tracking user interactions"""
    __tablename__ = "activity_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(100), nullable=False, default="default")
    action = Column(String(100), nullable=False)  # created, updated, completed, etc.
    task_id = Column(Integer)
    details = Column(Text)
    timestamp = Column(DateTime, default=func.now())


# Database functions
def init_db():
    """Initialize database tables"""
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Database initialized successfully")
        
        # Create default user settings if not exists
        db = SessionLocal()
        try:
            existing_settings = db.query(UserSettingsModel).filter(
                UserSettingsModel.user_id == "default"
            ).first()
            
            if not existing_settings:
                default_settings = UserSettingsModel(
                    user_id="default",
                    email_address=settings.email_address,
                    obsidian_vault_path=settings.obsidian_vault_path
                )
                db.add(default_settings)
                db.commit()
                print("✅ Default user settings created")
                
        except Exception as e:
            print(f"⚠️ Warning: Could not create default settings: {e}")
            db.rollback()
        finally:
            db.close()
            
    except Exception as e:
        print(f"❌ Database initialization failed: {e}")
        raise


def get_db() -> Session:
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_db_direct() -> Session:
    """Get database session directly (not for FastAPI dependency)"""
    return SessionLocal()


# Database utility functions
def calculate_priority_score(urgency: int, importance: int) -> int:
    """Calculate priority score from urgency and importance"""
    return urgency + importance


def format_tags_for_db(tags: list) -> str:
    """Convert tag list to database string format"""
    import json
    return json.dumps(tags)


def parse_tags_from_db(tags_str: str) -> list:
    """Parse tags from database string format"""
    import json
    try:
        return json.loads(tags_str) if tags_str else []
    except json.JSONDecodeError:
        return []


# Health check function
def check_database_health() -> bool:
    """Check if database is accessible"""
    try:
        db = SessionLocal()
        # Simple query to check connection
        db.execute("SELECT 1")
        db.close()
        return True
    except Exception as e:
        print(f"Database health check failed: {e}")
        return False