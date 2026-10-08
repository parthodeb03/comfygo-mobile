from pydantic import BaseModel, ConfigDict, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from ..models.user import UserRole

# Base schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone: Optional[str] = None
    role: UserRole = UserRole.tourist

# Create schemas
class UserCreate(UserBase):
    password: str
    address: Optional[str] = None
    nationality: Optional[str] = None
    bio: Optional[str] = None
    languages: Optional[List[str]] = None
    specialization: Optional[str] = None
    experience: Optional[int] = None
    daily_rate: Optional[float] = None

# Update schemas
class UserUpdate(BaseModel):
    model_config = ConfigDict(extra='forbid')
    full_name: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    nationality: Optional[str] = None
    bio: Optional[str] = None
    languages: Optional[List[str]] = None
    profile_image: Optional[str] = None
    specialization: Optional[str] = None
    experience: Optional[int] = Field(default=None, ge=0, le=80)
    daily_rate: Optional[float] = Field(default=None, ge=0)

# Response schemas
class UserResponse(UserBase):
    id: int
    profile_image: Optional[str] = None
    created_at: Optional[datetime] = None
    address: Optional[str] = None
    nationality: Optional[str] = None
    bio: Optional[str] = None
    languages: Optional[List[str]] = None
    rating: Optional[float] = None
    experience: Optional[int] = None
    hotel_id: Optional[int] = None
    
    class Config:
        from_attributes = True

# Auth schemas
class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class RegisterRequest(UserCreate):
    pass

class AuthResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse

class RefreshTokenRequest(BaseModel):
    model_config = ConfigDict(extra='forbid')
    refresh_token: str

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

class VerifyResetCodeRequest(BaseModel):
    email: EmailStr
    code: str = Field(min_length=6, max_length=6, pattern=r"\d{6}")

class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str

# Admin schemas
class AdminLoginRequest(BaseModel):
    email: EmailStr
    password: str

class AdminResponse(BaseModel):
    id: int
    email: str
    full_name: str
    
    class Config:
        from_attributes = True
