from sqlalchemy import Column, Integer, String, DateTime, Float, Boolean, Enum, ForeignKey
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from ..core.database import Base
import enum

class PackageTier(str, enum.Enum):
    basic = "basic"
    pro = "pro"
    premium = "premium"
    ultimate = "ultimate"

class PackageStatus(str, enum.Enum):
    active = "active"
    expired = "expired"
    cancelled = "cancelled"

class Package(Base):
    __tablename__ = "packages"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    tier = Column(Enum(PackageTier), nullable=False)
    price = Column(Float, nullable=False)
    description = Column(String)
    booking_limit = Column(Integer, default=0)  # -1 for unlimited
    discount_percentage = Column(Float, default=0.0)
    priority_listing = Column(Boolean, default=False)
    featured_listing = Column(Boolean, default=False)
    vip_support = Column(Boolean, default=False)
    exclusive_packages = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class UserPackage(Base):
    __tablename__ = "user_packages"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    package_id = Column(Integer, ForeignKey("packages.id"), nullable=False)
    status = Column(Enum(PackageStatus), default=PackageStatus.active)
    start_date = Column(DateTime(timezone=True), nullable=False)
    end_date = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="user_package")
    package = relationship("Package")
