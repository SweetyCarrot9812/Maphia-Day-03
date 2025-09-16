from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
import logging
from typing import Optional

from app.core.config import settings

logger = logging.getLogger(__name__)

class MongoDB:
    client: Optional[AsyncIOMotorClient] = None
    database = None

mongodb = MongoDB()

async def get_database():
    return mongodb.database

async def connect_to_mongo():
    """Create database connection"""
    try:
        mongodb.client = AsyncIOMotorClient(settings.MONGODB_URL)
        mongodb.database = mongodb.client[settings.DATABASE_NAME]

        # Test the connection
        await mongodb.client.admin.command('ping')
        logger.info("✅ Connected to MongoDB successfully")

    except Exception as e:
        logger.error(f"❌ Could not connect to MongoDB: {e}")
        raise

async def close_mongo_connection():
    """Close database connection"""
    if mongodb.client:
        mongodb.client.close()
        logger.info("👋 Disconnected from MongoDB")

async def init_db():
    """Initialize database with Beanie"""
    try:
        await connect_to_mongo()

        # Import all document models here
        from app.models.user import User
        from app.models.workout import Workout, Exercise, WorkoutSession

        # Initialize Beanie with document models
        await init_beanie(
            database=mongodb.database,
            document_models=[User, Workout, Exercise, WorkoutSession]
        )

        logger.info("✅ Database initialized with Beanie")

    except Exception as e:
        logger.error(f"❌ Database initialization failed: {e}")
        raise