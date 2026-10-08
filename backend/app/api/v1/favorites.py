"""DB-backed favorites (add / remove / list)."""
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy.orm import Session

from ...core.database import get_db
from ...models.destination import Destination
from ...models.favorite import Favorite
from ...models.guide import Guide
from ...models.hotel import Hotel
from ...models.transport import Transport
from ..deps import Principal, get_current_principal

router = APIRouter(prefix="/favorites", tags=["favorites"])

_ITEM_MODELS = {
    "destination": Destination,
    "hotel": Hotel,
    "guide": Guide,
    "transport": Transport,
}
_NAME_FIELDS = {"destination": "name", "hotel": "name", "guide": "name", "transport": "operator_name"}


class FavoriteRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    item_type: str = Field(pattern="^(destination|hotel|guide|transport)$")
    item_id: int = Field(ge=1)


class FavoriteResponse(BaseModel):
    id: int
    item_type: str
    item_id: int
    item_name: str | None = None
    item_image: str | None = None

    model_config = ConfigDict(from_attributes=True)


def _load_item(db: Session, item_type: str, item_id: int):
    model = _ITEM_MODELS[item_type]
    item = db.query(model).filter(model.id == item_id).first()
    if item is None:
        raise HTTPException(status_code=404, detail=f"{item_type.title()} not found")
    return item


def _image_of(item, item_type: str) -> str | None:
    if item_type == "guide":
        return item.profile_image
    images = getattr(item, "images", None)
    if images:
        return images[0]
    return None


@router.get("", response_model=dict)
def list_favorites(
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(Favorite)
        .filter(Favorite.user_id == principal.id)
        .order_by(Favorite.id.desc())
        .all()
    )
    return {
        "items": [FavoriteResponse.model_validate(r) for r in rows],
        "total": len(rows),
    }


@router.post("", response_model=FavoriteResponse, status_code=201)
def add_favorite(
    payload: FavoriteRequest,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    if principal.is_admin:
        raise HTTPException(status_code=403, detail="Admin accounts cannot save favorites")

    existing = (
        db.query(Favorite)
        .filter(
            Favorite.user_id == principal.id,
            Favorite.item_type == payload.item_type,
            Favorite.item_id == payload.item_id,
        )
        .first()
    )
    if existing is not None:
        return FavoriteResponse.model_validate(existing)

    item = _load_item(db, payload.item_type, payload.item_id)
    name_field = _NAME_FIELDS[payload.item_type]
    row = Favorite(
        user_id=principal.id,
        item_type=payload.item_type,
        item_id=payload.item_id,
        item_name=getattr(item, name_field, None),
        item_image=_image_of(item, payload.item_type),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return FavoriteResponse.model_validate(row)


@router.delete("/{item_type}/{item_id}", status_code=204)
def remove_favorite(
    item_type: str,
    item_id: int,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    if item_type not in _ITEM_MODELS:
        raise HTTPException(status_code=404, detail="Favorite not found")
    row = (
        db.query(Favorite)
        .filter(
            Favorite.user_id == principal.id,
            Favorite.item_type == item_type,
            Favorite.item_id == item_id,
        )
        .first()
    )
    if row is None:
        raise HTTPException(status_code=404, detail="Favorite not found")
    db.delete(row)
    db.commit()
    return None
