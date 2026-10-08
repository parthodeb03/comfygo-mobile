"""Add favorites, reviews, contact messages, password resets + payment wallet fields.

Revision ID: 0002_wallet_favorites_reviews
Revises: 0001_initial_schema
"""
from alembic import op
import sqlalchemy as sa

from app.core.database import Base
import app.models  # noqa: F401  (registers all tables on Base.metadata)

revision = '0002_wallet_favorites_reviews'
down_revision = '0001_initial_schema'
branch_labels = None
depends_on = None


def _has_column(table: str, column: str) -> bool:
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    return column in {c["name"] for c in inspector.get_columns(table)}


def _has_table(table: str) -> bool:
    bind = op.get_bind()
    return table in sa.inspect(bind).get_table_names()


def upgrade():
    # New tables (favorites, reviews, contact_messages, password_resets).
    # create_all only creates *missing* tables, so existing ones stay untouched.
    Base.metadata.create_all(bind=op.get_bind())

    # Payments gained a wallet field for bKash / Nagad (skip when re-created fresh)
    if _has_table("payments") and not _has_column("payments", "wallet_number"):
        op.add_column("payments", sa.Column("wallet_number", sa.String(), nullable=True))

    # SQLite stores the enum as VARCHAR — widen it for the longer new values.
    # PostgreSQL keeps a native enum type, which needs ALTER TYPE instead.
    bind = op.get_bind()
    if bind.dialect.name == "postgresql":
        # Literal values only — PostgreSQL does not allow parameters in ALTER TYPE.
        for value in ("bkash", "nagad"):
            bind.execute(
                sa.text(f"ALTER TYPE paymentmethod ADD VALUE IF NOT EXISTS '{value}'")
            )
    elif bind.dialect.name == "sqlite":
        # No-op: SQLite does not enforce VARCHAR lengths.
        pass


def downgrade():
    if _has_table("payments") and _has_column("payments", "wallet_number"):
        op.drop_column("payments", "wallet_number")
    for table in ("password_resets", "contact_messages", "reviews", "favorites"):
        if _has_table(table):
            op.drop_table(table)
    # Note: enum values cannot be removed from a PostgreSQL enum type safely.
