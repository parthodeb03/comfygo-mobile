"""ComfyGo backend smoke test - covers public data, auth, protected routes, images."""
import json
import os
import sys
from dotenv import load_dotenv

load_dotenv()
ADMIN_EMAIL = os.getenv('ADMIN_EMAIL')
ADMIN_PASSWORD = os.getenv('ADMIN_PASSWORD')
if not ADMIN_EMAIL or not ADMIN_PASSWORD:
    raise SystemExit('Set ADMIN_EMAIL and ADMIN_PASSWORD in backend/.env before running smoke tests.')
import urllib.request
import urllib.error

BASE = "http://localhost:8000/api/v1"
results = []


def req(method, path, body=None, token=None, timeout=10):
    url = BASE + path if path.startswith("/") else f"{BASE}/{path}"
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = json.dumps(body).encode() if body is not None else None
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(r, timeout=timeout) as resp:
            return resp.status, json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        try:
            payload = json.loads(e.read().decode())
        except Exception:
            payload = {}
        return e.code, payload
    except Exception as e:
        return 0, {"error": str(e)}


def check(name, cond, detail=""):
    results.append((name, bool(cond), detail))
    print(f"{'PASS' if cond else 'FAIL'}  {name}  {detail}")


# ---- health ----
import urllib.request as ur
with ur.urlopen("http://localhost:8000/health", timeout=5) as r:
    check("health endpoint", r.status == 200)

# ---- public list endpoints ----
counts = {}
for ep in ["destinations", "hotels", "transports", "guides", "packages"]:
    s, b = req("GET", f"/{ep}")
    items = b if isinstance(b, list) else (b.get("items") or b.get("data") or [] if isinstance(b, dict) else [])
    counts[ep] = len(items)
    check(f"GET /{ep}", s == 200 and len(items) > 0, f"status={s} count={len(items)}")

# ---- image reachability from returned data ----
image_urls = []
for ep in ["destinations", "hotels", "guides"]:
    s, b = req("GET", f"/{ep}")
    items = b if isinstance(b, list) else (b.get("items") or b.get("data") or [])
    for it in items:
        if isinstance(it, dict):
            for k, v in it.items():
                if isinstance(v, str) and ("image" in k.lower() or "photo" in k.lower() or "url" in k.lower() or "cover" in k.lower()):
                    if v.startswith("http"):
                        image_urls.append((f"{ep}.{k}", v))

ok_img, fail_img = 0, 0
for label, u in image_urls[:20]:
    try:
        rq = ur.Request(u, method="HEAD")
        with ur.urlopen(rq, timeout=8) as resp:
            if resp.status in (200, 206):
                ok_img += 1
            else:
                fail_img += 1
    except Exception:
        # try GET fallback
        try:
            with ur.urlopen(u, timeout=8) as resp:
                if resp.status == 200:
                    ok_img += 1
                else:
                    fail_img += 1
        except Exception:
            fail_img += 1
check("remote image URLs reachable", len(image_urls) == 0 or fail_img == 0,
      f"total={len(image_urls)} ok={ok_img} fail={fail_img}")

# image fields must exist in schema (may be empty; frontend falls back to assets)
s, b = req("GET", "/destinations")
items = b if isinstance(b, list) else (b.get("items") or [] if isinstance(b, dict) else [])
has_img_field = any(isinstance(it, dict) and "images" in it for it in items)
s2, b2 = req("GET", "/guides")
gitems = b2 if isinstance(b2, list) else (b2.get("items") or [] if isinstance(b2, dict) else [])
has_prof_field = any(isinstance(it, dict) and "profile_image" in it for it in gitems)
check("image fields in schemas", has_img_field and has_prof_field, f"destinations.images={has_img_field} guides.profile_image={has_prof_field}")

# ---- auth: admin login (admins authenticate via /admin/login) ----
s, b = req("POST", "/admin/login", {"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD})
admin_token = (b.get("access_token") or b.get("token") or (b.get("data") or {}).get("access_token")) if isinstance(b, dict) else None
check("admin login", s in (200, 201) and admin_token, f"status={s}")

# ---- auth: sample user login ----
s, b = req("POST", "/auth/login", {"email": "ahmed@email.com", "password": "password123"})
user_token = (b.get("access_token") or b.get("token") or (b.get("data") or {}).get("access_token")) if isinstance(b, dict) else None
check("user login", s in (200, 201) and user_token, f"status={s}")

# ---- wrong password rejected ----
s, b = req("POST", "/auth/login", {"email": ADMIN_EMAIL, "password": "wrongpass"})
check("wrong password rejected", s in (400, 401, 403), f"status={s}")

# ---- /auth/me ----
if admin_token:
    s, b = req("GET", "/auth/profile", token=admin_token)
    check("GET /auth/profile with token", s == 200, f"status={s} email={b.get('email') if isinstance(b, dict) else '?'}")

# ---- protected endpoints ----
if admin_token:
    s, b = req("GET", "/bookings", token=admin_token)
    check("GET /bookings (auth)", s == 200, f"status={s}")
    s, b = req("GET", "/payments", token=admin_token)
    check("GET /payments (auth)", s == 200, f"status={s}")
    s, b = req("GET", "/admin/stats", token=admin_token)
    check("GET /admin/stats (admin)", s == 200, f"status={s}")

# ---- unauthorized access blocked ----
s, b = req("GET", "/bookings")
check("GET /bookings without token blocked", s in (401, 403), f"status={s}")

# ---- detail endpoints ----
s, b = req("GET", "/destinations")
if isinstance(b, list) and b:
    did = b[0].get("id")
    if did:
        s2, b2 = req("GET", f"/destinations/{did}")
        check("GET /destinations/{id}", s2 == 200, f"status={s2}")

# ---- search/filter query params (used by frontend) ----
for q in ["?search=a", "?category=beach", "?page=1&page_size=5"]:
    s, b = req("GET", f"/destinations{q}")
    check(f"GET /destinations{q}", s == 200, f"status={s}")

# ---- summary ----
passed = sum(1 for _, ok, _ in results if ok)
total = len(results)
print("\n==== SUMMARY ====")
print(f"{passed}/{total} passed")
for name, ok, detail in results:
    if not ok:
        print(f"  FAILED: {name} {detail}")
sys.exit(0 if passed == total else 1)
