"""Download a Commons image as a 1600px-wide JPEG thumbnail.

Usage: python test_artifacts/download_photo.py "File:Name.jpg" out.jpg
Prints the license/artist so the asset can be attributed.
"""
import json
import sys
import urllib.parse
import urllib.request

API = "https://commons.wikimedia.org/w/api.php"
UA = "ComfyGo-asset-helper/1.0 (local dev; contact: dev@example.com)"


def info(title: str, width: int = 1600) -> dict:
    params = {
        "action": "query",
        "format": "json",
        "titles": title,
        "prop": "imageinfo",
        "iiprop": "url|size|extmetadata",
        "iiurlwidth": str(width),
    }
    req = urllib.request.Request(
        API + "?" + urllib.parse.urlencode(params), headers={"User-Agent": UA}
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = json.load(resp)
    page = next(iter(data["query"]["pages"].values()))
    return page["imageinfo"][0]


def main() -> None:
    title, out = sys.argv[1], sys.argv[2]
    meta = info(title)
    thumb = meta.get("thumburl") or meta["url"]
    req = urllib.request.Request(thumb, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=120) as resp:
        data = resp.read()
    with open(out, "wb") as fh:
        fh.write(data)
    em = meta.get("extmetadata", {})
    print(f"saved {out}: {len(data) / 1024:.0f} KB")
    print("  source :", meta.get("descriptionurl"))
    print("  license:", (em.get("LicenseShortName") or {}).get("value"))
    print("  artist :", (em.get("Artist") or {}).get("value", "")[:120])


if __name__ == "__main__":
    main()
