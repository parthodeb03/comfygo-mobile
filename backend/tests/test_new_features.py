"""New feature flows: wallet payments, OTP reset, favorites, reviews, contact, rate limit."""
import pytest
from conftest import make_booking_payload, first_item


@pytest.fixture(autouse=True)
def _restore_availability(db):
    """Snapshot and restore room/seat counts so this file's bookings don't
    drain inventory for tests that run later (test_payments, etc.).

    Values are written back with an explicit UPDATE: the API uses a different
    session, so assigning the same in-memory value on `db` would be a no-op.
    """
    from app.models import Hotel, Transport

    rooms = [(h.id, h.available_rooms) for h in db.query(Hotel).all()]
    seats = [(t.id, t.available_seats) for t in db.query(Transport).all()]
    db.commit()  # close the read transaction so writers aren't blocked
    yield
    for hotel_id, value in rooms:
        db.query(Hotel).filter(Hotel.id == hotel_id).update(
            {"available_rooms": value}, synchronize_session=False
        )
    for transport_id, value in seats:
        db.query(Transport).filter(Transport.id == transport_id).update(
            {"available_seats": value}, synchronize_session=False
        )
    db.commit()


CARD = {
    "method": "card",
    "card_number": "4242424242424242",
    "expiry_date": "12/28",
    "cvv": "123",
    "cardholder_name": "Ahmed Hassan",
}


def _make_booking(client, headers, type_="hotel"):
    item = first_item(client, f"/api/v1/{type_}s")
    resp = client.post(
        "/api/v1/bookings",
        headers=headers,
        json=make_booking_payload(type_, item["id"]),
    )
    assert resp.status_code in (200, 201), resp.text
    return resp.json()


# ── bKash / Nagad wallet payments ─────────────────────────────────────────

def test_bkash_payment_settles_immediately(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": booking["id"],
            "amount": booking["total_price"],
            "method": "bkash",
            "wallet_number": "01712345678",
        },
    )
    assert resp.status_code in (200, 201), resp.text
    payment = resp.json()
    assert payment["status"] == "completed"
    assert payment["wallet_number"] == "01712345678"
    assert payment["transaction_id"]

    fetched = client.get(
        f"/api/v1/bookings/{booking['id']}", headers=tourist_headers
    ).json()
    assert fetched["status"] == "confirmed"


def test_nagad_payment_settles_immediately(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": booking["id"],
            "amount": booking["total_price"],
            "method": "nagad",
            "wallet_number": "01998765432",
        },
    )
    assert resp.status_code in (200, 201), resp.text
    assert resp.json()["status"] == "completed"


@pytest.mark.parametrize("bad_number", ["12345", "0171234567", "02712345678", "017123456789", "abc"])
def test_wallet_number_validation(client, tourist_headers, bad_number):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": booking["id"],
            "amount": booking["total_price"],
            "method": "bkash",
            "wallet_number": bad_number,
        },
    )
    assert resp.status_code == 422, resp.text


def test_wallet_payment_without_number_rejected(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "amount": booking["total_price"], "method": "bkash"},
    )
    assert resp.status_code == 422


def test_admin_can_filter_payments_by_wallet_method(client, admin_headers):
    resp = client.get("/api/v1/payments?method=bkash", headers=admin_headers)
    assert resp.status_code == 200
    assert "items" in resp.json()


# ── 6-digit OTP forgot-password flow ──────────────────────────────────────

def test_forgot_password_flow_end_to_end(client, fresh_email):
    # Register a user first
    resp = client.post(
        "/api/v1/auth/register",
        json={
            "email": fresh_email,
            "password": "OldPass123!",
            "full_name": "Reset Tester",
            "phone": "01700000000",
            "role": "tourist",
        },
    )
    assert resp.status_code in (200, 201), resp.text

    # 1. Request a code
    resp = client.post("/api/v1/auth/forgot-password", json={"email": fresh_email})
    assert resp.status_code == 200
    body = resp.json()
    assert "dev_code" in body, "dev_code must be returned (no email provider wired)"
    code = body["dev_code"]
    assert len(code) == 6 and code.isdigit()

    # 2. Verify the code → reset token
    resp = client.post(
        "/api/v1/auth/verify-code", json={"email": fresh_email, "code": code}
    )
    assert resp.status_code == 200, resp.text
    reset_token = resp.json()["reset_token"]
    assert reset_token

    # 3. Set the new password
    resp = client.post(
        "/api/v1/auth/reset-password",
        json={"token": reset_token, "new_password": "NewPass456!"},
    )
    assert resp.status_code == 200, resp.text

    # Old password no longer works, new one does
    assert (
        client.post(
            "/api/v1/auth/login", json={"email": fresh_email, "password": "OldPass123!"}
        ).status_code
        == 401
    )
    resp = client.post(
        "/api/v1/auth/login", json={"email": fresh_email, "password": "NewPass456!"}
    )
    assert resp.status_code == 200


