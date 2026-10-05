"""Pytest fixtures for the ComfyGo backend.

The suite runs against a **temporary SQLite database** that is seeded once per
session, so it never touches ``backend/comfygo.db`` (the dev database that the
live uvicorn server uses).
"""
import os
import pathlib
import sys
import tempfile
import uuid

import pytest

# ── Make `app` and `scripts` importable no matter where pytest is invoked ──
BACKEND_DIR = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BACKEND_DIR))
sys.path.insert(0, str(BACKEND_DIR / "scripts"))

# ── Point the app at an isolated database BEFORE any app import ────────────
_fd, _TEST_DB_PATH = tempfile.mkstemp(prefix="comfygo_test_", suffix=".db")
os.close(_fd)
# Forward slashes keep the SQLAlchemy URL valid on Windows
os.environ["DATABASE_URL"] = "sqlite:///" + _TEST_DB_PATH.replace("\\", "/")

from app.core.database import Base, engine, SessionLocal  # noqa: E402
from app.main import app  # noqa: E402
import seed as seed_script  # noqa: E402

Base.metadata.create_all(bind=engine)
seed_script.seed_database()


# ── Shared clients ─────────────────────────────────────────────────────────

@pytest.fixture(scope="session")
def client():
    from fastapi.testclient import TestClient

    with TestClient(app) as c:
        yield c


def _login(client, email: str, password: str) -> dict:
    """Log in and return ``{"Authorization": "Bearer …"}``."""
    resp = client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": password},
    )
    if resp.status_code == 200:
        token = resp.json()["access_token"]
        return {"Authorization": f"Bearer {token}"}

    # Admins log in through their own endpoint
    resp = client.post(
        "/api/v1/admin/login",
        json={"email": email, "password": password},
    )
    assert resp.status_code == 200, f"login failed for {email}: {resp.text}"
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture(scope="session")
def tourist_headers(client):
    """Ahmed — seeded tourist (owns seeded booking #1)."""
    return _login(client, "ahmed@email.com", "password123")


@pytest.fixture(scope="session")
def tourist2_headers(client):
    """Fatima — second seeded tourist (owns seeded booking #2)."""
    return _login(client, "fatima@email.com", "password123")


@pytest.fixture(scope="session")
def manager_headers(client):
    """Rahman — hotel manager who owns seeded hotel 'Hotel Sea Shell'."""
    return _login(client, "rahman@email.com", "password123")


@pytest.fixture(scope="session")
def manager2_headers(client):
    """Karim — second hotel manager (for ownership tests)."""
    return _login(client, "karim@email.com", "password123")


@pytest.fixture(scope="session")
def guide_headers(client):
    """Seeded guide account (role=guide)."""
    return _login(client, "guide1@email.com", "password123")


@pytest.fixture(scope="session")
def guide2_headers(client):
    return _login(client, "guide2@email.com", "password123")


@pytest.fixture(scope="session")
def admin_headers(client):
    return _login(client, "admin@comfygo.com", "admin123")


@pytest.fixture()
def db():
    """A direct DB session for assertions / test-only fixture rows."""
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture()
def fresh_email():
    return f"it-{uuid.uuid4().hex[:12]}@test.com"


# ── Payload helpers ────────────────────────────────────────────────────────

def make_booking_payload(
    type_: str,
    item_id: int,
    guests: int = 1,
    nights: int = 2,
    check_in_day: int = 30,
):
    """Deterministic booking payload with `nights` between check-in/out."""
    from datetime import datetime, timedelta

    check_in = datetime.utcnow() + timedelta(days=check_in_day)
    payload = {
        "type": type_,
        "item_id": item_id,
        "check_in": check_in.isoformat(),
        "guests": guests,
    }
    if type_ != "transport":
        payload["check_out"] = (check_in + timedelta(days=nights)).isoformat()
    return payload


def first_item(client, path: str, params: dict | None = None) -> dict:
    """First item of a paginated list endpoint (asserts it exists)."""
    resp = client.get(path, params=params or {})
    assert resp.status_code == 200, resp.text
    items = resp.json()["items"]
    assert items, f"expected data in {path}"
    return items[0]
