"""Booking lifecycle: creation, pricing, availability, listing, cancellation.

Covers all four booking types (hotel, transport, guide, destination).
"""
from conftest import make_booking_payload, first_item


# ── Creation ───────────────────────────────────────────────────────────────

def test_create_requires_auth(client):
    hotel = first_item(client, "/api/v1/hotels")
    resp = client.post(
        "/api/v1/bookings",
        json=make_booking_payload("hotel", hotel["id"]),
    )
    assert resp.status_code == 401


def test_create_hotel_booking_computes_price(client, tourist_headers):
    hotel = first_item(client, "/api/v1/hotels")
    rooms_before = hotel["available_rooms"]

    resp = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload("hotel", hotel["id"], guests=2, nights=3),
    )
    assert resp.status_code in (200, 201), resp.text
    booking = resp.json()

    assert booking["status"] == "pending"
    assert booking["tourist_id"]  # set server-side from the token
    assert booking["item_name"] == hotel["name"]
    assert booking["guests"] == 2
    # price_per_night × 3 nights, computed server-side
    assert booking["total_price"] == pytest_approx(
        hotel["price_per_night"] * 3 * 0.8
    )

    # One room reserved
    hotel_after = client.get(f"/api/v1/hotels/{hotel['id']}").json()
    assert hotel_after["available_rooms"] == rooms_before - 1


def test_create_destination_booking(client, tourist_headers):
    dest = first_item(client, "/api/v1/destinations")
    resp = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload("destination", dest["id"], guests=4),
    )
    assert resp.status_code in (200, 201), resp.text
    booking = resp.json()
    assert booking["item_name"] == dest["name"]
    # Destination price is per person
    assert booking["total_price"] == pytest_approx(dest["price"] * 4 * 0.8)


def test_create_transport_booking_reserves_seats(client, tourist_headers):
    transport = first_item(client, "/api/v1/transports")
    seats_before = transport["available_seats"]

    resp = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload("transport", transport["id"], guests=2),
    )
    assert resp.status_code in (200, 201), resp.text
    booking = resp.json()
    assert booking["total_price"] == pytest_approx(transport["price"] * 2 * 0.8)

    after = client.get(f"/api/v1/transports/{transport['id']}").json()
    assert after["available_seats"] == seats_before - 2


def test_create_guide_booking(client, tourist_headers):
    guide = first_item(client, "/api/v1/guides")
    resp = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload("guide", guide["id"], nights=2),
    )
    assert resp.status_code in (200, 201), resp.text
    booking = resp.json()
    assert booking["item_name"] == guide["name"]
    assert booking["total_price"] == pytest_approx(guide["daily_rate"] * 2 * 0.8)


def test_create_unknown_item_404(client, tourist_headers):
    resp = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload("hotel", 999999),
    )
    assert resp.status_code == 404


def test_create_invalid_guests_rejected(client, tourist_headers):
    hotel = first_item(client, "/api/v1/hotels")
    payload = make_booking_payload("hotel", hotel["id"])
    payload["guests"] = 0
    resp = client.post("/api/v1/bookings", headers=tourist_headers, json=payload)
    assert resp.status_code in (400, 422)


def test_create_invalid_date_range_rejected(client, tourist_headers):
    hotel = first_item(client, "/api/v1/hotels")
    payload = make_booking_payload("hotel", hotel["id"])
    payload["check_in"] = (start := "2027-03-10T00:00:00")
    payload["check_out"] = start  # equal, not after
    resp = client.post("/api/v1/bookings", headers=tourist_headers, json=payload)
    assert resp.status_code in (400, 422)


def test_create_transport_more_seats_than_available(client, tourist_headers):
    transport = first_item(client, "/api/v1/transports")
    resp = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload(
            "transport", transport["id"],
            guests=transport["available_seats"] + 1,
        ),
    )
    assert resp.status_code == 400
    assert "seats" in resp.json()["detail"].lower()


