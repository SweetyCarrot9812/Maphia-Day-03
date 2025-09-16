from typing import Optional
from datetime import datetime, timedelta
from beanie import PydanticObjectId
from google.auth.transport import requests
from google.oauth2 import id_token
import httpx

from app.models.user import User, UserRole
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
)
from app.core.config import settings


class AuthService:
    @staticmethod
    async def authenticate_user(email: str, password: str) -> Optional[User]:
        """Authenticate user with email and password"""
        user = await User.find_one(User.email == email)

        if not user or user.is_oauth_user:
            return None

        if not verify_password(password, user.password_hash):
            return None

        # Update last login
        user.last_login_at = datetime.utcnow()
        await user.save()

        return user

    @staticmethod
    async def register_user(
        email: str,
        password: str,
        full_name: str,
        display_name: Optional[str] = None,
    ) -> User:
        """Register new user with email and password"""
        # Check if user already exists
        existing_user = await User.find_one(User.email == email)
        if existing_user:
            raise ValueError("User with this email already exists")

        # Create new user
        user = User(
            email=email,
            password_hash=get_password_hash(password),
            full_name=full_name,
            display_name=display_name or full_name,
            is_oauth_user=False,
            role=UserRole.SUPER_ADMIN if email == "tkandpf26@gmail.com" else UserRole.USER,
        )

        # Add super admin permissions
        if user.is_super_admin():
            user.permissions = ["user_management", "system_admin"]

        await user.save()
        return user

    @staticmethod
    async def authenticate_google_user(id_token_str: str) -> Optional[User]:
        """Authenticate user with Google ID token"""
        try:
            # Verify the token
            idinfo = id_token.verify_oauth2_token(
                id_token_str,
                requests.Request(),
                settings.GOOGLE_CLIENT_ID
            )

            # Token is valid, get user info
            email = idinfo["email"]
            google_id = idinfo["sub"]
            full_name = idinfo.get("name", email.split("@")[0])
            avatar_url = idinfo.get("picture")

            # Check if user exists
            user = await User.find_one(
                {"$or": [{"email": email}, {"google_id": google_id}]}
            )

            if user:
                # Update existing user
                user.google_id = google_id
                user.is_oauth_user = True
                if avatar_url:
                    user.avatar_url = avatar_url
                user.last_login_at = datetime.utcnow()
                await user.save()
            else:
                # Create new user
                user = User(
                    email=email,
                    full_name=full_name,
                    display_name=full_name,
                    google_id=google_id,
                    is_oauth_user=True,
                    avatar_url=avatar_url,
                    is_verified=True,  # Google users are pre-verified
                    email_verified_at=datetime.utcnow(),
                    role=UserRole.SUPER_ADMIN if email == "tkandpf26@gmail.com" else UserRole.USER,
                )

                # Add super admin permissions
                if user.is_super_admin():
                    user.permissions = ["user_management", "system_admin"]

                await user.save()

            return user

        except ValueError as e:
            # Invalid token
            print(f"Invalid Google ID token: {e}")
            return None

    @staticmethod
    async def get_user_by_id(user_id: str) -> Optional[User]:
        """Get user by ID"""
        try:
            return await User.get(user_id)
        except:
            return None

    @staticmethod
    async def get_user_by_email(email: str) -> Optional[User]:
        """Get user by email"""
        return await User.find_one(User.email == email)

    @staticmethod
    def create_tokens(user: User) -> dict:
        """Create access and refresh tokens for user"""
        access_token = create_access_token(subject=str(user.id))
        refresh_token = create_refresh_token(subject=str(user.id))

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }

    @staticmethod
    async def update_user_profile(user_id: str, profile_data: dict) -> Optional[User]:
        """Update user profile"""
        user = await User.get(user_id)
        if user:
            user.update_profile(profile_data)
            await user.save()
            return user
        return None

    @staticmethod
    async def change_password(
        user_id: str,
        current_password: str,
        new_password: str
    ) -> bool:
        """Change user password"""
        user = await User.get(user_id)

        if not user or user.is_oauth_user:
            return False

        if not verify_password(current_password, user.password_hash):
            return False

        user.password_hash = get_password_hash(new_password)
        user.updated_at = datetime.utcnow()
        await user.save()

        return True