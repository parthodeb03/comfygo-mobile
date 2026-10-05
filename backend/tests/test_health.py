"""Basic app health and metadata endpoints."""


def test_health(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json() == {"status": "healthy"}


def test_root(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert "message" in resp.json()


def test_openapi_schema(client):
    resp = client.get("/api/v1/openapi.json")
    assert resp.status_code == 200
    paths = resp.json()["paths"]
    # Every route the Flutter app calls must be documented
    for required in [
        "/api/v1/auth/login",
        "/api/v1/auth/register",
        "/api/v1/auth/profile",
        "/api/v1/bookings",
        "/api/v1/payments",
        "/api/v1/packages",
        "/api/v1/user-packages",
        "/api/v1/hotels",
        "/api/v1/guides",
        "/api/v1/transports",
        "/api/v1/destinations",
        "/api/v1/admin/stats",
    ]:
        assert required in paths, f"missing route {required}"
