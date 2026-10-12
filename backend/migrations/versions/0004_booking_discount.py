"""Add bookings.discount_amount used by package discounts.

The Booking model gained `discount_amount` and /api/v1/bookings selects it,
but no migration ever created the column, so every bookings query failed on
databases created before the model change (`no such column:
bookings.discount_amount`).
"""

import sqlalchemy as sa
from alembic import op

revision = "0004_booking_discount"
down_revision = "0003_destination_activities"
branch_labels = None
depends_on = None


def upgrade():
    bind = op.get_bind()
    columns = {c["name"] for c in sa.inspect(bind).get_columns("bookings")}
    if "discount_amount" not in columns:
        with op.batch_alter_table("bookings") as batch:
            batch.add_column(
                sa.Column(
                    "discount_amount",
                    sa.Float(),
                    nullable=False,
                    server_default="0",
                )
            )


def downgrade():
    bind = op.get_bind()
    columns = {c["name"] for c in sa.inspect(bind).get_columns("bookings")}
    if "discount_amount" in columns:
        with op.batch_alter_table("bookings") as batch:
            batch.drop_column("discount_amount")
