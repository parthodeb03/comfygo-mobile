from sqlalchemy import Column, Integer, String, DateTime, Float, JSON, Boolean
from sqlalchemy.sql import func
from ..core.database import Base

class Destination(Base):
    __tablename__ = "destinations"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)
    location = Column(String, nullable=False)
    division = Column(String, nullable=False)
    images = Column(JSON, default=[])
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    price = Column(Float, nullable=False)
    best_time_to_visit = Column(String)
    activities = Column(JSON, default=[])
    latitude = Column(Float)
    longitude = Column(Float)
    is_featured = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
