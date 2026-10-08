"""Add extra guides, transports and hotels to the existing comfygo.db.

Idempotent: skips rows that already exist (matched by name).
Run from the backend/ folder:  python scripts/seed_more.py
"""
import json
import sqlite3
from datetime import datetime

DB = "comfygo.db"

GUIDES = [
    # name, specialization, location, rate, experience, rating, reviews, bio, languages
    (
        "Fatema Akter",
        "Cultural Tours",
        "Sylhet",
        1600,
        6,
        4.7,
        92,
        "Cultural tour specialist covering Sylhet, tea gardens and heritage sites.",
        ["Bengali", "English"],
    ),
    (
        "Tanvir Hossain",
        "Adventure & Trekking",
        "Bandarban",
        2200,
        9,
        4.8,
        143,
        "High-altitude trekking guide for Bandarban, Sajek and the Hill Tracts.",
        ["Bengali", "English", "Marma"],
    ),
    (
        "Nabila Rahman",
        "Heritage & Photography",
        "Dhaka",
        1800,
        4,
        4.6,
        76,
        "Old Dhaka heritage walks and photography tours across the Mughal city.",
        ["Bengali", "English", "Hindi"],
    ),
    (
        "Shahriar Kabir",
        "Wildlife & Sundarbans",
        "Khulna",
        2000,
        7,
        4.7,
        118,
        "Licensed forest guide for Sundarbans cruises and wildlife spotting.",
        ["Bengali", "English"],
    ),
]

TRANSPORTS = [
    # name, type, description, from, to, depart, arrive, price, total, available, amenities, operator, phone
    (
        "Shohagh Paribahan",
        "bus",
        "Overnight AC bus from Dhaka to Sylhet with reclining seats.",
        "Dhaka",
        "Sylhet",
        "10:30 PM",
        "6:00 AM",
        1100,
        40,
        26,
        ["AC", "WiFi", "Snacks", "Reclining Seats"],
        "Shohagh Paribahan",
        "+880 1711-111111",
    ),
    (
        "Hanif Enterprise",
        "bus",
        "Express bus from Dhaka to Chattogram, departing every night.",
        "Dhaka",
        "Chattogram",
        "11:00 PM",
        "6:30 AM",
        900,
        42,
        30,
        ["AC", "WiFi", "Snacks"],
        "Hanif Enterprise",
        "+880 1722-222222",
    ),
    (
        "Subarna Express",
        "train",
        "Direct intercity train from Dhaka to Sylhet with chair class seats.",
        "Dhaka",
        "Sylhet",
        "6:30 AM",
        "12:30 PM",
        750,
        40,
        18,
        ["AC", "Dining Car", "Luggage Space"],
        "Bangladesh Railway",
        "+880 9611-111111",
    ),
    (
        "US-Bangla Airlines",
        "flight",
        "Morning flight from Dhaka to Cox's Bazar airport.",
        "Dhaka",
        "Cox's Bazar",
        "9:00 AM",
        "9:50 AM",
        5500,
        48,
        33,
        ["In-flight Meal", "Hand Luggage", "15 kg Baggage"],
        "US-Bangla Airlines",
        "+880 1613-333333",
    ),
]

HOTELS = [
    # name, description, location, division, address, price, total, available, rating, reviews, amenities, manager_id
    (
        "Sea Pearl Resort",
        "Beachfront resort with sea-view rooms, pool and rooftop restaurant.",
        "Cox's Bazar",
        "Chittagong",
        "Kalatali Road, Cox's Bazar",
        4200,
        60,
        28,
        4.6,
        214,
        ["WiFi", "Pool", "Restaurant", "Parking", "AC"],
        4,
    ),
    (
        "Sylhet Grand Palace",
        "Central hotel near Zindabazar with garden views and local cuisine.",
        "Sylhet",
        "Sylhet",
        "Zindabazar, Sylhet",
        3500,
        45,
        20,
        4.4,
        132,
        ["WiFi", "Restaurant", "Parking", "AC", "Room Service"],
        5,
    ),
    (
        "Rangpur Garden Resort",
        "Quiet garden resort with family rooms and free breakfast.",
        "Rangpur",
        "Rangpur",
        "Jahaj Company More, Rangpur",
        2200,
        30,
        12,
        4.3,
        88,
        ["WiFi", "Parking", "AC", "Breakfast"],
        4,
    ),
]


