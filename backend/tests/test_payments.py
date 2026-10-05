"""Payment lifecycle: creation, ownership, statuses, admin confirmation."""
from conftest import make_booking_payload, first_item


def _make_booking(client, headers, type_="hotel"):
    item = first_item(client, f"/api/v1/{type_}s")
    resp = client.post(
        "/api/v1/bookings",
        headers=headers,
        json=make_booking_payload(type_, item["id"]),
    )
    assert resp.status_code in (200, 201), resp.text
    return resp.json()


CARD = {
    "method": "card",
    "card_number": "4242424242424242",
    "expiry_date": "12/28",
    "cvv": "123",
    "cardholder_name": "Ahmed Hassan",
}


# ── Creation ───────────────────────────────────────────────────────────────

def test_create_requires_auth(client):
    assert client.post("/api/v1/payments", json={}).status_code == 401


def test_card_payment_settles_and_confirms_booking(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": booking["id"],
            "amount": booking["total_price"],
            **CARD,
        },
    )
    assert resp.status_code in (200, 201), resp.text
    payment = resp.json()

    assert payment["status"] == "completed"
    assert payment["card_last_four"] == "4242"
    assert payment["transaction_id"]
    assert payment["user_id"] == booking["tourist_id"]

    # The booking flips pending → confirmed after a successful card payment
    fetched = client.get(
        f"/api/v1/bookings/{booking['id']}", headers=tourist_headers
    ).json()
    assert fetched["status"] == "confirmed"


def test_cash_payment_stays_pending(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": booking["id"],
            "amount": booking["total_price"],
            "method": "cash",
        },
    )
    assert resp.status_code in (200, 201), resp.text
    assert resp.json()["status"] == "pending"


def test_amount_mismatch_rejected(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": booking["id"],
            "amount": booking["total_price"] * 0.5,
            **CARD,
        },
    )
    assert resp.status_code == 400
    assert "amount" in resp.json()["detail"].lower()


def test_cannot_pay_someone_elses_booking(client, tourist_headers, tourist2_headers):
    their_booking = _make_booking(client, tourist2_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={
            "booking_id": their_booking["id"],
            "amount": their_booking["total_price"],
            **CARD,
        },
    )
    assert resp.status_code == 404


def test_unknown_booking_404(client, tourist_headers):
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={"booking_id": 999999, "amount": 100, **CARD},
    )
    assert resp.status_code == 404


def test_double_payment_rejected(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    payload = {"booking_id": booking["id"], "amount": booking["total_price"], **CARD}

    first = client.post("/api/v1/payments", headers=tourist_headers, json=payload)
    assert first.status_code in (200, 201)

    second = client.post("/api/v1/payments", headers=tourist_headers, json=payload)
    assert second.status_code == 400
    assert "paid" in second.json()["detail"].lower()


def test_negative_amount_rejected(client, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    resp = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "amount": -5, **CARD},
    )
    assert resp.status_code == 400


# ── Listing & ownership ────────────────────────────────────────────────────

def test_payment_list_is_scoped_to_owner(
    client, tourist_headers, tourist2_headers
):
    mine = client.get("/api/v1/payments", headers=tourist_headers).json()
    theirs = client.get("/api/v1/payments", headers=tourist2_headers).json()

    my_ids = {p["id"] for p in mine["items"]}
    their_ids = {p["id"] for p in theirs["items"]}
    assert my_ids and their_ids
    assert not my_ids & their_ids, "payments must be scoped to their owner"


def test_payment_detail_ownership(
    client, tourist_headers, tourist2_headers
):
    # Fatima owns seeded payment id 2 (cash)
    theirs = client.get("/api/v1/payments", headers=tourist2_headers).json()
    other_payment_id = theirs["items"][0]["id"]

    assert (
        client.get(
            f"/api/v1/payments/{other_payment_id}", headers=tourist2_headers
        ).status_code
        == 200
    )
    assert (
        client.get(
            f"/api/v1/payments/{other_payment_id}", headers=tourist_headers
        ).status_code
        == 404
    )
    assert (
        client.get(f"/api/v1/payments/{other_payment_id}").status_code == 401
    )


# ── Admin flows ────────────────────────────────────────────────────────────

def test_admin_sees_all_payments(client, admin_headers, tourist_headers):
    theirs = client.get("/api/v1/payments", headers=tourist_headers).json()
    everyone = client.get("/api/v1/payments", headers=admin_headers).json()
    assert everyone["total"] >= theirs["total"]


def test_admin_confirm_cash_payment(
    client, admin_headers, tourist_headers
):
    booking = _make_booking(client, tourist_headers)
    payment = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "amount": booking["total_price"], "method": "cash"},
    ).json()
    assert payment["status"] == "pending"

    # Non-admins may not confirm
    assert (
        client.put(
            f"/api/v1/payments/{payment['id']}/confirm", headers=tourist_headers
        ).status_code
        == 403
    )

    resp = client.put(
        f"/api/v1/payments/{payment['id']}/confirm", headers=admin_headers
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "completed"

    # Booking becomes confirmed once cash is collected
    fetched = client.get(
        f"/api/v1/bookings/{booking['id']}", headers=tourist_headers
    ).json()
    assert fetched["status"] == "confirmed"


def test_admin_refund(client, admin_headers, tourist_headers):
    booking = _make_booking(client, tourist_headers)
    payment = client.post(
        "/api/v1/payments",
        headers=tourist_headers,
        json={"booking_id": booking["id"], "amount": booking["total_price"], **CARD},
    ).json()

    # Non-admins may not refund
    assert (
        client.put(
            f"/api/v1/payments/{payment['id']}/refund",
            headers=tourist_headers,
            json={"reason": "nope"},
        ).status_code
        == 403
    )

    resp = client.put(
        f"/api/v1/payments/{payment['id']}/refund",
        headers=admin_headers,
        json={"reason": "customer request"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "refunded"


def test_confirm_and_refund_require_auth(client):
    assert client.put("/api/v1/payments/1/confirm").status_code == 401
    assert (
        client.put("/api/v1/payments/1/refund", json={}).status_code == 401
    )


def test_payment_404(client, tourist_headers):
    assert (
        client.get("/api/v1/payments/999999", headers=tourist_headers).status_code
        == 404
    )
