from sqlalchemy import Column, Float, ForeignKey, Integer, JSON, String
from sqlalchemy.orm import relationship

from ..core.database import Base


class Activity(Base):
    __tablename__ = "activities"

    id = Column(Integer, primary_key=True, index=True)
    destination_id = Column(
        Integer,
        ForeignKey("destinations.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    image_url = Column(String, nullable=False, default="")
    name = Column(String, nullable=False)
    type = Column(String, nullable=False, default="Sightseeing Tour")
    start_times = Column(JSON, nullable=False, default=list)
    rating = Column(Integer, nullable=False, default=0)
    price = Column(Float, nullable=False, default=0)

    destination = relationship("Destination", back_populates="tour_activities")
