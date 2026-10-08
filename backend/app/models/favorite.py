from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, UniqueConstraint
from sqlalchemy.sql import func
from ..core.database import Base


class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    item_type = Column(String, nullable=False)  # destination | hotel | guide | transport
    item_id = Column(Integer, nullable=False)
    # Denormalized snapshot so the favorites list can render without joins
    item_name = Column(String)
    item_image = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint("user_id", "item_type", "item_id", name="uq_favorite_user_item"),
    )