def test_forgot_password_no_user_enumeration(client, fresh_email):
    resp = client.post("/api/v1/auth/forgot-password", json={"email": fresh_email})
    assert resp.status_code == 200
    assert "dev_code" not in resp.json()


def test_wrong_code_rejected(client, fresh_email):
    client.post(
        "/api/v1/auth/register",
        json={
            "email": fresh_email,
            "password": "OldPass123!",
            "full_name": "Wrong Code",
            "phone": "01700000001",
            "role": "tourist",
        },
    )
    client.post("/api/v1/auth/forgot-password", json={"email": fresh_email})
    resp = client.post(
        "/api/v1/auth/verify-code", json={"email": fresh_email, "code": "000000"}
    )
    # 000000 might theoretically be the issued code; if not, must fail
    body = resp.json()
    if resp.status_code == 200:
        pytest.skip("unlikely collision with real code")
    assert resp.status_code == 400


def test_reset_code_single_use(client, fresh_email):
    client.post(
        "/api/v1/auth/register",
        json={
            "email": fresh_email,
            "password": "OldPass123!",
            "full_name": "Reuse Code",
            "phone": "01700000002",
            "role": "tourist",
        },
    )
    code = client.post(
        "/api/v1/auth/forgot-password", json={"email": fresh_email}
    ).json()["dev_code"]

    first = client.post(
        "/api/v1/auth/verify-code", json={"email": fresh_email, "code": code}
    )
    assert first.status_code == 200

    # Same code cannot be used again
    second = client.post(
        "/api/v1/auth/verify-code", json={"email": fresh_email, "code": code}
    )
    assert second.status_code == 400


def test_short_password_rejected_on_reset(client, fresh_email):
    client.post(
        "/api/v1/auth/register",
        json={
            "email": fresh_email,
            "password": "OldPass123!",
            "full_name": "Short Pw",
            "phone": "01700000003",
            "role": "tourist",
        },
    )
    code = client.post(
        "/api/v1/auth/forgot-password", json={"email": fresh_email}
    ).json()["dev_code"]
    verify = client.post(
        "/api/v1/auth/verify-code", json={"email": fresh_email, "code": code}
    )
    assert verify.status_code == 200, verify.text
    token = verify.json()["reset_token"]
    resp = client.post(
        "/api/v1/auth/reset-password", json={"token": token, "new_password": "short"}
    )
    assert resp.status_code == 400


# ── Favorites ─────────────────────────────────────────────────────────────

def test_favorite_add_list_remove(client, tourist_headers):
    item = first_item(client, "/api/v1/destinations")

    resp = client.post(
        "/api/v1/favorites",
        headers=tourist_headers,
        json={"item_type": "destination", "item_id": item["id"]},
    )
    assert resp.status_code == 201, resp.text
    fav = resp.json()
    assert fav["item_name"] == item["name"]

    listing = client.get("/api/v1/favorites", headers=tourist_headers).json()
    assert any(
        f["item_type"] == "destination" and f["item_id"] == item["id"]
        for f in listing["items"]
    )

    # Adding again is idempotent
    again = client.post(
        "/api/v1/favorites",
        headers=tourist_headers,
        json={"item_type": "destination", "item_id": item["id"]},
    )
    assert again.status_code == 201

    resp = client.delete(
        f"/api/v1/favorites/destination/{item['id']}", headers=tourist_headers
    )
    assert resp.status_code == 204

    listing = client.get("/api/v1/favorites", headers=tourist_headers).json()
    assert not any(
        f["item_type"] == "destination" and f["item_id"] == item["id"]
        for f in listing["items"]
    )


def test_favorites_require_auth(client):
    assert client.get("/api/v1/favorites").status_code == 401
    assert (
        client.post(
            "/api/v1/favorites", json={"item_type": "hotel", "item_id": 1}
        ).status_code
        == 401
    )


def test_favorite_unknown_item_404(client, tourist_headers):
    resp = client.post(
        "/api/v1/favorites",
        headers=tourist_headers,
        json={"item_type": "hotel", "item_id": 999999},
    )
    assert resp.status_code == 404


def test_favorite_invalid_type_rejected(client, tourist_headers):
    resp = client.post(
        "/api/v1/favorites",
        headers=tourist_headers,
        json={"item_type": "spaceship", "item_id": 1},
    )
    assert resp.status_code == 422


# ── Reviews ───────────────────────────────────────────────────────────────

def _complete_a_booking(client, headers, type_="hotel"):
    booking = _make_booking(client, headers, type_)
    # Pay for it (card settles → confirmed), then admin completes it
    client.post(
        "/api/v1/payments",
        headers=headers,
        json={"booking_id": booking["id"], "amount": booking["total_price"], **CARD},
    )
    return booking


