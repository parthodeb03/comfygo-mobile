"""Shared FastAPI dependencies.

Two token principals are supported:

* **User** tokens   — issued by ``/auth/login`` and ``/auth/register``.
* **Admin** tokens  — issued by ``/admin/login`` (claim ``role == "admin"``).

Admin ids live in a separate table from user ids, so an admin token must
NEVER be resolved through :func:`get_current_user` (doing so used to collide
with an unrelated user that happened to share the id). Use
:func:`get_current_principal` for endpoints that serve both, and
:func:`get_current_admin` for admin-only endpoints.
"""
from dataclasses import dataclass
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from ..core.config import settings
from ..core.database import get_db
from ..models.user import Admin, User

# auto_error=False so we can return a clean 401 instead of a default 403
security = HTTPBearer(auto_error=False)


@dataclass
class Principal:
    """Authenticated account — either a regular user or an admin."""

    id: int
    role: str  # UserRole value, or "admin"
    user: Optional[User] = None
    admin: Optional[Admin] = None

    @property
    def is_admin(self) -> bool:
        return self.role == "admin"

    @property
    def email(self) -> str:
        return (self.user or self.admin).email  # type: ignore[union-attr]

    @property
    def full_name(self) -> str:
        return (self.user or self.admin).full_name  # type: ignore[union-attr]


def _decode_token(
    credentials: Optional[HTTPAuthorizationCredentials],
) -> tuple:
    """Decode the bearer token → ``(subject_id, role_claim)``."""
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
        )

    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
        )
        subject = payload.get("sub")
        if subject is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )
        role = payload.get("role", "user") or "user"
        return int(subject), str(role)
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
    except (TypeError, ValueError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )


def get_current_principal(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db),
) -> Principal:
    """Load whichever account the token belongs to (user *or* admin)."""
    subject, role = _decode_token(credentials)

    if role == "admin":
        admin = db.query(Admin).filter(Admin.id == subject).first()
        if admin is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Admin account not found",
            )
        return Principal(id=admin.id, role="admin", admin=admin)

    user = db.query(User).filter(User.id == subject).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return Principal(id=user.id, role=user.role.value, user=user)


def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    """Resolve a *regular user* from the Authorization header.

    Admin tokens are rejected with 403 — they must never be interpreted as a
    user because the ids come from different tables.
    """
    subject, role = _decode_token(credentials)

    if role == "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin accounts must use the admin endpoints",
        )

    user = db.query(User).filter(User.id == subject).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )
    return user


def get_current_admin(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db),
) -> Admin:
    """Resolve an *admin* from the Authorization header (admin endpoints only)."""
    subject, role = _decode_token(credentials)

    if role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required",
        )

    admin = db.query(Admin).filter(Admin.id == subject).first()
    if admin is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Admin account not found",
        )
    return admin


def require_non_admin(principal: Principal) -> None:
    """Guard for endpoints that operate on a *user's own* data."""
    if principal.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin accounts cannot perform this action",
        )
