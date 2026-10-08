from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import Optional
from datetime import datetime
from ..models.booking import BookingStatus, BookingType

class BookingBase(BaseModel):
    type: BookingType
    item_id: int
    check_in: datetime
    check_out: Optional[datetime] = None
    guests: int = Field(default=1, ge=1)
    notes: Optional[str] = None

    @model_validator(mode="after")
    def _check_dates(self):
        if self.check_out is not None:
            ci = self.check_in.replace(tzinfo=None) if self.check_in.tzinfo else self.check_in
            co = self.check_out.replace(tzinfo=None) if self.check_out.tzinfo else self.check_out
            if co <= ci:
                raise ValueError("check_out must be after check_in")
        return self

class BookingCreate(BookingBase):
    pass

class BookingUpdate(BaseModel):
    model_config = ConfigDict(extra='forbid')
    status: Optional[BookingStatus] = None
    check_out: Optional[datetime] = None
    notes: Optional[str] = None

class BookingResponse(BookingBase):
    id: int
    tourist_id: int
    tourist_name: str
    status: BookingStatus
    item_name: Optional[str] = None
    total_price: float
    discount_amount: float = 0
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
