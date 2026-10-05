from sqlalchemy import Column, Integer, String, DateTime, Float, JSON, Boolean
from sqlalchemy.sql import func
from ..core.database import Base

class Transport(Base):
    __tablename__ = "transports"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    type = Column(String, nullable=False)  # bus, car, train, flight
    description = Column(String, nullable=False)
    from_location = Column(String, nullable=False)
    to_location = Column(String, nullable=False)
    departure_time = Column(String, nullable=False)
    arrival_time = Column(String)
    price = Column(Float, nullable=False)
    total_seats = Column(Integer, default=0)
    available_seats = Column(Integer, default=0)
    amenities = Column(JSON, default=[])
    operator_name = Column(String)
    phone = Column(String)
    is_approved = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
