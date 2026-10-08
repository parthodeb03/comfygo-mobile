from sqlalchemy import Column, Integer, String, DateTime, Float, Enum, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base
import enum

class PaymentMethod(str, enum.Enum):
    card = "card"
    cash = "cash"
    bkash = "bkash"
    nagad = "nagad"

class PaymentStatus(str, enum.Enum):
    pending = "pending"
    completed = "completed"
    failed = "failed"
    refunded = "refunded"
    voided = "voided"

class Payment(Base):
    __tablename__ = "payments"
    
    id = Column(Integer, primary_key=True, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    amount = Column(Float, nullable=False)
    method = Column(Enum(PaymentMethod), nullable=False)
    status = Column(Enum(PaymentStatus), default=PaymentStatus.pending)
    transaction_id = Column(String)
    card_last_four = Column(String)
    wallet_number = Column(String)  # bKash / Nagad wallet phone number
    notes = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    booking = relationship("Booking", back_populates="payment")
    user = relationship("User", back_populates="payments")