def main():
    conn = sqlite3.connect(DB)
    cur = conn.cursor()
    now = datetime.utcnow().isoformat(sep=" ", timespec="seconds")

    # Reuse an existing guide password hash and profile pattern
    cur.execute(
        "select hashed_password from users where role='guide' limit 1"
    )
    row = cur.fetchone()
    password_hash = row[0] if row else "!"

    added_guides = 0
    for i, (name, spec, loc, rate, exp, rating, reviews, bio, langs) in enumerate(
        GUIDES, start=1
    ):
        cur.execute("select id from guides where name = ?", (name,))
        if cur.fetchone():
            continue
        email = f"guide{i + 2}@email.com"
        cur.execute("select id from users where email = ?", (email,))
        user = cur.fetchone()
        if user:
            user_id = user[0]
        else:
            cur.execute(
                "insert into users (email, full_name, phone, role, hashed_password, "
                "created_at, languages, specialization, experience, daily_rate, bio) "
                "values (?, ?, ?, 'guide', ?, ?, ?, ?, ?, ?, ?)",
                (
                    email,
                    name,
                    "+880 1800-000000",
                    password_hash,
                    now,
                    json.dumps(langs),
                    spec,
                    exp,
                    rate,
                    bio,
                ),
            )
            user_id = cur.lastrowid
        cur.execute(
            "insert into guides (user_id, name, profile_image, bio, languages, "
            "specialization, rating, review_count, experience, daily_rate, phone, "
            "email, location, is_approved, created_at, updated_at) "
            "values (?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)",
            (
                user_id,
                name,
                bio,
                json.dumps(langs),
                spec,
                rating,
                reviews,
                exp,
                rate,
                "+880 1800-000000",
                email,
                loc,
                now,
                now,
            ),
        )
        added_guides += 1

    added_transports = 0
    for (
        name,
        ttype,
        desc,
        frm,
        to,
        depart,
        arrive,
        price,
        total,
        available,
        amenities,
        operator,
        phone,
    ) in TRANSPORTS:
        cur.execute(
            "select id from transports where name = ? and from_location = ? and to_location = ?",
            (name, frm, to),
        )
        if cur.fetchone():
            continue
        cur.execute(
            "insert into transports (name, type, description, from_location, "
            "to_location, departure_time, arrival_time, price, total_seats, "
            "available_seats, amenities, operator_name, phone, is_approved, created_at) "
            "values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?)",
            (
                name,
                ttype,
                desc,
                frm,
                to,
                depart,
                arrive,
                price,
                total,
                available,
                json.dumps(amenities),
                operator,
                phone,
                now,
            ),
        )
        added_transports += 1

    added_hotels = 0
    for (
        name,
        desc,
        loc,
        division,
        address,
        price,
        total,
        available,
        rating,
        reviews,
        amenities,
        manager_id,
    ) in HOTELS:
        cur.execute("select id from hotels where name = ?", (name,))
        if cur.fetchone():
            continue
        cur.execute(
            "insert into hotels (name, description, location, division, address, "
            "images, rating, review_count, price_per_night, manager_id, amenities, "
            "total_rooms, available_rooms, is_approved, created_at) "
            "values (?, ?, ?, ?, ?, '[]', ?, ?, ?, ?, ?, ?, ?, 1, ?)",
            (
                name,
                desc,
                loc,
                division,
                address,
                rating,
                reviews,
                price,
                manager_id,
                json.dumps(amenities),
                total,
                available,
                now,
            ),
        )
        added_hotels += 1

    conn.commit()
    print(
        f"[OK] guides +{added_guides}, transports +{added_transports}, "
        f"hotels +{added_hotels}"
    )
    conn.close()


if __name__ == "__main__":
    main()
