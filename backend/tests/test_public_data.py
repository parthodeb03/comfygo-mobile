"""Public (unauthenticated) data endpoints used by the browsing UI."""

import pytest


# ── Destinations ───────────────────────────────────────────────────────────

def test_destinations_list(client):
    resp = client.get("/api/v1/destinations")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] >= 4
    for item in body["items"]:
        assert item["name"]
        assert item["price"] > 0
        assert item["id"] > 0
        assert isinstance(item["images"], list)


def test_destination_search(client):
    resp = client.get("/api/v1/destinations", params={"search": "cox"})
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert items, "search for 'cox' should match Cox's Bazar"
    assert any("cox" in i["name"].lower() for i in items)


def test_destination_division_filter(client):
    resp = client.get("/api/v1/destinations", params={"division": "Chittagong"})
    assert resp.status_code == 200
    for item in resp.json()["items"]:
        assert item["division"] == "Chittagong"


def test_featured_destinations(client):
    resp = client.get("/api/v1/destinations/featured")
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert items
    assert all(i["is_featured"] for i in items)


def test_destination_detail(client):
    dest = client.get("/api/v1/destinations").json()["items"][0]
    resp = client.get(f"/api/v1/destinations/{dest['id']}")
    assert resp.status_code == 200
    body = resp.json()
    assert body["name"] == dest["name"]
    assert body["description"]
    assert body["activities"]


def test_destination_detail_404(client):
    assert client.get("/api/v1/destinations/999999").status_code == 404


# ── Hotels ─────────────────────────────────────────────────────────────────

def test_hotels_list(client):
    resp = client.get("/api/v1/hotels")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] >= 2
    for item in body["items"]:
        assert item["name"]
        assert item["price_per_night"] > 0
        assert isinstance(item["images"], list)
        assert item["is_approved"] is True


def test_hotel_search_and_price_filters(client):
    resp = client.get("/api/v1/hotels", params={"search": "sea shell"})
    assert resp.status_code == 200
    assert resp.json()["items"]

    resp = client.get("/api/v1/hotels", params={"max_price": 4000})
    assert resp.status_code == 200
    for item in resp.json()["items"]:
        assert item["price_per_night"] <= 4000


def test_hotel_detail_and_404(client):
    hotel = client.get("/api/v1/hotels").json()["items"][0]
    assert client.get(f"/api/v1/hotels/{hotel['id']}").status_code == 200
    assert client.get("/api/v1/hotels/999999").status_code == 404


# ── Transports ─────────────────────────────────────────────────────────────

def test_transports_list(client):
    resp = client.get("/api/v1/transports")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] >= 2
    for item in body["items"]:
        assert item["name"]
        assert item["price"] > 0
        assert "available_seats" in item


def test_transport_type_filter(client):
    resp = client.get("/api/v1/transports", params={"type": "bus"})
    assert resp.status_code == 200
    for item in resp.json()["items"]:
        assert item["type"] == "bus"


def test_transport_detail_and_404(client):
    t = client.get("/api/v1/transports").json()["items"][0]
    assert client.get(f"/api/v1/transports/{t['id']}").status_code == 200
    assert client.get("/api/v1/transports/999999").status_code == 404


# ── Guides ─────────────────────────────────────────────────────────────────

def test_guides_list(client):
    resp = client.get("/api/v1/guides")
    assert resp.status_code == 200
    body = resp.json()
    assert body["total"] >= 2
    for item in body["items"]:
        assert item["name"]
        assert item["daily_rate"] > 0
        # Nullable so the UI can fall back to the local asset
        assert "profile_image" in item


def test_guide_detail_and_404(client):
    g = client.get("/api/v1/guides").json()["items"][0]
    assert client.get(f"/api/v1/guides/{g['id']}").status_code == 200
    assert client.get("/api/v1/guides/999999").status_code == 404


# ── Packages ───────────────────────────────────────────────────────────────

def test_packages_list_has_four_tiers(client):
    resp = client.get("/api/v1/packages")
    assert resp.status_code == 200
    items = resp.json()["items"]
    assert len(items) >= 4
    tiers = {i["tier"] for i in items}
    assert {"basic", "pro", "premium", "ultimate"} <= tiers
    for item in items:
        assert item["name"]
        assert item["price"] >= 0


def test_package_detail_and_404(client):
    pkg = client.get("/api/v1/packages").json()["items"][0]
    assert client.get(f"/api/v1/packages/{pkg['id']}").status_code == 200
    assert client.get("/api/v1/packages/999999").status_code == 404
