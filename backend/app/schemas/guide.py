from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class GuideBase(BaseModel):
    name: str
    bio: Optional[str] = None
    languages: List[str] = []
    specialization: str
    daily_rate: float
    phone: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None

class GuideCreate(GuideBase):
    # Only honored when an admin creates a profile on someone else's behalf
    user_id: Optional[int] = None

class GuideUpdate(BaseModel):
    bio: Optional[str] = None
    languages: Optional[List[str]] = None
    specialization: Optional[str] = None
    daily_rate: Optional[float] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    location: Optional[str] = None

class GuideResponse(GuideBase):
    id: int
    user_id: int
    profile_image: Optional[str] = None
    rating: float = 0.0
    review_count: int = 0
    experience: int = 0
    is_approved: bool = True
    created_at: datetime
    
    class Config:
        from_attributes = True
