from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class TransportBase(BaseModel):
    name: str
    type: str  # bus, car, train, flight
    description: str
    from_location: str
    to_location: str
    departure_time: str
    arrival_time: Optional[str] = None
    price: float
    total_seats: int = 0
    amenities: List[str] = []
    operator_name: Optional[str] = None
    phone: Optional[str] = None

class TransportCreate(TransportBase):
    pass

class TransportUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    from_location: Optional[str] = None
    to_location: Optional[str] = None
    departure_time: Optional[str] = None
    arrival_time: Optional[str] = None
    price: Optional[float] = None
    total_seats: Optional[int] = None
    available_seats: Optional[int] = None
    amenities: Optional[List[str]] = None

class TransportResponse(TransportBase):
    id: int
    available_seats: int = 0
    is_approved: bool = True
    created_at: datetime
    
    class Config:
        from_attributes = True
