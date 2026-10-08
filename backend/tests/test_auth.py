"""Authentication: register, login, profile, refresh, admin login."""


# ── Register ───────────────────────────────────────────────────────────────

def test_register_success(client, fresh_email):
    resp = client.post("/api/v1/auth/register", json={
        "email": fresh_email,
        "password": "secret123",
        "full_name": "Integration Tester",
        "phone": "+8801700000000",
        "role": "tourist",
    })
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["access_token"]
    assert body["user"]["email"] == fresh_email
    assert body["user"]["role"] == "tourist"


def test_register_duplicate_email(client, fresh_email):
    payload = {
        "email": fresh_email,
        "password": "secret123",
        "full_name": "Twice",
        "role": "tourist",
    }
    assert client.post("/api/v1/auth/register", json=payload).status_code == 200
    resp = client.post("/api/v1/auth/register", json=payload)
    assert resp.status_code == 409
    assert "already" in resp.json()["detail"].lower()


def test_register_cannot_self_assign_admin(client, fresh_email):
    resp = client.post("/api/v1/auth/register", json={
        "email": fresh_email,
        "password": "secret123",
        "full_name": "Sneaky",
        "role": "admin",
    })
    assert resp.status_code == 400
    assert "admin" in resp.json()["detail"].lower()


def test_register_invalid_email(client, fresh_email):
    resp = client.post("/api/v1/auth/register", json={
        "email": "not-an-email",
        "password": "secret123",
        "full_name": "No Mail",
        "role": "tourist",
    })
    assert resp.status_code == 422


# ── Login ──────────────────────────────────────────────────────────────────

def test_login_success(client):
    resp = client.post("/api/v1/auth/login", json={
        "email": "ahmed@email.com",
        "password": "password123",
    })
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["access_token"]
    assert body["refresh_token"]
    assert body["user"]["email"] == "ahmed@email.com"


def test_login_wrong_password(client):
    resp = client.post("/api/v1/auth/login", json={
        "email": "ahmed@email.com",
        "password": "definitely-wrong",
    })
    assert resp.status_code == 401
    assert resp.json()["detail"]


def test_login_unknown_email(client):
    resp = client.post("/api/v1/auth/login", json={
        "email": "nobody@test.com",
        "password": "whatever",
    })
    assert resp.status_code == 401


# ── Profile ────────────────────────────────────────────────────────────────

def test_profile_requires_token(client):
    assert client.get("/api/v1/auth/profile").status_code == 401


def test_profile_with_token(client, tourist_headers):
    resp = client.get("/api/v1/auth/profile", headers=tourist_headers)
    assert resp.status_code == 200
    assert resp.json()["email"] == "ahmed@email.com"


def test_profile_rejects_garbage_token(client):
    resp = client.get(
        "/api/v1/auth/profile",
        headers={"Authorization": "Bearer not.a.jwt"},
    )
    assert resp.status_code == 401


def test_update_profile(client, tourist_headers):
    resp = client.put(
        "/api/v1/auth/profile",
        headers=tourist_headers,
        json={"phone": "+880 1711111111", "address": "Dhanmondi, Dhaka"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["phone"] == "+880 1711111111"

    # Persisted, not just echoed
    resp = client.get("/api/v1/auth/profile", headers=tourist_headers)
    assert resp.json()["address"] == "Dhanmondi, Dhaka"


def test_update_profile_ignores_unsafe_fields(client, tourist_headers):
    resp = client.put(
        "/api/v1/auth/profile",
        headers=tourist_headers,
        json={"role": "admin", "id": 9999},
    )
    assert resp.status_code == 422


# ── Refresh ────────────────────────────────────────────────────────────────

def test_refresh_issues_working_token(client):
    login = client.post("/api/v1/auth/login", json={
        "email": "fatima@email.com",
        "password": "password123",
    }).json()

    resp = client.post("/api/v1/auth/refresh", json={
        "refresh_token": login["refresh_token"],
    })
    assert resp.status_code == 200, resp.text
    new_token = resp.json()["access_token"]

    profile = client.get(
        "/api/v1/auth/profile",
        headers={"Authorization": f"Bearer {new_token}"},
    )
    assert profile.status_code == 200
    assert profile.json()["email"] == "fatima@email.com"


def test_refresh_invalid_token(client):
    resp = client.post("/api/v1/auth/refresh", json={"refresh_token": "junk"})
    assert resp.status_code == 401


def test_refresh_missing_token(client):
    resp = client.post("/api/v1/auth/refresh", json={})
    assert resp.status_code == 422


# ── Forgot password ────────────────────────────────────────────────────────

def test_forgot_password(client, fresh_email):
    resp = client.post("/api/v1/auth/forgot-password", json={"email": fresh_email})
    assert resp.status_code == 200
    assert "detail" in resp.json()


# ── Admin login ────────────────────────────────────────────────────────────

def test_admin_login(client):
    resp = client.post("/api/v1/admin/login", json={
        "email": "admin.test@example.com",
        "password": "test-admin-password",
    })
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["user"]["role"] == "admin"
    assert body["access_token"]


def test_admin_login_wrong_password(client):
    resp = client.post("/api/v1/admin/login", json={
        "email": "admin.test@example.com",
        "password": "wrong",
    })
    assert resp.status_code == 401


def test_admin_profile_with_admin_token(client, admin_headers):
    """Admin tokens must resolve to the *admin*, never to a same-id user."""
    resp = client.get("/api/v1/auth/profile", headers=admin_headers)
    assert resp.status_code == 200, resp.text
    body = resp.json()
    assert body["role"] == "admin"
    assert body["email"] == "admin.test@example.com"
