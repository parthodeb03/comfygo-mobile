from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey, UniqueConstraint, CheckConstraint
from sqlalchemy.sql import func
from ..core.database import Base


class Review(Base):
    __tablename__ = "reviews"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    booking_id = Column(Integer, ForeignKey("bookings.id"), nullable=False, index=True)
    item_type = Column(String, nullable=False)  # hotel | transport | guide | destination
    item_id = Column(Integer, nullable=False, index=True)
    rating = Column(Float, nullable=False)
    comment = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint("booking_id", name="uq_review_per_booking"),
        CheckConstraint("rating >= 1 AND rating <= 5", name="ck_review_rating_range"),
    )
