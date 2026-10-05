from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class HotelBase(BaseModel):
    name: str
    description: str
    location: str
    division: str
    address: str
    price_per_night: float
    amenities: List[str] = []
    total_rooms: int = 0
    phone: Optional[str] = None
    email: Optional[str] = None

class HotelCreate(HotelBase):
    images: List[str] = []

class HotelUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    address: Optional[str] = None
    price_per_night: Optional[float] = None
    images: Optional[List[str]] = None
    amenities: Optional[List[str]] = None
    total_rooms: Optional[int] = None
    available_rooms: Optional[int] = None
    phone: Optional[str] = None
    email: Optional[str] = None

class HotelResponse(HotelBase):
    id: int
    images: List[str] = []
    rating: float = 0.0
    review_count: int = 0
    manager_id: int
    manager_name: Optional[str] = None
    available_rooms: int = 0
    is_approved: bool = True
    created_at: datetime
    
    class Config:
        from_attributes = True
