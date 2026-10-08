"""6-digit password-reset codes (issue -> verify -> reset).

Codes are stored hashed (SHA-256 over SECRET_KEY + code) with a short TTL.
There is no email/SMS provider wired up in this project, so the code is
returned in the API response for development and logged server-side; a
production deployment should deliver it out-of-band and drop `dev_code`.
"""
import hashlib
import logging
import secrets
from datetime import datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from ..core.config import settings
from ..models.password_reset import PasswordReset
from ..models.user import User
from .auth_service import get_password_hash

logger = logging.getLogger("comfygo.auth")


def _hash_code(code: str) -> str:
    return hashlib.sha256((settings.SECRET_KEY + code).encode("utf-8")).hexdigest()


def issue_code(db: Session, email: str) -> dict:
    """Create a fresh 6-digit code for the user. Always reports success (no user enumeration)."""
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        logger.info("Password reset requested for unknown email %s", email)
        return {"detail": "If that email is registered, a 6-digit code has been sent."}

    code = f"{secrets.randbelow(1_000_000):06d}"
    # Invalidate previous unused codes — only the newest one works
    db.query(PasswordReset).filter(
        PasswordReset.user_id == user.id,
        PasswordReset.used.is_(False),
    ).update({"used": True}, synchronize_session=False)

    db.add(PasswordReset(
        user_id=user.id,
        code_hash=_hash_code(code),
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=settings.RESET_CODE_TTL_MINUTES),
        used=False,
    ))
    db.commit()

    # No email/SMS provider in this project: log it and return it for development.
    logger.info("Password reset code for %s: %s", email, code)
    return {
        "detail": "If that email is registered, a 6-digit code has been sent.",
        "dev_code": code,
        "expires_in_minutes": settings.RESET_CODE_TTL_MINUTES,
    }


def verify_code(db: Session, email: str, code: str) -> str:
    """Check the code and return a short-lived reset token (JWT)."""
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    record = (
        db.query(PasswordReset)
        .filter(PasswordReset.user_id == user.id, PasswordReset.used.is_(False))
        .order_by(PasswordReset.id.desc())
        .first()
    )
    if record is None or record.code_hash != _hash_code(code):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    expires = record.expires_at
    if expires.tzinfo is None:
        expires = expires.replace(tzinfo=timezone.utc)
    if expires < datetime.now(timezone.utc):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    record.used = True
    db.commit()

    from .auth_service import create_access_token  # local import avoids cycle at module load

    token = create_access_token(
        data={"sub": str(user.id), "purpose": "password_reset"},
        expires_delta=timedelta(minutes=settings.RESET_CODE_TTL_MINUTES),
    )
    return token


def reset_password(db: Session, token: str, new_password: str) -> None:
    """Consume a reset token and set the new password."""
    from jose import JWTError, jwt

    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    if payload.get("purpose") != "password_reset":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    try:
        user_id = int(payload.get("sub"))
    except (TypeError, ValueError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

    if len(new_password) < 8:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 8 characters",
        )

    user.hashed_password = get_password_hash(new_password)
    db.commit()
