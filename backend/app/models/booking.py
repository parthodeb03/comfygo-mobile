from sqlalchemy import Column, Integer, String, DateTime, Float, Enum, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base
import enum

class BookingStatus(str, enum.Enum):
    pending = "pending"
    confirmed = "confirmed"
    cancelled = "cancelled"
    completed = "completed"

class BookingType(str, enum.Enum):
    hotel = "hotel"
    transport = "transport"
    guide = "guide"
    destination = "destination"

class Booking(Base):
    __tablename__ = "bookings"
    
    id = Column(Integer, primary_key=True, index=True)
    tourist_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    tourist_name = Column(String)
    type = Column(Enum(BookingType), nullable=False)
    status = Column(Enum(BookingStatus), default=BookingStatus.pending)
    item_id = Column(Integer, nullable=False)
    item_name = Column(String)
    check_in = Column(DateTime(timezone=True), nullable=False)
    check_out = Column(DateTime(timezone=True))
    guests = Column(Integer, default=1)
    total_price = Column(Float, nullable=False)
    discount_amount = Column(Float, nullable=False, default=0)
    notes = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Relationships
    tourist = relationship("User", back_populates="bookings")
    payment = relationship("Payment", back_populates="booking", uselist=False)
