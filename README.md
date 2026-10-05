# ComfyGo - Travel Agency App

A full-stack travel agency application built with Flutter (Samsung One UI design) and FastAPI backend.

## Features

### User Roles
- **Tourist**: Browse destinations, book hotels/transport/guides, make payments
- **Guide**: Manage profile, view bookings, update availability
- **Hotel Manager**: Manage hotel listings, view bookings, update availability
- **Admin**: Full access to all data, manage users/bookings/payments/listings

### Core Features
- Authentication with JWT tokens
- Role-based dashboards
- Destination browsing with search and filters
- Hotel/Transport/Guide booking system
- Payment processing (Card & Cash)
- Package/Subscription system (Basic, Pro, Premium, Ultimate)
- Admin panel for system management

## Tech Stack

### Mobile App
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Secure Storage**: flutter_secure_storage
- **Design**: Samsung One UI

### Backend
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL
- **ORM**: SQLAlchemy
- **Authentication**: JWT (python-jose)
- **Password Hashing**: bcrypt (passlib)

## Project Structure

```
comfygo/
├── lib/                    # Flutter app
│   ├── core/              # Core utilities
│   │   ├── theme/         # One UI design system
│   │   ├── widgets/       # Reusable widgets
│   │   ├── router/        # GoRouter configuration
│   │   └── constants/     # API constants
│   ├── features/          # Feature screens
│   │   ├── auth/          # Login, Signup, Forgot Password
│   │   ├── home/          # Home screen
│   │   ├── destinations/  # Destinations list/detail
│   │   ├── hotels/        # Hotels list/detail
│   │   ├── transports/    # Transport list
│   │   ├── guides/        # Guides list/detail
│   │   ├── bookings/      # Bookings list/detail
│   │   ├── payments/      # Payment screen
│   │   ├── packages/      # Package/Subscription
│   │   ├── admin/         # Admin panel
│   │   └── profile/       # User profile
│   ├── models/            # Data models
│   ├── services/          # API services
│   └── state/             # Riverpod providers
├── backend/               # FastAPI backend
│   ├── app/
│   │   ├── api/v1/        # API routes
│   │   ├── core/          # Configuration
│   │   ├── models/        # SQLAlchemy models
│   │   ├── schemas/       # Pydantic schemas
│   │   └── services/      # Business logic
│   └── scripts/           # Seed scripts
└── assets/                # App assets
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Python 3.8+
- PostgreSQL
- Android Studio (for Android development)

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cat > .env << EOF
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/comfygo
SECRET_KEY=your-secret-key-here
EOF

# Create database
createdb comfygo

# Run seed script
python scripts/seed.py

# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Flutter App Setup

```bash
# Navigate to project root
cd ..

# Install Flutter dependencies
flutter pub get

# Run the app (Android)
flutter run
```

### 3. Android Studio Setup

1. Open Android Studio
2. Open the project folder
3. Wait for Gradle sync to complete
4. Select an emulator or connected device
5. Click Run (▶️) or use `flutter run`

## Default Credentials

### Admin Account
- **Email**: admin@comfygo.com
- **Password**: admin123

### Sample User
- **Email**: ahmed@email.com
- **Password**: password123

## API Documentation

Once the backend is running, visit:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Package Tiers

| Tier | Price | Bookings | Discount | Features |
|------|-------|----------|----------|----------|
| Basic | Free | 3/month | 0% | Basic access |
| Pro | $4.99/month | 10/month | 5% | Priority listing |
| Premium | $9.99/month | Unlimited | 10% | Featured listing |
| Ultimate | $19.99/month | Unlimited | 20% | VIP support, exclusive packages |

## State Management

This app uses **Riverpod** for state management:
- `authProvider`: Handles authentication state
- `themeProvider`: Manages light/dark theme
- `navigationProvider`: Controls bottom navigation

## Design System

The app follows **Samsung One UI** design language:
- Large collapsing titles
- Rounded cards with generous padding
- Soft pastel accent colors
- One UI color palette for light/dark modes
- Spring-based animations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
