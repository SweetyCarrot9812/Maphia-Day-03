from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer
from pydantic import BaseModel, EmailStr
from typing import Optional

from app.models.user import User
from app.services.auth_service import AuthService
from app.core.security import get_current_user_id


router = APIRouter()
security = HTTPBearer()


# Request/Response models
class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    display_name: Optional[str] = None


class GoogleAuthRequest(BaseModel):
    id_token: str


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str
    user: dict


class UserResponse(BaseModel):
    id: str
    email: str
    full_name: str
    display_name: Optional[str]
    avatar_url: Optional[str]
    role: str
    is_oauth_user: bool
    created_at: str


@router.post("/register", response_model=AuthResponse)
async def register(request: RegisterRequest):
    """Register new user with email and password"""
    try:
        user = await AuthService.register_user(
            email=request.email,
            password=request.password,
            full_name=request.full_name,
            display_name=request.display_name,
        )

        tokens = AuthService.create_tokens(user)

        return AuthResponse(
            access_token=tokens["access_token"],
            refresh_token=tokens["refresh_token"],
            token_type=tokens["token_type"],
            user=user.dict(exclude={"password_hash"})
        )

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Registration failed"
        )


@router.post("/login", response_model=AuthResponse)
async def login(request: LoginRequest):
    """Login with email and password"""
    user = await AuthService.authenticate_user(request.email, request.password)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled"
        )

    tokens = AuthService.create_tokens(user)

    return AuthResponse(
        access_token=tokens["access_token"],
        refresh_token=tokens["refresh_token"],
        token_type=tokens["token_type"],
        user=user.dict(exclude={"password_hash"})
    )


@router.post("/google", response_model=AuthResponse)
async def google_auth(request: GoogleAuthRequest):
    """Authenticate with Google ID token"""
    user = await AuthService.authenticate_google_user(request.id_token)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google ID token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled"
        )

    tokens = AuthService.create_tokens(user)

    return AuthResponse(
        access_token=tokens["access_token"],
        refresh_token=tokens["refresh_token"],
        token_type=tokens["token_type"],
        user=user.dict(exclude={"password_hash"})
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user(current_user_id: str = Depends(get_current_user_id)):
    """Get current user profile"""
    user = await AuthService.get_user_by_id(current_user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return UserResponse(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        display_name=user.display_name,
        avatar_url=user.avatar_url,
        role=user.role,
        is_oauth_user=user.is_oauth_user,
        created_at=user.created_at.isoformat()
    )


@router.put("/profile")
async def update_profile(
    profile_data: dict,
    current_user_id: str = Depends(get_current_user_id)
):
    """Update user profile"""
    user = await AuthService.update_user_profile(current_user_id, profile_data)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return {"message": "Profile updated successfully", "user": user.dict(exclude={"password_hash"})}


@router.post("/change-password")
async def change_password(
    request: ChangePasswordRequest,
    current_user_id: str = Depends(get_current_user_id)
):
    """Change user password"""
    success = await AuthService.change_password(
        current_user_id,
        request.current_password,
        request.new_password
    )

    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid current password or user not found"
        )

    return {"message": "Password changed successfully"}


@router.post("/logout")
async def logout(current_user_id: str = Depends(get_current_user_id)):
    """Logout user (client should remove tokens)"""
    return {"message": "Logout successful"}


@router.get("/verify-token")
async def verify_token(current_user_id: str = Depends(get_current_user_id)):
    """Verify if token is valid"""
    return {"valid": True, "user_id": current_user_id}