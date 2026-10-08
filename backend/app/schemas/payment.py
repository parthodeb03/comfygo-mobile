from pydantic import BaseModel, ConfigDict, model_validator
from typing import Optional
from datetime import datetime
from ..models.payment import PaymentMethod, PaymentStatus

class PaymentBase(BaseModel):
    booking_id: int
    amount: float
    method: PaymentMethod

class PaymentCreate(PaymentBase):
    model_config = ConfigDict(extra="forbid")

    card_number: Optional[str] = None
    expiry_date: Optional[str] = None
    cvv: Optional[str] = None
    cardholder_name: Optional[str] = None
    wallet_number: Optional[str] = None  # bKash / Nagad wallet
    notes: Optional[str] = None

    @model_validator(mode="after")
    def restrict_card_to_sandbox(self):
        if self.method == PaymentMethod.card and self.card_number != "4242424242424242":
            raise ValueError("Sandbox card payments must use test card 4242 4242 4242 4242")
        if self.method in (PaymentMethod.bkash, PaymentMethod.nagad):
            digits = (self.wallet_number or "").strip()
            if not digits.isdigit() or len(digits) != 11 or not digits.startswith("01"):
                raise ValueError("Wallet number must be an 11-digit Bangladesh mobile number (01…)")
        return self

class PaymentResponse(PaymentBase):
    id: int
    user_id: int
    status: PaymentStatus
    transaction_id: Optional[str] = None
    card_last_four: Optional[str] = None
    wallet_number: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True

class RefundRequest(BaseModel):
    reason: Optional[str] = None

class VoidRequest(BaseModel):
    reason: Optional[str] = None
