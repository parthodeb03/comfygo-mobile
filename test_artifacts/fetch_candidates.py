import json
import sys
import urllib.parse
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")
UA = "ComfyGoApp/1.0 (travel app asset fetch; contact: dev@example.com)"

QUERIES = {
    # Divisions
    "div_dhaka": "Dhaka cityscape sunset Bangladesh",
    "div_chittagong": "Karnaphuli River Chattogram",
    "div_sylhet": "Surma River Sylhet city",
    "div_rajshahi": "Padma River Rajshahi Bangladesh",
    "div_khulna": "Sundarbans mangrove canal boat",
    "div_barisal": "Barisal river boat Bangladesh",
    "div_rangpur": "Rangpur Bangladesh city",
    "div_mymensingh": "Mymensingh Bangladesh Brahmaputra",
    # Spots
    "spot_coxs_bazar": "Cox's Bazar beach sea",
    "spot_sundarbans": "Sundarbans forest Bangladesh",
    "spot_bandarban": "Bandarban Bangladesh hills",
    "spot_nilgiri": "Nilgiri Bandarban hill",
    "spot_srimangal": "Srimangal tea garden Bangladesh",
    "spot_jaflong": "Jaflong Sylhet stone quarry",
    "spot_ratargul": "Ratargul swamp forest",
    "spot_ahsan_manzil": "Ahsan Manzil Dhaka",
    "spot_lalbagh": "Lalbagh Fort Dhaka",
    "spot_parliament": "National Parliament Bangladesh Jatiya Sangsad",
    "spot_sonargaon": "Sonargaon Panam City Bangladesh",
    "spot_paharpur": "Paharpur Somapura Mahavihara",
    "spot_kantanagar": "Kantanagar Temple Dinajpur",
    "spot_bagerhat": "Sixty Dome Mosque Bagerhat",
    "spot_kuakata": "Kuakata beach Patuakhali",
    "spot_kaptai": "Kaptai Lake Rangamati",
    "spot_patenga": "Patenga Beach Chittagong",
    "spot_sajek": "Sajek Valley Rangamati",
    "spot_tajhat": "Tajhat Palace Rangpur",
    "spot_bagh": "Bagha Mosque Rajshahi terracotta",
    "spot_mymensingh": "Mymensingh Rajbari Bangladesh",
}


def search(term, limit=8):
    params = {
        "action": "query",
        "format": "json",
        "generator": "search",
        "gsrsearch": f"{term} filemime:image/jpeg",
        "gsrnamespace": "6",
        "gsrlimit": str(limit),
        "prop": "imageinfo",
        "iiprop": "url|size",
        "iiurlwidth": "1400",
    }
    url = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode())
    pages = (data.get("query") or {}).get("pages") or {}
    out = []
    for p in pages.values():
        ii = (p.get("imageinfo") or [{}])[0]
        if not ii or not ii.get("thumburl"):
            continue
        out.append((p.get("title"), ii.get("width"), ii.get("height"), ii.get("thumburl")))
    return out


if __name__ == "__main__":
    results = {}
    for key, term in QUERIES.items():
        try:
            res = search(term)
        except Exception as e:
            print(f"{key}: ERROR {e}")
            continue
        results[key] = res
        print(f"\n=== {key} :: {term}")
        for i, (title, w, h, thumb) in enumerate(res):
            print(f"  {i}: [{w}x{h}] {title}")
    with open("test_artifacts/candidates.json", "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=1)
