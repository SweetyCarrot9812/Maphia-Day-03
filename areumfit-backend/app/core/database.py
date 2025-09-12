import motor.motor_asyncio
from beanie import init_beanie
import logging

from app.core.config import settings
from app.models.user import User
from app.models.exercise import Exercise
from app.models.session import Session
from app.models.set import Set

logger = logging.getLogger(__name__)


class Database:
    client: motor.motor_asyncio.AsyncIOMotorClient = None


db = Database()


async def get_database() -> motor.motor_asyncio.AsyncIOMotorDatabase:
    """Get database instance"""
    return db.client[settings.DATABASE_NAME]


async def init_db():
    """Initialize database connection and models"""
    try:
        # Create MongoDB client
        db.client = motor.motor_asyncio.AsyncIOMotorClient(settings.MONGODB_URL)

        # Test connection
        await db.client.admin.command("ping")
        logger.info(f"🔗 Connected to MongoDB: {settings.DATABASE_NAME}")

        # Initialize Beanie with document models
        await init_beanie(database=db.client[settings.DATABASE_NAME], document_models=[User, Exercise, Session, Set])

        logger.info("✅ Database models initialized")

    except Exception as e:
        logger.error(f"❌ Database connection failed: {e}")
        raise


async def close_db():
    """Close database connection"""
    if db.client:
        db.client.close()
        logger.info("👋 Database connection closed")
