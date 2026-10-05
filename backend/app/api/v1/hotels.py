from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from ...core.database import get_db
from ...models.hotel import Hotel
from ...models.user import User, UserRole
from ...schemas.hotel import HotelCreate, HotelUpdate, HotelResponse
from ..deps import Principal, get_current_principal, require_non_admin

router = APIRouter(prefix="/hotels", tags=["hotels"])


def _can_manage(hotel: Hotel, principal: Principal) -> bool:
    """Admins manage everything; hotel managers manage only their own listings."""
    if principal.is_admin:
        return True
    return (
        principal.user is not None
        and principal.user.role == UserRole.hotel_manager
        and hotel.manager_id == principal.id
    )


@router.get("", response_model=dict)
def get_hotels(
    search: Optional[str] = None,
    division: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(Hotel).filter(Hotel.is_approved == True)
    
    if search:
        query = query.filter(Hotel.name.ilike(f"%{search}%"))
    if division:
        query = query.filter(Hotel.division == division)
    if min_price:
        query = query.filter(Hotel.price_per_night >= min_price)
    if max_price:
        query = query.filter(Hotel.price_per_night <= max_price)
    
    total = query.count()
    hotels = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [HotelResponse.model_validate(h) for h in hotels],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/{hotel_id}", response_model=HotelResponse)
def get_hotel(hotel_id: int, db: Session = Depends(get_db)):
    hotel = db.query(Hotel).filter(Hotel.id == hotel_id).first()
    if not hotel:
        raise HTTPException(status_code=404, detail="Hotel not found")
    return HotelResponse.model_validate(hotel)

@router.post("", response_model=HotelResponse)
def create_hotel(
    hotel: HotelCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    # Hotel managers create their own listings; admins can create any
    if not principal.is_admin and (
        principal.user is None or principal.user.role != UserRole.hotel_manager
    ):
        raise HTTPException(status_code=403, detail="Hotel manager access required")

    payload = hotel.model_dump()
    # The creating manager owns the listing (admins may reassign later via PUT)
    db_hotel = Hotel(
        **payload,
        manager_id=principal.id,
        # Fresh listings start fully bookable
        available_rooms=payload.get("total_rooms", 0),
    )
    db.add(db_hotel)
    db.commit()
    db.refresh(db_hotel)
    return HotelResponse.model_validate(db_hotel)

@router.put("/{hotel_id}", response_model=HotelResponse)
def update_hotel(
    hotel_id: int,
    updates: HotelUpdate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    hotel = db.query(Hotel).filter(Hotel.id == hotel_id).first()
    if not hotel:
        raise HTTPException(status_code=404, detail="Hotel not found")
    if not _can_manage(hotel, principal):
        raise HTTPException(status_code=403, detail="Not allowed to edit this listing")

    for key, value in updates.model_dump(exclude_unset=True).items():
        setattr(hotel, key, value)
    db.commit()
    db.refresh(hotel)
    return HotelResponse.model_validate(hotel)

@router.delete("/{hotel_id}")
def delete_hotel(
    hotel_id: int,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    hotel = db.query(Hotel).filter(Hotel.id == hotel_id).first()
    if not hotel:
        raise HTTPException(status_code=404, detail="Hotel not found")
    if not _can_manage(hotel, principal):
        raise HTTPException(status_code=403, detail="Not allowed to delete this listing")

    db.delete(hotel)
    db.commit()
    return {"detail": "Hotel deleted"}
