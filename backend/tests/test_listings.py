"""Listing management: hotels (managers), guides (owners), transports (admin).

These tests only ever create/delete their **own** records — seeded data is
left untouched so the rest of the suite stays deterministic.
"""
from conftest import first_item


HOTEL_PAYLOAD = {
    "name": "Test Inn",
    "description": "A hotel created by the listing tests.",
    "location": "Test Town",
    "division": "Dhaka",
    "address": "1 Test Road",
    "price_per_night": 2500,
    "amenities": ["WiFi"],
    "total_rooms": 5,
}

GUIDE_PAYLOAD = {
    "name": "Test Guide",
    "bio": "Created by tests",
    "languages": ["Bengali", "English"],
    "specialization": "City Tours",
    "daily_rate": 1200,
    "location": "Dhaka",
}

TRANSPORT_PAYLOAD = {
    "name": "Test Express",
    "type": "bus",
    "description": "Created by tests",
    "from_location": "Dhaka",
    "to_location": "Chittagong",
    "departure_time": "09:00 AM",
    "arrival_time": "03:00 PM",
    "price": 900,
    "total_seats": 30,
    "amenities": ["AC"],
    "operator_name": "Test Lines",
}


# ── Hotels ─────────────────────────────────────────────────────────────────

def test_hotel_create_requires_auth(client):
    assert client.post("/api/v1/hotels", json=HOTEL_PAYLOAD).status_code == 401


def test_hotel_create_forbidden_for_tourist(client, tourist_headers):
    resp = client.post("/api/v1/hotels", headers=tourist_headers, json=HOTEL_PAYLOAD)
    assert resp.status_code == 403


