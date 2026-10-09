"""
ComfyGo Seed Script
Populates the database with sample data for testing.
"""
import sys
import os
from datetime import datetime, timedelta
from passlib.context import CryptContext

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings
from app.core.database import engine, SessionLocal, Base
from app.models import (
    User, Admin, Destination, Activity, Hotel, Transport, Guide,
    Booking, Payment, Package, UserPackage,
    Favorite, Review, ContactMessage,
    UserRole, BookingStatus, BookingType,
    PaymentStatus, PaymentMethod, PackageTier, PackageStatus
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

# Unique Unsplash image URLs for each entity
IMAGES = {
    "sundarbans": [
        "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80",
        "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=80",
    ],
    "coxs_bazar": [
        "https://images.unsplash.com/photo-1506929562872-bb421503ef21?w=800&q=80",
        "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80",
    ],
    "sylhet": [
        "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80",
        "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800&q=80",
    ],
    "bandarban": [
        "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80",
        "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=80",
    ],
    "hotel_sea_shell": [
        "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80",
        "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80",
    ],
    "ruposhi_bangla": [
        "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=80",
        "https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&q=80",
    ],
    "guide_karim": [
        "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80",
    ],
    "guide_rahim": [
        "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=80",
    ],
    "home_banner": [
        "https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=800&q=80",
    ],
}

def seed_database():
    if not settings.ADMIN_EMAIL or not settings.ADMIN_PASSWORD:
        raise RuntimeError("Set ADMIN_EMAIL and ADMIN_PASSWORD in backend/.env before seeding.")

    # Create all tables
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    try:
        # Check if data already exists
        if db.query(User).count() > 0:
            print("Database already seeded. Skipping...")
            return
        
        print("Seeding database...")
        
        # ═══════════════════════════════════════════
        # ADMIN ACCOUNT
        # ═══════════════════════════════════════════
        admin = Admin(
            email=settings.ADMIN_EMAIL,
            full_name="System Administrator",
            hashed_password=hash_password(settings.ADMIN_PASSWORD)
        )
        db.add(admin)
        db.flush()
        print("[OK] Admin account created")
        
        # ═══════════════════════════════════════════
        # TOURISTS
        # ═══════════════════════════════════════════
        tourists = [
            User(
                email="ahmed@email.com",
                full_name="Ahmed Hassan",
                phone="+880 1712345678",
                role=UserRole.tourist,
                hashed_password=hash_password("password123"),
                address="Dhanmondi, Dhaka",
                nationality="Bangladeshi"
            ),
            User(
                email="fatima@email.com",
                full_name="Fatima Khan",
                phone="+880 1812345678",
                role=UserRole.tourist,
                hashed_password=hash_password("password123"),
                address="Gulshan, Dhaka",
                nationality="Bangladeshi"
            ),
            User(
                email="sara@email.com",
                full_name="Sara Ali",
                phone="+880 1912345678",
                role=UserRole.tourist,
                hashed_password=hash_password("password123"),
                address="Banani, Dhaka",
                nationality="Bangladeshi"
            ),
        ]
        db.add_all(tourists)
        db.flush()
        print(f"[OK] {len(tourists)} tourists created")
        
        # ═══════════════════════════════════════════
        # HOTEL MANAGERS
        # ═══════════════════════════════════════════
        managers = [
            User(
                email="rahman@email.com",
                full_name="Rahman Hotels",
                phone="+880 1612345678",
                role=UserRole.hotel_manager,
                hashed_password=hash_password("password123"),
            ),
            User(
                email="karim@email.com",
                full_name="Karim Enterprises",
                phone="+880 1512345678",
                role=UserRole.hotel_manager,
                hashed_password=hash_password("password123"),
            ),
        ]
        db.add_all(managers)
        db.flush()
        print(f"[OK] {len(managers)} hotel managers created")
        
        # ═══════════════════════════════════════════
        # GUIDES
        # ═══════════════════════════════════════════
        guide_users = [
            User(
                email="guide1@email.com",
                full_name="Karim Ahmed",
                phone="+880 1412345678",
                role=UserRole.guide,
                hashed_password=hash_password("password123"),
                bio="Experienced trekking guide with 8 years of experience",
                languages=["Bengali", "English", "Hindi"],
                specialization="Trekking & Adventure",
                experience=8,
                daily_rate=2000,
                profile_image=IMAGES["guide_karim"][0],
            ),
            User(
                email="guide2@email.com",
                full_name="Rahim Uddin",
                phone="+880 1312345678",
                role=UserRole.guide,
                hashed_password=hash_password("password123"),
                bio="Cultural tour specialist",
                languages=["Bengali", "English"],
                specialization="Cultural Tours",
                experience=5,
                daily_rate=1500,
                profile_image=IMAGES["guide_rahim"][0],
            ),
        ]
        db.add_all(guide_users)
        db.flush()
        print(f"[OK] {len(guide_users)} guides created")
        
        # ═══════════════════════════════════════════
        # DESTINATIONS
        # ═══════════════════════════════════════════
        destinations = [
            Destination(
                name="Sundarbans",
                description="The world's largest mangrove forest, home to the Royal Bengal Tiger.",
                location="Khulna Division",
                division="Khulna",
                price=15000,
                rating=4.8,
                review_count=245,
                best_time_to_visit="October to March",
                activities=["Boat Cruise", "Tiger Spotting", "Bird Watching", "Nature Walk"],
                is_featured=True,
                images=IMAGES["sundarbans"],
            ),
            Destination(
                name="Cox's Bazar",
                description="The world's longest natural sandy sea beach.",
                location="Chittagong Division",
                division="Chittagong",
                price=8000,
                rating=4.7,
                review_count=389,
                best_time_to_visit="November to February",
                activities=["Beach Activities", "Seafood", "Sunset Viewing", "Water Sports"],
                is_featured=True,
                images=IMAGES["coxs_bazar"],
            ),
            Destination(
                name="Sylhet Tea Gardens",
                description="Lush green tea gardens in the northeastern region.",
                location="Sylhet Division",
                division="Sylhet",
                price=10000,
                rating=4.6,
                review_count=178,
                best_time_to_visit="September to December",
                activities=["Tea Garden Tour", "Hiking", "Photography", "Waterfalls"],
                is_featured=True,
                images=IMAGES["sylhet"],
            ),
            Destination(
                name="Bandarban",
                description="Home to the highest peaks of Bangladesh.",
                location="Chittagong Hill Tracts",
                division="Chittagong",
                price=12000,
                rating=4.5,
                review_count=134,
                best_time_to_visit="October to March",
                activities=["Trekking", "Tribal Culture", "Photography", "Camping"],
                is_featured=True,
                images=IMAGES["bandarban"],
            ),
        ]
        for destination in destinations:
            activity_records = []
            activity_records = [
                {
                    "imageUrl": destination.images[0] if destination.images else "",
                    "name": activity_name,
                    "type": "Sightseeing Tour",
                    "startTimes": ["9:00 AM", "2:00 PM"],
                    "rating": 5,
                    "price": max(500, int(destination.price / 10)),
                }
                for activity_name in destination.activities
            ]
            destination.activities = activity_records
            destination.tour_activities = [
                Activity(
                    image_url=activity["imageUrl"],
                    name=activity["name"],
                    type=activity["type"],
                    start_times=activity["startTimes"],
                    rating=activity["rating"],
                    price=activity["price"],
                )
                for activity in activity_records
            ]
        db.add_all(destinations)
        db.flush()
        print(f"[OK] {len(destinations)} destinations created")
        
        # ═══════════════════════════════════════════
        # HOTELS
        # ═══════════════════════════════════════════
        hotels = [
            Hotel(
                name="Hotel Sea Shell",
                description="Beachfront hotel with stunning sea views.",
                location="Cox's Bazar",
                division="Chittagong",
                address="Kalatali Road, Cox's Bazar",
                price_per_night=3500,
                manager_id=managers[0].id,
                amenities=["WiFi", "Pool", "Restaurant", "Parking", "AC"],
                total_rooms=50,
                available_rooms=20,
                rating=4.5,
                review_count=156,
                images=IMAGES["hotel_sea_shell"],
            ),
            Hotel(
                name="Ruposhi Bangla",
                description="Luxury hotel in the heart of Dhaka.",
                location="Dhaka",
                division="Dhaka",
                address="Bangabandhu Avenue, Dhaka",
                price_per_night=5000,
                manager_id=managers[1].id,
                amenities=["WiFi", "Gym", "Spa", "Restaurant", "Conference Hall"],
                total_rooms=100,
                available_rooms=35,
                rating=4.3,
                review_count=289,
                images=IMAGES["ruposhi_bangla"],
            ),
        ]
        db.add_all(hotels)
        db.flush()
        print(f"[OK] {len(hotels)} hotels created")
        
        # ═══════════════════════════════════════════
        # TRANSPORTS
        # ═══════════════════════════════════════════
        transports = [
            Transport(
                name="Green Line Bus",
                type="bus",
                description="AC bus service from Dhaka to Cox's Bazar",
                from_location="Dhaka",
                to_location="Cox's Bazar",
                departure_time="08:00 AM",
                arrival_time="06:00 PM",
                price=1200,
                total_seats=40,
                available_seats=15,
                amenities=["AC", "WiFi", "Snacks"],
                operator_name="Green Line",
            ),
            Transport(
                name="Bangladesh Railway",
                type="train",
                description="Train service from Dhaka to Sylhet",
                from_location="Dhaka",
                to_location="Sylhet",
                departure_time="10:30 AM",
                arrival_time="06:30 PM",
                price=800,
                total_seats=200,
                available_seats=42,
                amenities=["AC", "Food Service"],
                operator_name="Bangladesh Railway",
            ),
        ]
        db.add_all(transports)
        db.flush()
        print(f"[OK] {len(transports)} transports created")
        
        # ═══════════════════════════════════════════
        # GUIDE PROFILES
        # ═══════════════════════════════════════════
        guide_profiles = [
            Guide(
                user_id=guide_users[0].id,
                name="Karim Ahmed",
                bio="Experienced trekking guide specializing in the Chittagong Hill Tracts.",
                languages=["Bengali", "English", "Hindi"],
                specialization="Trekking & Adventure",
                experience=8,
                daily_rate=2000,
                rating=4.8,
                review_count=67,
                location="Chittagong",
                profile_image=IMAGES["guide_karim"][0],
            ),
            Guide(
                user_id=guide_users[1].id,
                name="Rahim Uddin",
                bio="Cultural tour specialist with deep knowledge of Bangladesh heritage.",
                languages=["Bengali", "English"],
                specialization="Cultural Tours",
                experience=5,
                daily_rate=1500,
                rating=4.6,
                review_count=45,
                location="Dhaka",
                profile_image=IMAGES["guide_rahim"][0],
            ),
        ]
        db.add_all(guide_profiles)
        db.flush()
        print(f"[OK] {len(guide_profiles)} guide profiles created")
        
        # ═══════════════════════════════════════════
        # PACKAGES
        # ═══════════════════════════════════════════
        packages = [
            Package(
                name="Basic",
                tier=PackageTier.basic,
                price=0,
                description="Free tier with basic features",
                booking_limit=3,
                discount_percentage=0
            ),
            Package(
                name="Pro",
                tier=PackageTier.pro,
                price=499,
                description="Pro tier with priority listing",
                booking_limit=10,
                discount_percentage=5,
                priority_listing=True
            ),
            Package(
                name="Premium",
                tier=PackageTier.premium,
                price=999,
                description="Premium tier with featured listing",
                booking_limit=-1,  # unlimited
                discount_percentage=10,
                priority_listing=True,
                featured_listing=True
            ),
            Package(
                name="Ultimate",
                tier=PackageTier.ultimate,
                price=1999,
                description="Ultimate tier with all features",
                booking_limit=-1,  # unlimited
                discount_percentage=20,
                priority_listing=True,
                featured_listing=True,
                vip_support=True,
                exclusive_packages=True
            ),
        ]
        db.add_all(packages)
        db.flush()
        print(f"[OK] {len(packages)} packages created")
        
        # ═══════════════════════════════════════════
        # SAMPLE BOOKINGS
        # ═══════════════════════════════════════════
        bookings = [
            Booking(
                tourist_id=tourists[0].id,
                tourist_name=tourists[0].full_name,
                type=BookingType.hotel,
                status=BookingStatus.confirmed,
                item_id=hotels[0].id,
                item_name=hotels[0].name,
                check_in=datetime.utcnow() + timedelta(days=7),
                check_out=datetime.utcnow() + timedelta(days=10),
                guests=2,
                total_price=10500
            ),
            Booking(
                tourist_id=tourists[1].id,
                tourist_name=tourists[1].full_name,
                type=BookingType.transport,
                status=BookingStatus.pending,
                item_id=transports[0].id,
                item_name=transports[0].name,
                check_in=datetime.utcnow() + timedelta(days=7),
                guests=1,
                total_price=1200
            ),
        ]
        db.add_all(bookings)
        db.flush()
        print(f"[OK] {len(bookings)} bookings created")
        
        # ═══════════════════════════════════════════
        # SAMPLE PAYMENTS
        # ═══════════════════════════════════════════
        payments = [
            Payment(
                booking_id=bookings[0].id,
                user_id=tourists[0].id,
                amount=10500,
                method=PaymentMethod.card,
                status=PaymentStatus.completed,
                transaction_id="TXN-001",
                card_last_four="4242"
            ),
            Payment(
                booking_id=bookings[1].id,
                user_id=tourists[1].id,
                amount=1200,
                method=PaymentMethod.cash,
                status=PaymentStatus.pending
            ),
        ]
        db.add_all(payments)
        db.flush()
        print(f"[OK] {len(payments)} payments created")

        # ═══════════════════════════════════════════
        # COMPLETED BOOKING + REVIEW (ratings demo)
        # ═══════════════════════════════════════════
        completed_booking = Booking(
            tourist_id=tourists[2].id,
            tourist_name=tourists[2].full_name,
            type=BookingType.hotel,
            status=BookingStatus.completed,
            item_id=hotels[1].id,
            item_name=hotels[1].name,
            check_in=datetime.utcnow() - timedelta(days=30),
            check_out=datetime.utcnow() - timedelta(days=27),
            guests=2,
            total_price=15000,
        )
        db.add(completed_booking)
        db.flush()
        db.add(Review(
            user_id=tourists[2].id,
            booking_id=completed_booking.id,
            item_type="hotel",
            item_id=hotels[1].id,
            rating=5,
            comment="Beautiful stay, staff were incredibly helpful.",
        ))
        db.flush()
        print("[OK] completed booking + review created")

        # ═══════════════════════════════════════════
        # SAMPLE FAVORITES
        # ═══════════════════════════════════════════
        favorites = [
            Favorite(
                user_id=tourists[0].id,
                item_type="destination",
                item_id=destinations[0].id,
                item_name=destinations[0].name,
                item_image=destinations[0].images[0] if destinations[0].images else None,
            ),
            Favorite(
                user_id=tourists[0].id,
                item_type="hotel",
                item_id=hotels[0].id,
                item_name=hotels[0].name,
                item_image=hotels[0].images[0] if hotels[0].images else None,
            ),
        ]
        db.add_all(favorites)
        db.flush()
        print(f"[OK] {len(favorites)} favorites created")

        # ═══════════════════════════════════════════
        # SAMPLE CONTACT MESSAGES (admin inbox)
        # ═══════════════════════════════════════════
        contact_messages = [
            ContactMessage(
                name="Tanvir Ahmed",
                email="tanvir@example.com",
                message="When will the Sylhet tour package be available in July?",
            ),
            ContactMessage(
                name="Nusrat Jahan",
                email="nusrat@example.com",
                message="I need to change the date of my existing booking. Please advise.",
            ),
        ]
        db.add_all(contact_messages)
        db.flush()
        print(f"[OK] {len(contact_messages)} contact messages created")

        # Commit all changes
        db.commit()
        
        print("\n" + "="*50)
        print("[OK] Database seeded successfully!")
        print("="*50)
        print(f"\nAdmin account seeded for: {settings.ADMIN_EMAIL}")
        print("\nSample user credentials:")
        print("  Email: ahmed@email.com")
        print("  Password: password123")
        print("="*50)
        
    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
        raise
    finally:
        db.close()

if __name__ == "__main__":
    seed_database()