def test_admin_cannot_create_bookings(client, admin_headers):
    hotel = first_item(client, "/api/v1/hotels")
    resp = client.post(
        "/api/v1/bookings",
        headers=admin_headers,
        json=make_booking_payload("hotel", hotel["id"]),
    )
    assert resp.status_code == 403


# ── Listing & ownership ────────────────────────────────────────────────────

def test_list_returns_only_own_bookings(client, tourist_headers, tourist2_headers):
    mine = client.get("/api/v1/bookings", headers=tourist_headers).json()
    theirs = client.get("/api/v1/bookings", headers=tourist2_headers).json()

    my_ids = {b["id"] for b in mine["items"]}
    their_ids = {b["id"] for b in theirs["items"]}
    assert my_ids and their_ids
    assert not my_ids & their_ids, "users must not see each other's bookings"
    assert all(b["tourist_name"] for b in mine["items"])


def test_detail_ownership(client, tourist_headers, tourist2_headers):
    theirs = client.get("/api/v1/bookings", headers=tourist2_headers).json()
    other_id = theirs["items"][0]["id"]

    # Owner can read
    resp = client.get(f"/api/v1/bookings/{other_id}", headers=tourist2_headers)
    assert resp.status_code == 200

    # Someone else gets 404 (no existence leak)
    resp = client.get(f"/api/v1/bookings/{other_id}", headers=tourist_headers)
    assert resp.status_code == 404

    # Anonymous gets 401
    assert client.get(f"/api/v1/bookings/{other_id}").status_code == 401


# ── Cancellation ───────────────────────────────────────────────────────────