def test_manager_creates_own_hotel(client, manager_headers):
    payload = {**HOTEL_PAYLOAD, "name": "Manager Made Hotel"}
    resp = client.post("/api/v1/hotels", headers=manager_headers, json=payload)
    assert resp.status_code in (200, 201), resp.text
    hotel = resp.json()

    # Owns the listing and it starts fully bookable
    assert hotel["manager_id"] > 0
    assert hotel["available_rooms"] == hotel["total_rooms"]

    # Public list now includes it (approved by default)
    listing = client.get(f"/api/v1/hotels/{hotel['id']}")
    assert listing.status_code == 200
    assert listing.json()["name"] == "Manager Made Hotel"

    # Owner can update it
    resp = client.put(
        f"/api/v1/hotels/{hotel['id']}",
        headers=manager_headers,
        json={"price_per_night": 2750},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["price_per_night"] == 2750

    # And delete it again
    resp = client.delete(f"/api/v1/hotels/{hotel['id']}", headers=manager_headers)
    assert resp.status_code == 200
    assert client.get(f"/api/v1/hotels/{hotel['id']}").status_code == 404


def test_other_manager_cannot_edit_seeded_hotel(
    client, manager2_headers, manager_headers
):
    seeded = None
    # Find Rahman's seeded hotel (Hotel Sea Shell)
    items = client.get("/api/v1/hotels", params={"search": "sea shell"}).json()["items"]
    seeded = items[0] if items else None
    assert seeded is not None, "seeded hotel missing"

    # Karim (other manager) must not edit or delete it
    resp = client.put(
        f"/api/v1/hotels/{seeded['id']}",
        headers=manager2_headers,
        json={"price_per_night": 1},
    )
    assert resp.status_code == 403

    resp = client.delete(f"/api/v1/hotels/{seeded['id']}", headers=manager2_headers)
    assert resp.status_code == 403

    # But its owner can
    resp = client.put(
        f"/api/v1/hotels/{seeded['id']}",
        headers=manager_headers,
        json={"price_per_night": seeded["price_per_night"]},
    )
    assert resp.status_code == 200


def test_tourist_cannot_update_or_delete_hotel(client, tourist_headers):
    hotel = first_item(client, "/api/v1/hotels")
    assert (
        client.put(
            f"/api/v1/hotels/{hotel['id']}",
            headers=tourist_headers,
            json={"price_per_night": 1},
        ).status_code
        == 403
    )
    assert (
        client.delete(f"/api/v1/hotels/{hotel['id']}", headers=tourist_headers).status_code
        == 403
    )


def test_hotel_update_404(client, manager_headers):
    resp = client.put(
        "/api/v1/hotels/999999", headers=manager_headers, json={"price_per_night": 1}
    )
    assert resp.status_code == 404


# ── Guides ─────────────────────────────────────────────────────────────────

def test_guide_create_requires_auth(client):
    assert client.post("/api/v1/guides", json=GUIDE_PAYLOAD).status_code == 401


def test_guide_create_forbidden_for_tourist(client, tourist_headers):
    resp = client.post("/api/v1/guides", headers=tourist_headers, json=GUIDE_PAYLOAD)
    assert resp.status_code == 403


def test_guide_creates_and_edits_own_profile(client, guide_headers):
    payload = {**GUIDE_PAYLOAD, "name": "Guide Made Profile"}
    resp = client.post("/api/v1/guides", headers=guide_headers, json=payload)
    assert resp.status_code in (200, 201), resp.text
    guide = resp.json()
    assert guide["user_id"] > 0

    # Visible publicly
    assert client.get(f"/api/v1/guides/{guide['id']}").status_code == 200

    # Owner edits own profile
    resp = client.put(
        f"/api/v1/guides/{guide['id']}",
        headers=guide_headers,
        json={"daily_rate": 1500, "bio": "Updated by owner"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["daily_rate"] == 1500
    assert resp.json()["bio"] == "Updated by owner"


def test_other_guide_cannot_edit_profile(client, guide2_headers):
    # guide1's profile is off-limits to guide2
    items = client.get("/api/v1/guides", params={"search": "Guide Made"}).json()["items"]
    assert items, "guide-created profile missing"
    target = items[0]

    resp = client.put(
        f"/api/v1/guides/{target['id']}",
        headers=guide2_headers,
        json={"daily_rate": 1},
    )
    assert resp.status_code == 403


def test_guide_update_404(client, guide_headers):
    resp = client.put(
        "/api/v1/guides/999999", headers=guide_headers, json={"daily_rate": 1}
    )
    assert resp.status_code == 404


# ── Transports (admin-managed) ─────────────────────────────────────────────

def test_transport_create_requires_auth(client):
    assert client.post("/api/v1/transports", json=TRANSPORT_PAYLOAD).status_code == 401


def test_transport_create_forbidden_for_non_admin(client, tourist_headers):
    resp = client.post(
        "/api/v1/transports", headers=tourist_headers, json=TRANSPORT_PAYLOAD
    )
    assert resp.status_code == 403


def test_admin_creates_updates_transport(client, admin_headers):
    payload = {**TRANSPORT_PAYLOAD, "name": "Admin Made Express"}
    resp = client.post("/api/v1/transports", headers=admin_headers, json=payload)
    assert resp.status_code in (200, 201), resp.text
    transport = resp.json()

    # Seats available from the start
    assert transport["available_seats"] == transport["total_seats"]

    resp = client.put(
        f"/api/v1/transports/{transport['id']}",
        headers=admin_headers,
        json={"price": 950, "available_seats": 25},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["price"] == 950
    assert resp.json()["available_seats"] == 25


def test_transport_update_forbidden_for_non_admin(
    client, tourist_headers, admin_headers
):
    items = client.get("/api/v1/transports", params={"search": "Admin Made"}).json()["items"]
    assert items, "admin-created transport missing"
    target = items[0]

    resp = client.put(
        f"/api/v1/transports/{target['id']}",
        headers=tourist_headers,
        json={"price": 1},
    )
    assert resp.status_code == 403


def test_transport_update_404(client, admin_headers):
    resp = client.put(
        "/api/v1/transports/999999", headers=admin_headers, json={"price": 1}
    )
    assert resp.status_code == 404
