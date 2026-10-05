"""Subscription (user-package) flows: subscribe, current, upgrade, cancel."""
from conftest import first_item


def _package_by_tier(client, tier: str) -> dict:
    items = client.get("/api/v1/packages").json()["items"]
    for p in items:
        if p["tier"] == tier:
            return p
    raise AssertionError(f"no {tier} package seeded")


def test_subscribe_requires_auth(client):
    resp = client.post("/api/v1/user-packages", json={
        "package_id": 1, "payment_method": "card",
    })
    assert resp.status_code == 401


def test_current_requires_auth(client):
    assert client.get("/api/v1/user-packages/current").status_code == 401


def test_admin_cannot_use_user_packages(client, admin_headers):
    assert (
        client.get("/api/v1/user-packages/current", headers=admin_headers).status_code
        == 403
    )


def test_subscribe_free_plan_and_current(
    client, tourist_headers, tourist2_headers
):
    # Use the second tourist so ordering with other files stays independent
    basic = _package_by_tier(client, "basic")

    resp = client.post(
        "/api/v1/user-packages",
        headers=tourist2_headers,
        json={"package_id": basic["id"], "payment_method": "card"},
    )
    assert resp.status_code in (200, 201), resp.text
    sub = resp.json()
    assert sub["package"]["tier"] == "basic"
    assert sub["status"] == "active"

    # Reflects as the current package
    current = client.get(
        "/api/v1/user-packages/current", headers=tourist2_headers
    )
    assert current.status_code == 200
    assert current.json()["id"] == sub["id"]

    # Subscribing twice is rejected
    again = client.post(
        "/api/v1/user-packages",
        headers=tourist2_headers,
        json={"package_id": basic["id"], "payment_method": "card"},
    )
    assert again.status_code == 400

    # Clean up for later tests
    assert (
        client.put(
            "/api/v1/user-packages/cancel", headers=tourist2_headers
        ).status_code
        == 200
    )
    assert (
        client.get("/api/v1/user-packages/current", headers=tourist2_headers).status_code
        == 404
    )


def test_subscribe_paid_plan_requires_card_details(client, guide_headers):
    pro = _package_by_tier(client, "pro")

    resp = client.post(
        "/api/v1/user-packages",
        headers=guide_headers,
        json={"package_id": pro["id"], "payment_method": "card"},
    )
    assert resp.status_code == 400
    assert "card" in resp.json()["detail"].lower()

    resp = client.post(
        "/api/v1/user-packages",
        headers=guide_headers,
        json={"package_id": pro["id"], "payment_method": "bitcoin"},
    )
    assert resp.status_code == 400


def test_subscribe_unknown_package_404(client, guide_headers):
    resp = client.post(
        "/api/v1/user-packages",
        headers=guide_headers,
        json={"package_id": 999999, "payment_method": "card"},
    )
    assert resp.status_code == 404


def test_full_subscribe_upgrade_cancel_cycle(client, manager_headers):
    basic = _package_by_tier(client, "basic")
    premium = _package_by_tier(client, "premium")

    # Subscribe to a paid plan with card details
    resp = client.post(
        "/api/v1/user-packages",
        headers=manager_headers,
        json={
            "package_id": basic["id"],
            "payment_method": "card",
        },
    )
    assert resp.status_code in (200, 201), resp.text

    # Upgrade to premium (paid → needs card)
    resp = client.put(
        "/api/v1/user-packages/upgrade",
        headers=manager_headers,
        json={
            "package_id": premium["id"],
            "payment_method": "card",
            "card_number": "4242424242424242",
            "expiry_date": "12/28",
            "cvv": "123",
        },
    )
    assert resp.status_code == 200, resp.text
    upgraded = resp.json()
    assert upgraded["package"]["tier"] == "premium"
    assert upgraded["status"] == "active"

    # Upgrading to the same plan is rejected
    resp = client.put(
        "/api/v1/user-packages/upgrade",
        headers=manager_headers,
        json={
            "package_id": premium["id"],
            "payment_method": "card",
            "card_number": "4242424242424242",
        },
    )
    assert resp.status_code == 400

    # Cancel
    resp = client.put("/api/v1/user-packages/cancel", headers=manager_headers)
    assert resp.status_code == 200

    # Cancelling again → nothing active
    resp = client.put("/api/v1/user-packages/cancel", headers=manager_headers)
    assert resp.status_code == 404
    assert (
        client.get("/api/v1/user-packages/current", headers=manager_headers).status_code
        == 404
    )


def test_upgrade_without_active_package_404(client, guide2_headers):
    premium = _package_by_tier(client, "premium")
    resp = client.put(
        "/api/v1/user-packages/upgrade",
        headers=guide2_headers,
        json={
            "package_id": premium["id"],
            "payment_method": "card",
            "card_number": "4242424242424242",
        },
    )
    assert resp.status_code == 404
