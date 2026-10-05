from sqlalchemy import Column, Integer, String, DateTime, Float, JSON, Boolean
from sqlalchemy.sql import func
from ..core.database import Base

class Hotel(Base):
    __tablename__ = "hotels"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)
    location = Column(String, nullable=False)
    division = Column(String, nullable=False)
    address = Column(String, nullable=False)
    images = Column(JSON, default=[])
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    price_per_night = Column(Float, nullable=False)
    manager_id = Column(Integer, nullable=False)
    amenities = Column(JSON, default=[])
    total_rooms = Column(Integer, default=0)
    available_rooms = Column(Integer, default=0)
    phone = Column(String)
    email = Column(String)
    is_approved = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
