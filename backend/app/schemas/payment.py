from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from ..models.payment import PaymentMethod, PaymentStatus

class PaymentBase(BaseModel):
    booking_id: int
    amount: float
    method: PaymentMethod

class PaymentCreate(PaymentBase):
    card_number: Optional[str] = None
    expiry_date: Optional[str] = None
    cvv: Optional[str] = None
    cardholder_name: Optional[str] = None
    notes: Optional[str] = None

class PaymentResponse(PaymentBase):
    id: int
    user_id: int
    status: PaymentStatus
    transaction_id: Optional[str] = None
    card_last_four: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

class RefundRequest(BaseModel):
    reason: Optional[str] = None

class VoidRequest(BaseModel):
    reason: Optional[str] = None
