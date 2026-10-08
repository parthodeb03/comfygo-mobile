"""In-memory sliding-window rate limiter for auth endpoints.

Deliberately dependency-free: buckets live in process memory, which is the
right trade-off for a single-worker development deployment. Behind a
multi-worker/production deployment this should be swapped for a shared store
(Redis) — the :func:`rate_limit` dependency is the single integration point.
"""
import time
from typing import Callable

from fastapi import HTTPException, Request

from ..core.config import settings

# key -> list of request timestamps inside the current window
_BUCKETS: dict[str, list[float]] = {}


def _client_ip(request: Request) -> str:
    if request.client and request.client.host:
        return request.client.host
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return "unknown"


def check_rate_limit(request: Request, bucket: str, limit: int, window_seconds: int) -> None:
    """Raise 429 when `limit` requests from the same IP hit `bucket` within `window_seconds`."""
    if not settings.RATE_LIMIT_ENABLED:
        return

    key = f"{bucket}:{_client_ip(request)}"
    now = time.monotonic()
    hits = [t for t in _BUCKETS.get(key, []) if now - t < window_seconds]

    if len(hits) >= limit:
        _BUCKETS[key] = hits
        retry_after = int(window_seconds - (now - hits[0])) + 1
        raise HTTPException(
            status_code=429,
            detail="Too many attempts. Please wait and try again.",
            headers={"Retry-After": str(retry_after)},
        )

    hits.append(now)
    _BUCKETS[key] = hits


def rate_limit(bucket: str, limit_setting: str) -> Callable:
    """FastAPI dependency factory: `rate_limit("login", "AUTH_RATE_LIMIT")`."""

    def _dependency(request: Request) -> None:
        limit = getattr(settings, limit_setting)
        check_rate_limit(request, bucket, limit, settings.RATE_LIMIT_WINDOW_SECONDS)

    return _dependency


def reset_buckets() -> None:
    """Test hook — clear all counters."""
    _BUCKETS.clear()
