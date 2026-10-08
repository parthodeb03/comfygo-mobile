"""Contact messages: saved from the app, read by the admin."""
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, ConfigDict, EmailStr, Field
from sqlalchemy.orm import Session

from ...core.database import get_db
from ...models.contact import ContactMessage
from ..deps import get_current_admin

router = APIRouter(prefix="/contact", tags=["contact"])


class ContactCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    name: str = Field(min_length=1, max_length=120)
    email: EmailStr
    message: str = Field(min_length=1, max_length=5000)


class ContactResponse(BaseModel):
    id: int
    name: str
    email: str
    message: str
    resolved: bool
    created_at: object | None = None

    model_config = ConfigDict(from_attributes=True)


@router.post("", response_model=ContactResponse, status_code=201)
def submit_message(payload: ContactCreate, db: Session = Depends(get_db)):
    """Public — anyone can send a message; stored for the admin inbox."""
    row = ContactMessage(
        name=payload.name.strip(),
        email=payload.email,
        message=payload.message.strip(),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return ContactResponse.model_validate(row)


@router.get("/inbox", response_model=dict)
def inbox(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    """Admin-only inbox of all contact messages."""
    query = db.query(ContactMessage)
    total = query.count()
    rows = query.order_by(ContactMessage.id.desc()).offset((page - 1) * limit).limit(limit).all()
    return {
        "items": [ContactResponse.model_validate(r) for r in rows],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.put("/{message_id}/resolve", response_model=ContactResponse)
def resolve_message(
    message_id: int,
    _: object = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    row = db.query(ContactMessage).filter(ContactMessage.id == message_id).first()
    if row is None:
        raise HTTPException(status_code=404, detail="Message not found")
    row.resolved = True
    db.commit()
    db.refresh(row)
    return ContactResponse.model_validate(row)