def test_cancel_releases_room_and_blocks_double_cancel(
    client, tourist_headers
):
    hotel = first_item(client, "/api/v1/hotels")
    rooms_before = hotel["available_rooms"]

    created = client.post(
        "/api/v1/bookings",
        headers=tourist_headers,
        json=make_booking_payload("hotel", hotel["id"]),
    ).json()

    # Room is held
    assert (
        client.get(f"/api/v1/hotels/{hotel['id']}").json()["available_rooms"]
        == rooms_before - 1
    )

    resp = client.put(
        f"/api/v1/bookings/{created['id']}/cancel", headers=tourist_headers
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "cancelled"

    # Room released again
    assert (
        client.get(f"/api/v1/hotels/{hotel['id']}").json()["available_rooms"]
        == rooms_before
    )

    # Cancelling twice is rejected
    resp = client.put(
        f"/api/v1/bookings/{created['id']}/cancel", headers=tourist_headers
    )
    assert resp.status_code == 400


def test_cancel_someone_elses_booking_404(
    client, tourist_headers, tourist2_headers
):
    theirs = client.get("/api/v1/bookings", headers=tourist2_headers).json()
    other_id = theirs["items"][0]["id"]
    resp = client.put(
        f"/api/v1/bookings/{other_id}/cancel", headers=tourist_headers
    )
    assert resp.status_code == 404


# ── Status updates (staff flow) ────────────────────────────────────────────

def _create_pending_booking(client, headers, type_="hotel"):
    item = first_item(client, f"/api/v1/{type_}s")
    resp = client.post(
        "/api/v1/bookings",
        headers=headers,
        json=make_booking_payload(type_, item["id"]),
    )
    assert resp.status_code in (200, 201), resp.text
    return resp.json()


def test_tourist_cannot_update_status(client, tourist_headers):
    booking = _create_pending_booking(client, tourist_headers)
    resp = client.put(
        f"/api/v1/bookings/{booking['id']}/status",
        headers=tourist_headers,
        json={"status": "confirmed"},
    )
    assert resp.status_code == 403


def test_admin_can_update_status(client, admin_headers, tourist_headers):
    booking = _create_pending_booking(client, tourist_headers)
    resp = client.put(
        f"/api/v1/bookings/{booking['id']}/status",
        headers=admin_headers,
        json={"status": "confirmed"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "confirmed"

    fetched = client.get(
        f"/api/v1/bookings/{booking['id']}", headers=tourist_headers
    ).json()
    assert fetched["status"] == "confirmed"


def test_invalid_status_value_returns_validation_error(client, admin_headers, tourist_headers):
    booking = _create_pending_booking(client, tourist_headers)
    resp = client.put(
        f"/api/v1/bookings/{booking['id']}/status",
        headers=admin_headers,
        json={"status": "banana"},
    )
    assert resp.status_code == 422


def test_status_update_requires_auth(client, tourist_headers):
    booking = _create_pending_booking(client, tourist_headers)
    resp = client.put(
        f"/api/v1/bookings/{booking['id']}/status",
        json={"status": "confirmed"},
    )
    assert resp.status_code == 401


# ── Admin visibility ───────────────────────────────────────────────────────

def test_admin_sees_all_bookings(
    client, admin_headers, tourist_headers, tourist2_headers
):
    mine = client.get("/api/v1/bookings", headers=tourist_headers).json()
    theirs = client.get("/api/v1/bookings", headers=tourist2_headers).json()
    all_bookings = client.get("/api/v1/bookings", headers=admin_headers).json()

    assert all_bookings["total"] >= mine["total"] + theirs["total"] - 2
    admin_ids = {b["id"] for b in all_bookings["items"]}
    for b in mine["items"][:1] + theirs["items"][:1]:
        assert b["id"] in admin_ids


def test_admin_endpoints_require_admin(client, tourist_headers):
    # Anonymous → 401, regular user → 403
    assert client.get("/api/v1/admin/bookings").status_code == 401
    assert (
        client.get("/api/v1/admin/bookings", headers=tourist_headers).status_code
        == 403
    )


def test_basic_monthly_booking_limit(client, fresh_email):
    registered = client.post("/api/v1/auth/register", json={
        "email": fresh_email,
        "full_name": "Basic Plan Test",
        "password": "password123",
        "role": "tourist",
    })
    assert registered.status_code == 200, registered.text
    headers = {"Authorization": f"Bearer {registered.json()['access_token']}"}
    destination = first_item(client, "/api/v1/destinations")

    for _ in range(3):
        response = client.post(
            "/api/v1/bookings",
            headers=headers,
            json=make_booking_payload("destination", destination["id"]),
        )
        assert response.status_code == 200, response.text

    limited = client.post(
        "/api/v1/bookings",
        headers=headers,
        json=make_booking_payload("destination", destination["id"]),
    )
    assert limited.status_code == 403
    assert "limit" in limited.json()["detail"].lower()


def test_pro_package_discount_is_applied(client, fresh_email):
    registered = client.post("/api/v1/auth/register", json={
        "email": fresh_email,
        "full_name": "Discount Plan Test",
        "password": "password123",
        "role": "tourist",
    })
    assert registered.status_code == 200, registered.text
    headers = {"Authorization": f"Bearer {registered.json()['access_token']}"}
    packages = client.get("/api/v1/packages").json()["items"]
    pro = next(item for item in packages if item["tier"] == "pro")
    subscribed = client.post(
        "/api/v1/user-packages",
        headers=headers,
        json={
            "package_id": pro["id"],
            "payment_method": "card",
            "card_number": "4242424242424242",
            "expiry_date": "12/28",
            "cvv": "123",
        },
    )
    assert subscribed.status_code == 200, subscribed.text

    destination = first_item(client, "/api/v1/destinations")
    response = client.post(
        "/api/v1/bookings",
        headers=headers,
        json=make_booking_payload("destination", destination["id"], guests=2),
    )
    assert response.status_code == 200, response.text
    gross = destination["price"] * 2
    assert response.json()["total_price"] == pytest_approx(gross * 0.95)
    assert response.json()["discount_amount"] == pytest_approx(gross * 0.05)


def pytest_approx(value, rel=1e-6):
    """Local helper so assertions read naturally without importing pytest."""
    import pytest

    return pytest.approx(value, rel=rel)
