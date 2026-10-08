"""Download curated real Bangladesh photos (Wikimedia Commons) into assets/.

Outputs:
  assets/images/divisions/<division>.jpg   (8 divisions)
  assets/images/spots/<spot>.jpg           (tourist spots)
All images are resized to <=1280px wide and re-encoded as optimized JPEGs.
"""
import io
import os
import sys
import time
import urllib.parse
import urllib.request

from PIL import Image

sys.stdout.reconfigure(encoding="utf-8")
UA = "ComfyGoApp/1.0 (travel app asset fetch; contact: dev@example.com)"

MAX_W = 1280

# key -> Wikimedia Commons File: title
DIVISIONS = {
    "dhaka": "Dhaka cityscape sunset.jpg",
    "chittagong": "At the mouth of Karnaphuli river 02.jpg",
    "sylhet": "The Keane Bridge over the Surma River, Sylhet, Bangladesh.jpg",
    "rajshahi": "Sunset at Padma River, Rajshahi (1).jpg",
    "khulna": "Gol pata on boat from Sundarban, Khulna..JPG",
    "barisal": "Burishwar River in Barguna, Bangladesh (2).jpg",
    "rangpur": "Rangpur - Elite class city of Bangladesh.jpg",
    "mymensingh": "Beautiful Brahmaputra River in Mymensingh,Bangladesh.jpg",
}

SPOTS = {
    "coxs_bazar": "Cox's Bazar Sea Beach in 2024.22.jpg",
    "sundarbans": "Sundarban Landscape during monsoon 17.jpg",
    "bandarban": "The hills of Bandarban.jpg",
    "nilgiri": "Nilgiri Hill Resort, Nilgiri, Bandarban (9813).jpg",
    "srimangal": "Tea Garden near Srimangal, Sylhet, Bangladesh.jpg",
    "jaflong": "Jaflong Sylhet.jpg",
    "ratargul": "Ratargul Swamp Forest, Sylhet.jpg",
    "ahsan_manzil": "Ahsan Manzil-Front View.jpg",
    "lalbagh": "Lalbagh Kella (Lalbagh Fort) Dhaka Bangladesh 2011 36.JPG",
    "parliament": "The Jatiya Sangsad Bhaban at 2024.jpg",
    "sonargaon": "Panam City, Sonargaon, 33.jpg",
    "paharpur": "Aerial view of Somapura Mahavihara.jpg",
    "kantanagar": "Kantanagar Temple Kantanagar.jpg",
    "bagerhat": "Sixty Dome Mosque at Bagerhat (2).jpg",
    "kuakata": "Sunrise at Kuakata beach, Bangladesh.jpg",
    "kaptai": "Hanging Bridge, Kaptai Lake.jpg",
    "patenga": "Patenga Sea Beach, Chittagong 08.jpg",
    "sajek": "Sajek Valley, Rangamati,Bangladesh.jpg",
    "tajhat": "Tajhat Jamidar Palace.jpg",
    "bagha": "Bagha Mosque, Rajshahi, Bangladesh 03.jpg",
    "mymensingh_rajbari": "Mymensingh Rajbari.jpg",
    "saint_martin": "Saint Martin's Island.JPG",
}


def fetch(title):
    url = (
        "https://commons.wikimedia.org/wiki/Special:FilePath/"
        + urllib.parse.quote(title.replace(" ", "_"))
        + f"?width={MAX_W}"
    )
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                return r.read()
        except Exception as e:
            if attempt == 2:
                raise
            time.sleep(2 * (attempt + 1))
            print(f"    retry {attempt + 1}: {e}")


def save(raw, out_path):
    img = Image.open(io.BytesIO(raw))
    img = img.convert("RGB")
    if img.width > MAX_W:
        h = round(img.height * MAX_W / img.width)
        img = img.resize((MAX_W, h), Image.LANCZOS)
    img.save(out_path, "JPEG", quality=80, optimize=True, progressive=True)
    return os.path.getsize(out_path), img.size


def main():
    os.makedirs("assets/images/divisions", exist_ok=True)
    os.makedirs("assets/images/spots", exist_ok=True)
    failures = []
    for group, mapping in (("divisions", DIVISIONS), ("spots", SPOTS)):
        for key, title in mapping.items():
            out = f"assets/images/{group}/{key}.jpg"
            if os.path.exists(out) and os.path.getsize(out) > 10000:
                print(f"skip (exists): {out}")
                continue
            try:
                raw = fetch(title)
                size, dim = save(raw, out)
                print(f"OK  {out}  {dim[0]}x{dim[1]}  {size // 1024} KB  <- {title}")
            except Exception as e:
                failures.append((out, title, str(e)))
                print(f"FAIL {out} <- {title}: {e}")
    print("\n=== FAILURES ===" if failures else "\n=== ALL DONE ===")
    for f in failures:
        print(f)


if __name__ == "__main__":
    main()
