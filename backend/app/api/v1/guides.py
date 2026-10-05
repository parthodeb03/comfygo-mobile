from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from ...core.database import get_db
from ...models.guide import Guide
from ...models.user import UserRole
from ...schemas.guide import GuideCreate, GuideUpdate, GuideResponse
from ..deps import Principal, get_current_principal

router = APIRouter(prefix="/guides", tags=["guides"])


def _can_edit(guide: Guide, principal: Principal) -> bool:
    """Admins edit anything; guides edit only their own profile."""
    if principal.is_admin:
        return True
    return principal.user is not None and guide.user_id == principal.id


@router.get("", response_model=dict)
def get_guides(
    search: Optional[str] = None,
    specialization: Optional[str] = None,
    location: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(Guide).filter(Guide.is_approved == True)
    
    if search:
        query = query.filter(Guide.name.ilike(f"%{search}%"))
    if specialization:
        query = query.filter(Guide.specialization.ilike(f"%{specialization}%"))
    if location:
        query = query.filter(Guide.location.ilike(f"%{location}%"))
    
    total = query.count()
    guides = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [GuideResponse.model_validate(g) for g in guides],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/{guide_id}", response_model=GuideResponse)
def get_guide(guide_id: int, db: Session = Depends(get_db)):
    guide = db.query(Guide).filter(Guide.id == guide_id).first()
    if not guide:
        raise HTTPException(status_code=404, detail="Guide not found")
    return GuideResponse.model_validate(guide)


@router.post("", response_model=GuideResponse)
def create_guide(
    guide: GuideCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    # Guides create their own profile; admins may create one for someone else
    if not principal.is_admin and (
        principal.user is None or principal.user.role != UserRole.guide
    ):
        raise HTTPException(status_code=403, detail="Guide access required")

    payload = guide.model_dump()
    user_id = payload.pop("user_id", None)
    if principal.is_admin and user_id:
        target_user_id = user_id
    else:
        target_user_id = principal.id

    db_guide = Guide(**payload, user_id=target_user_id)
    db.add(db_guide)
    db.commit()
    db.refresh(db_guide)
    return GuideResponse.model_validate(db_guide)


@router.put("/{guide_id}", response_model=GuideResponse)
def update_guide(
    guide_id: int,
    updates: GuideUpdate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    guide = db.query(Guide).filter(Guide.id == guide_id).first()
    if not guide:
        raise HTTPException(status_code=404, detail="Guide not found")
    if not _can_edit(guide, principal):
        raise HTTPException(status_code=403, detail="Not allowed to edit this profile")

    for key, value in updates.model_dump(exclude_unset=True).items():
        setattr(guide, key, value)
    db.commit()
    db.refresh(guide)
    return GuideResponse.model_validate(guide)
