from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from ..models.package import PackageTier, PackageStatus

class PackageBase(BaseModel):
    name: str
    tier: PackageTier
    price: float
    description: Optional[str] = None
    booking_limit: int = 0
    discount_percentage: float = 0.0
    priority_listing: bool = False
    featured_listing: bool = False
    vip_support: bool = False
    exclusive_packages: bool = False

class PackageCreate(PackageBase):
    pass

class PackageResponse(PackageBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

class UserPackageCreate(BaseModel):
    model_config = ConfigDict(extra='forbid')
    package_id: int
    payment_method: str
    card_number: Optional[str] = None
    expiry_date: Optional[str] = None
    cvv: Optional[str] = None

class UserPackageResponse(BaseModel):
    id: int
    user_id: int
    package_id: int
    package: PackageResponse
    status: PackageStatus
    start_date: datetime
    end_date: datetime
    created_at: datetime
    
    class Config:
        from_attributes = True
