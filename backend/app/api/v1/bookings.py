from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime
from ...core.database import get_db
from ...models.booking import Booking, BookingStatus, BookingType
from ...models.destination import Destination
from ...models.hotel import Hotel
from ...models.transport import Transport
from ...models.guide import Guide
from ...models.user import User, UserRole
from ...models.package import Package, PackageTier, PackageStatus, UserPackage
from ...schemas.booking import BookingCreate, BookingResponse, BookingUpdate
from ..deps import Principal, get_current_principal, require_non_admin

router = APIRouter(prefix="/bookings", tags=["bookings"])

# Staff roles allowed to change a booking's status (manage flow)
_STAFF_ROLES = {UserRole.admin, UserRole.hotel_manager, UserRole.guide}


def _entitlements_for_user(db: Session, user_id: int) -> Optional[Package]:
    now = datetime.utcnow()
    subscription = (
        db.query(UserPackage)
        .filter(
            UserPackage.user_id == user_id,
            UserPackage.status == PackageStatus.active,
            UserPackage.start_date <= now,
            UserPackage.end_date > now,
        )
        .order_by(UserPackage.end_date.desc())
        .first()
    )
    if subscription:
        return subscription.package
    return db.query(Package).filter(Package.tier == PackageTier.basic).first()


def _monthly_booking_count(db: Session, user_id: int) -> int:
    now = datetime.utcnow()
    month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    next_month = (
        month_start.replace(year=month_start.year + 1, month=1)
        if month_start.month == 12
        else month_start.replace(month=month_start.month + 1)
    )
    return db.query(Booking).filter(
        Booking.tourist_id == user_id,
        Booking.created_at >= month_start,
        Booking.created_at < next_month,
    ).count()


def _days_between(check_in: datetime, check_out: Optional[datetime]) -> int:
    """Whole days between two datetimes, minimum 1. Tolerates mixed tz-aware/naive."""
    ci = check_in.replace(tzinfo=None) if check_in.tzinfo else check_in
    co = check_out.replace(tzinfo=None) if (check_out and check_out.tzinfo) else check_out
    if co is None:
        return 1
    return max((co - ci).days, 1)


def _validate_dates(check_in: datetime, check_out: Optional[datetime]) -> None:
    if check_out is None:
        return
    ci = check_in.replace(tzinfo=None) if check_in.tzinfo else check_in
    co = check_out.replace(tzinfo=None) if check_out.tzinfo else check_out
    if co <= ci:
        raise HTTPException(status_code=400, detail="check_out must be after check_in")


def _get_item(db: Session, booking_type: BookingType, item_id: int):
    """Fetch the booked entity, or None when it doesn't exist."""
    model = {
        BookingType.hotel: Hotel,
        BookingType.transport: Transport,
        BookingType.guide: Guide,
        BookingType.destination: Destination,
    }.get(booking_type)
    if model is None:
        return None
    return db.query(model).filter(model.id == item_id).first()


def _compute_total_price(
    db: Session,
    booking_type: BookingType,
    item_id: int,
    check_in: datetime,
    check_out: Optional[datetime],
    guests: int,
) -> Optional[float]:
    """Derive total price from the booked item. Returns None if item doesn't exist."""
    item = _get_item(db, booking_type, item_id)
    if item is None:
        return None
    if booking_type == BookingType.hotel:
        return item.price_per_night * _days_between(check_in, check_out)
    if booking_type == BookingType.transport:
        return item.price * guests
    if booking_type == BookingType.guide:
        return item.daily_rate * _days_between(check_in, check_out)
    if booking_type == BookingType.destination:
        return item.price * guests
    return None


def _check_availability(db: Session, booking_type: BookingType, item, guests: int) -> None:
    """Raise 400 when the item cannot accommodate the request."""
    if booking_type == BookingType.hotel:
        if (item.available_rooms or 0) < 1:
            raise HTTPException(status_code=400, detail="No rooms available")
    elif booking_type == BookingType.transport:
        if (item.available_seats or 0) < guests:
            raise HTTPException(
                status_code=400,
                detail=f"Only {item.available_seats or 0} seats available",
            )


def _reserve(db: Session, booking_type: BookingType, item, guests: int) -> None:
    """Decrement availability for a newly created booking."""
    if booking_type == BookingType.hotel:
        item.available_rooms = (item.available_rooms or 0) - 1
    elif booking_type == BookingType.transport:
        item.available_seats = (item.available_seats or 0) - guests


def _release(db: Session, booking_type: BookingType, item, guests: int) -> None:
    """Give availability back when a booking is cancelled."""
    if booking_type == BookingType.hotel:
        item.available_rooms = (item.available_rooms or 0) + 1
    elif booking_type == BookingType.transport:
        item.available_seats = (item.available_seats or 0) + (guests or 1)


