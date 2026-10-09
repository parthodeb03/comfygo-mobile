"""Store destination tours as structured activity rows."""

from alembic import op
from sqlalchemy.orm import Session

from app.core.database import Base
import app.models  # noqa: F401
from app.models import Activity, Destination

revision = "0003_destination_activities"
down_revision = "0002_wallet_favorites_reviews"
branch_labels = None
depends_on = None


def upgrade():
    Base.metadata.create_all(bind=op.get_bind())
    session = Session(bind=op.get_bind())
    try:
        destinations = session.query(Destination).all()
        for destination in destinations:
            if destination.tour_activities:
                continue
            for value in destination.activities or []:
                data = value if isinstance(value, dict) else {"name": str(value)}
                destination.tour_activities.append(
                    Activity(
                        image_url=data.get("imageUrl", data.get("image_url", "")),
                        name=data.get("name", ""),
                        type=data.get("type", "Sightseeing Tour"),
                        start_times=data.get(
                            "startTimes", data.get("start_times", [])
                        ),
                        rating=int(data.get("rating", 0)),
                        price=float(data.get("price", 0)),
                    )
                )
        session.commit()
    finally:
        session.close()


def downgrade():
    op.drop_table("activities")
