from sqlalchemy import Column, Integer, String, DateTime, Enum, Float, JSON, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base
import enum

class UserRole(str, enum.Enum):
    tourist = "tourist"
    guide = "guide"
    hotel_manager = "hotel_manager"
    admin = "admin"

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=False)
    phone = Column(String)
    role = Column(Enum(UserRole), default=UserRole.tourist, nullable=False)
    hashed_password = Column(String, nullable=False)
    profile_image = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Tourist fields
    address = Column(String)
    nationality = Column(String)
    
    # Guide fields
    bio = Column(String)
    languages = Column(JSON)
    specialization = Column(String)
    experience = Column(Integer)
    daily_rate = Column(Float)
    
    # Hotel Manager fields
    hotel_id = Column(Integer, index=True)
    
    # Relationships
    bookings = relationship("Booking", back_populates="tourist")
    payments = relationship("Payment", back_populates="user")
    user_package = relationship("UserPackage", back_populates="user", uselist=False)

class Admin(Base):
    __tablename__ = "admins"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    full_name = Column(String, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
