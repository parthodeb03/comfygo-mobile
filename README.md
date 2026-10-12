# ComfyGo

ComfyGo is a Flutter travel booking app with a FastAPI and PostgreSQL backend. The mobile screens follow the cream, charcoal, sage, and lime reference in photos/img.png. Flutter state management uses Riverpod.

## Features

- Tourist, Guide, and Hotel Manager accounts; hidden Admin login
- Destination, hotel, transport, and guide discovery and details
- Bookings, payment records, package subscriptions, and admin management
- Secure token storage, cached photos, and loading/error states

## Backend setup

Requires Python 3.11+, PostgreSQL, and Android Studio/Flutter.

    cd backend
    python -m venv .venv
    .\.venv\Scripts\Activate.ps1
    pip install -r requirements.txt
    Copy-Item .env.example .env
    python -c "import secrets; print(secrets.token_urlsafe(48))"

Paste the generated value into SECRET_KEY in backend/.env, replace the PostgreSQL DATABASE_URL placeholder with your database credentials, then set ADMIN_EMAIL and a strong ADMIN_PASSWORD. The seed script stores only a bcrypt hash; there is no built-in admin credential. Keep .env private.

Create the comfygo PostgreSQL database, then from backend/ run:

    alembic upgrade head
    python scripts/seed.py
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

API docs are at http://localhost:8000/docs. The admin login is opened by tapping the ComfyGo logo five times on the login screen.

The seed includes a sample tourist (ahmed@email.com / password123) and other role accounts. Change sample passwords before any shared deployment. Seed destination and listing photo URLs come from Unsplash; review each source and its current license terms before release.

## Android app

From the repository root:

    flutter pub get
    flutter run

The app defaults to http://localhost:8000, which reaches the host from a USB-connected phone through `adb reverse tcp:8000 tcp:8000`. The Android emulator needs http://10.0.2.2:8000 instead. For a phone on Wi-Fi, pass the computer's LAN address:

    flutter run --dart-define=API_BASE_URL=http://YOUR_PC_LAN_IP:8000

Local development uses HTTP. Release builds require an HTTPS API URL. Put the backend behind a TLS-enabled reverse proxy for deployment.

## Packages and payments

Current proposed monthly tiers are Basic (?0, 3 bookings), Pro (?499, 10 bookings, a 5% discount, and priority listing), Premium (?999, unlimited bookings, a 10% discount, and featured listing), and Ultimate (?1,999, unlimited bookings, a 20% discount, VIP support, and exclusive packages). Subscriptions are available to non-admin users; listing benefits apply to guide and hotel-manager listings.

Card payments are simulated for sandbox development and do not charge a card or contact a payment processor. Cash payments remain pending until an admin confirms collection. Choose and integrate a real provider before accepting production payments.

## Verification

Backend flow tests use an isolated temporary SQLite database:

    cd backend
    python -m pytest -q
