"""Admin endpoints: guards, stats, moderation, voiding."""
from datetime import datetime

from app.models.hotel import Hotel
from app.models.payment import Payment, PaymentMethod, PaymentStatus


ADMIN_GETS = [
    "/api/v1/admin/users",
    "/api/v1/admin/bookings",
    "/api/v1/admin/payments",
    "/api/v1/admin/listings",
    "/api/v1/admin/stats",
]


def test_admin_endpoints_require_token(client):
    for path in ADMIN_GETS:
        assert client.get(path).status_code == 401, path


def test_admin_endpoints_reject_normal_users(client, tourist_headers):
    for path in ADMIN_GETS:
        assert client.get(path, headers=tourist_headers).status_code == 403, path


def test_admin_writes_require_admin(client, tourist_headers):
    assert (
        client.put("/api/v1/admin/listings/1/approve", headers=tourist_headers).status_code
        == 403
    )
    assert (
        client.delete("/api/v1/admin/listings/1", headers=tourist_headers).status_code
        == 403
    )
    assert (
        client.put(
            "/api/v1/admin/payments/1/void", headers=tourist_headers, json={}
        ).status_code
        == 403
    )


def test_stats_shape(client, admin_headers):
    resp = client.get("/api/v1/admin/stats", headers=admin_headers)
    assert resp.status_code == 200, resp.text
    body = resp.json()
    for key in ("users", "bookings", "revenue", "active_packages"):
        assert key in body, f"stats missing {key}"
        assert isinstance(body[key], (int, float))

    # Users count matches the users listing
    users = client.get("/api/v1/admin/users", headers=admin_headers).json()
    assert body["users"] == users["total"]


def test_revenue_matches_completed_payments(client, admin_headers):
    stats = client.get("/api/v1/admin/stats", headers=admin_headers).json()
    payments = client.get(
        "/api/v1/admin/payments", headers=admin_headers, params={"limit": 100}
    ).json()["items"]
    expected = sum(p["amount"] for p in payments if p["status"] == "completed")
    assert stats["revenue"] == expected


def test_users_listing_and_filters(client, admin_headers):
    resp = client.get("/api/v1/admin/users", headers=admin_headers)
    assert resp.status_code == 200
    body = resp.json()
    emails = {u["email"] for u in body["items"]}
    assert "ahmed@email.com" in emails
    assert all("password" not in str(u).lower() for u in body["items"]), (
        "hashed passwords must never leak to the API"
    )

    # Search filter (matches name or email)
    resp = client.get(
        "/api/v1/admin/users", headers=admin_headers, params={"search": "ahmed"}
    )
    assert resp.status_code == 200
    assert resp.json()["items"]
    for u in resp.json()["items"]:
        haystack = f"{u['full_name']} {u['email']}".lower()
        assert "ahmed" in haystack

    # Role filter
    resp = client.get(
        "/api/v1/admin/users", headers=admin_headers, params={"role": "tourist"}
    )
    assert resp.status_code == 200
    for u in resp.json()["items"]:
        assert u["role"] == "tourist"


def test_bookings_listing_allows_filters(client, admin_headers):
    resp = client.get(
        "/api/v1/admin/bookings",
        headers=admin_headers,
        params={"status": "confirmed"},
    )
    assert resp.status_code == 200
    for b in resp.json()["items"]:
        assert b["status"] == "confirmed"


def test_listings_moderation_flow(client, admin_headers, db):
    """Unapproved hotel is hidden → approve shows it → delete removes it."""
    hotel = Hotel(
        name="Pending Inn",
        description="Awaiting approval",
        location="Nowhere",
        division="Dhaka",
        address="0 Pending Lane",
        price_per_night=1000,
        manager_id=1,
        available_rooms=3,
        total_rooms=3,
        is_approved=False,
    )
    db.add(hotel)
    db.commit()
    db.refresh(hotel)

    try:
        # Hidden from the public list while unapproved
        public = client.get("/api/v1/hotels", params={"search": "Pending Inn"}).json()
        assert all(h["id"] != hotel.id for h in public["items"])

        # Admin can list unapproved ones
        resp = client.get(
            "/api/v1/admin/listings",
            headers=admin_headers,
            params={"approved": False},
        )
        assert resp.status_code == 200
        assert any(h["id"] == hotel.id for h in resp.json()["items"])

        # Approve
        resp = client.put(
            f"/api/v1/admin/listings/{hotel.id}/approve", headers=admin_headers
        )
        assert resp.status_code == 200

        public = client.get("/api/v1/hotels", params={"search": "Pending Inn"}).json()
        assert any(h["id"] == hotel.id for h in public["items"])

        # Delete
        resp = client.delete(
            f"/api/v1/admin/listings/{hotel.id}", headers=admin_headers
        )
        assert resp.status_code == 200
        assert client.get(f"/api/v1/hotels/{hotel.id}").status_code == 404
    finally:
        db.rollback()


def test_listings_404(client, admin_headers):
    assert (
        client.put(
            "/api/v1/admin/listings/999999/approve", headers=admin_headers
        ).status_code
        == 404
    )
    assert (
        client.delete("/api/v1/admin/listings/999999", headers=admin_headers).status_code
        == 404
    )


def test_void_payment(client, admin_headers, tourist_headers, db):
    # Build a pending cash payment directly for a seeded booking
    payment = Payment(
        booking_id=1,
        user_id=1,
        amount=100.0,
        method=PaymentMethod.cash,
        status=PaymentStatus.pending,
        transaction_id="TEST-VOID-1",
    )
    db.add(payment)
    db.commit()
    db.refresh(payment)

    try:
        resp = client.put(
            f"/api/v1/admin/payments/{payment.id}/void",
            headers=admin_headers,
            json={"reason": "test void"},
        )
        assert resp.status_code == 200, resp.text
        body = resp.json()
        # Returns the updated payment, not just a detail string
        assert body["id"] == payment.id
        assert body["status"] == "refunded"
    finally:
        db.rollback()


def test_void_404(client, admin_headers):
    resp = client.put(
        "/api/v1/admin/payments/999999/void", headers=admin_headers, json={}
    )
    assert resp.status_code == 404
