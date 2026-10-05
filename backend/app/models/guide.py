from sqlalchemy import Column, Integer, String, DateTime, Float, JSON, Boolean
from sqlalchemy.sql import func
from ..core.database import Base

class Guide(Base):
    __tablename__ = "guides"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    name = Column(String, nullable=False)
    profile_image = Column(String)
    bio = Column(String)
    languages = Column(JSON, default=[])
    specialization = Column(String, nullable=False)
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    experience = Column(Integer, default=0)
    daily_rate = Column(Float, nullable=False)
    phone = Column(String)
    email = Column(String)
    location = Column(String)
    is_approved = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
