from pydantic import BaseModel, Field
from typing import Optional, List, Any
from datetime import datetime

class DestinationBase(BaseModel):
    name: str
    description: str
    location: str
    division: str
    price: float
    best_time_to_visit: Optional[str] = None
    activities: Optional[List[Any]] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_featured: bool = False

class DestinationCreate(DestinationBase):
    images: List[str] = []

class DestinationUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    location: Optional[str] = None
    division: Optional[str] = None
    price: Optional[float] = None
    images: Optional[List[str]] = None
    best_time_to_visit: Optional[str] = None
    activities: Optional[List[Any]] = None
    is_featured: Optional[bool] = None

class DestinationResponse(DestinationBase):
    id: int
    images: List[str] = []
    rating: float = 0.0
    review_count: int = 0
    created_at: datetime
    
    class Config:
        from_attributes = True

class ActivityResponse(BaseModel):
    imageUrl: str = Field(validation_alias="image_url")
    name: str
    type: str
    startTimes: List[str] = Field(validation_alias="start_times")
    rating: int
    price: float

    class Config:
        from_attributes = True
        populate_by_name = True