@router.get("", response_model=dict)
def get_bookings(
    status: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    # Users see their own bookings; admins see everything
    query = db.query(Booking)
    if not principal.is_admin:
        query = query.filter(Booking.tourist_id == principal.id)

    if status:
        query = query.filter(Booking.status == status)

    total = query.count()
    bookings = query.order_by(Booking.id.desc()).offset((page - 1) * limit).limit(limit).all()

    return {
        "items": [BookingResponse.model_validate(b) for b in bookings],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/{booking_id}", response_model=BookingResponse)
def get_booking(
    booking_id: int,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    query = db.query(Booking).filter(Booking.id == booking_id)
    if not principal.is_admin:
        query = query.filter(Booking.tourist_id == principal.id)
    booking = query.first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    return BookingResponse.model_validate(booking)


@router.post("", response_model=BookingResponse)
def create_booking(
    booking: BookingCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)
    assert principal.user is not None
    if principal.user.role != UserRole.tourist:
        raise HTTPException(status_code=403, detail='Only tourists can create bookings')

    plan = _entitlements_for_user(db, principal.user.id)
    if plan is not None and plan.booking_limit >= 0:
        count = _monthly_booking_count(db, principal.user.id)
        if count >= plan.booking_limit:
            raise HTTPException(
                status_code=403,
                detail=f'Monthly booking limit reached for {plan.name}. Upgrade your package to book more.',
            )

    if booking.guests < 1:
        raise HTTPException(status_code=400, detail="guests must be at least 1")
    _validate_dates(booking.check_in, booking.check_out)

    # Price is computed server-side from the booked item, never trusted from client
    item = _get_item(db, booking.type, booking.item_id)
    if item is None:
        raise HTTPException(status_code=404, detail="Referenced item not found")

    total_price = _compute_total_price(
        db, booking.type, booking.item_id,
        booking.check_in, booking.check_out, booking.guests,
    )

    _check_availability(db, booking.type, item, booking.guests)
    gross_total = total_price or 0
    discount_rate = plan.discount_percentage if plan is not None else 0
    discount_amount = round(gross_total * discount_rate / 100, 2)
    total_price = round(gross_total - discount_amount, 2)

    db_booking = Booking(
        tourist_id=principal.user.id,
        tourist_name=principal.user.full_name,
        total_price=total_price,
        discount_amount=discount_amount,
        item_name=getattr(item, "name", None),
        **booking.model_dump(),
    )
    _reserve(db, booking.type, item, booking.guests)
    db.add(db_booking)
    db.commit()
    db.refresh(db_booking)
    return BookingResponse.model_validate(db_booking)


@router.put("/{booking_id}/cancel", response_model=BookingResponse)
def cancel_booking(
    booking_id: int,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)

    booking = db.query(Booking).filter(
        Booking.id == booking_id,
        Booking.tourist_id == principal.id,
    ).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    if booking.status in (BookingStatus.cancelled, BookingStatus.completed):
        raise HTTPException(
            status_code=400,
            detail=f"A {booking.status.value} booking cannot be cancelled",
        )

    # Give reserved inventory back
    item = _get_item(db, booking.type, booking.item_id)
    if item is not None:
        _release(db, booking.type, item, booking.guests or 1)

    booking.status = BookingStatus.cancelled
    db.commit()
    db.refresh(booking)
    return BookingResponse.model_validate(booking)


@router.put("/{booking_id}/status", response_model=BookingResponse)
def update_booking_status(
    booking_id: int,
    data: BookingUpdate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    # Staff only — tourists must not flip their own booking statuses
    if principal.is_admin:
        pass  # admins manage everything
    elif principal.user is None or principal.user.role not in _STAFF_ROLES:
        raise HTTPException(status_code=403, detail="Staff access required")

    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")

    if not principal.is_admin and principal.user is not None:
        item = _get_item(db, booking.type, booking.item_id)
        if principal.user.role == UserRole.hotel_manager:
            if booking.type != BookingType.hotel or item is None or item.manager_id != principal.id:
                raise HTTPException(status_code=403, detail="This booking is outside your hotel listings")
        elif principal.user.role == UserRole.guide:
            if booking.type != BookingType.guide or item is None or item.user_id != principal.id:
                raise HTTPException(status_code=403, detail="This booking is outside your guide assignments")

    if data.status is not None:
        new_status = data.status

        # Releasing reserved inventory when a booking ends without a stay
        if new_status in (BookingStatus.cancelled, BookingStatus.completed):
            if booking.status in (BookingStatus.pending, BookingStatus.confirmed):
                item = _get_item(db, booking.type, booking.item_id)
                if item is not None:
                    _release(db, booking.type, item, booking.guests or 1)
        booking.status = new_status

    db.commit()
    db.refresh(booking)
    return BookingResponse.model_validate(booking)
