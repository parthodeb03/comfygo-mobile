"""Search Wikimedia Commons for candidate photos and print metadata.

Usage: python test_artifacts/fetch_photos.py "sundarban mangrove" "cox's bazar beach"
"""
import json
import sys
import urllib.parse
import urllib.request

API = "https://commons.wikimedia.org/w/api.php"
UA = "ComfyGo-asset-helper/1.0 (local dev; contact: dev@example.com)"


def api(params: dict) -> dict:
    params = {**params, "format": "json"}
    url = API + "?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def search(term: str, limit: int = 12) -> list[dict]:
    data = api({
        "action": "query",
        "generator": "search",
        "gsrsearch": f"filetype:bitmap {term}",
        "gsrnamespace": "6",
        "gsrlimit": str(limit),
        "prop": "imageinfo",
        "iiprop": "url|size|mime|extmetadata",
    })
    out = []
    for page in (data.get("query", {}).get("pages", {}) or {}).values():
        info = (page.get("imageinfo") or [{}])[0]
        meta = info.get("extmetadata", {})
        out.append({
            "title": page.get("title"),
            "url": info.get("url"),
            "size": (info.get("width"), info.get("height")),
            "mime": info.get("mime"),
            "license": (meta.get("LicenseShortName") or {}).get("value"),
            "artist": (meta.get("Artist") or {}).get("value", "")[:70],
        })
    return out


if __name__ == "__main__":
    for term in sys.argv[1:]:
        print(f"=== {term} ===")
        for item in search(term):
            w, h = item["size"]
            if item["mime"] != "image/jpeg":
                continue
            print(
                f"  {w}x{h}  {item['license']!s:22.22}  {item['title']}\n"
                f"      {item['url']}"
            )