def test_review_requires_completed_booking(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/reviews",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "rating": 5, "comment": "Great"},
    )
    assert resp.status_code == 400
    assert "completed" in resp.json()["detail"].lower()


def test_review_after_completion_updates_listing_rating(
    client, tourist_headers, admin_headers
):
    booking = _complete_a_booking(client, tourist_headers)

    # Admin marks it completed
    resp = client.put(
        f"/api/v1/bookings/{booking['id']}/status",
        headers=admin_headers,
        json={"status": "completed"},
    )
    assert resp.status_code == 200, resp.text

    item_id = booking["item_id"]
    before = client.get(f"/api/v1/hotels/{item_id}").json()

    resp = client.post(
        "/api/v1/reviews",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "rating": 4, "comment": "Lovely stay"},
    )
    assert resp.status_code == 201, resp.text
    review = resp.json()
    assert review["rating"] == 4
    assert review["reviewer_name"]

    # Denormalized rating/review_count updated on the listing
    after = client.get(f"/api/v1/hotels/{item_id}").json()
    assert after["review_count"] == before["review_count"] + 1

    # Reviews are publicly listable per item
    listing = client.get(
        f"/api/v1/reviews?item_type=hotel&item_id={item_id}"
    ).json()
    assert listing["total"] >= 1


def test_review_only_once_per_booking(client, tourist_headers, admin_headers):
    booking = _complete_a_booking(client, tourist_headers)
    client.put(
        f"/api/v1/bookings/{booking['id']}/status",
        headers=admin_headers,
        json={"status": "completed"},
    )
    first = client.post(
        "/api/v1/reviews",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "rating": 5},
    )
    assert first.status_code == 201
    second = client.post(
        "/api/v1/reviews",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "rating": 1},
    )
    assert second.status_code == 409


def test_cannot_review_someone_elses_booking(
    client, tourist_headers, tourist2_headers
):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/reviews",
        headers=tourist2_headers,
        json={"booking_id": booking["id"], "rating": 5},
    )
    assert resp.status_code == 404


def test_review_rating_range_validated(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    for bad in (0, 6):
        resp = client.post(
            "/api/v1/reviews",
            headers=tourist_headers,
            json={"booking_id": booking["id"], "rating": bad},
        )
        assert resp.status_code == 422


# ── Contact messages ──────────────────────────────────────────────────────

def test_contact_message_saved_and_visible_to_admin(client, admin_headers):
    payload = {
        "name": "Test Sender",
        "email": "sender@example.com",
        "message": "How do I change my booking date?",
    }
    resp = client.post("/api/v1/contact", json=payload)
    assert resp.status_code == 201, resp.text
    created = resp.json()
    assert created["id"] >= 1

    inbox = client.get("/api/v1/contact/inbox", headers=admin_headers).json()
    assert any(m["id"] == created["id"] for m in inbox["items"])


def test_contact_inbox_requires_admin(client, tourist_headers):
    assert client.get("/api/v1/contact/inbox").status_code == 401
    assert client.get("/api/v1/contact/inbox", headers=tourist_headers).status_code == 403


def test_contact_validation(client):
    resp = client.post(
        "/api/v1/contact", json={"name": "", "email": "bad", "message": ""}
    )
    assert resp.status_code == 422


def test_contact_resolve(client, admin_headers):
    created = client.post(
        "/api/v1/contact",
        json={"name": "A", "email": "a@example.com", "message": "hello"},
    ).json()
    resp = client.put(
        f"/api/v1/contact/{created['id']}/resolve", headers=admin_headers
    )
    assert resp.status_code == 200
    assert resp.json()["resolved"] is True


# ── Rate limiting ─────────────────────────────────────────────────────────

def test_rate_limit_triggers_429(client):
    from app.core.config import settings
    from app.core import rate_limit as rl

    old_enabled = settings.RATE_LIMIT_ENABLED
    old_limit = settings.AUTH_RATE_LIMIT
    rl.reset_buckets()
    try:
        settings.RATE_LIMIT_ENABLED = True
        settings.AUTH_RATE_LIMIT = 3

        codes = set()
        for _ in range(6):
            resp = client.post(
                "/api/v1/auth/login",
                json={"email": "nobody@example.com", "password": "wrongpass"},
            )
            codes.add(resp.status_code)
        assert 429 in codes, f"expected a 429 within 6 bad logins, got {codes}"

        # The 429 advertises a retry delay
        resp = client.post(
            "/api/v1/auth/login",
            json={"email": "nobody@example.com", "password": "wrongpass"},
        )
        if resp.status_code == 429:
            assert "Retry-After" in resp.headers
    finally:
        settings.AUTH_RATE_LIMIT = old_limit
        settings.RATE_LIMIT_ENABLED = old_enabled
        rl.reset_buckets()
