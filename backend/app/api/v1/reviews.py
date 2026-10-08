"""Reviews: leave a rating after a completed booking, browse by item."""
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy.orm import Session

from ...core.database import get_db
from ...models.booking import Booking, BookingStatus, BookingType
from ...models.review import Review
from ...models.destination import Destination
from ...models.guide import Guide
from ...models.hotel import Hotel
from ...models.transport import Transport
from ..deps import Principal, get_current_principal

router = APIRouter(prefix="/reviews", tags=["reviews"])

_ITEM_MODELS = {
    BookingType.hotel.value: Hotel,
    BookingType.transport.value: Transport,
    BookingType.guide.value: Guide,
    BookingType.destination.value: Destination,
}


class ReviewCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    booking_id: int = Field(ge=1)
    rating: int = Field(ge=1, le=5)
    comment: str | None = Field(default=None, max_length=2000)


class ReviewResponse(BaseModel):
    id: int
    booking_id: int
    item_type: str
    item_id: int
    rating: float
    comment: str | None = None
    reviewer_name: str | None = None
    created_at: object | None = None

    model_config = ConfigDict(from_attributes=True)


def _bump_item_rating(db: Session, item_type: str, item_id: int, new_rating: float) -> None:
    """Blend a new review into the listing's denormalized rating/review_count.

    Incremental (rather than a full recompute) so seeded/historical counts are
    preserved even when older reviews predate the reviews table.
    """
    model = _ITEM_MODELS.get(item_type)
    if model is None:
        return
    item = db.query(model).filter(model.id == item_id).first()
    if item is None:
        return
    old_count = int(item.review_count or 0)
    old_rating = float(item.rating or 0)
    item.rating = round((old_rating * old_count + new_rating) / (old_count + 1), 1)
    item.review_count = old_count + 1


@router.post("", response_model=ReviewResponse, status_code=201)
def create_review(
    payload: ReviewCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    if principal.is_admin:
        raise HTTPException(status_code=403, detail="Admin accounts cannot leave reviews")

    booking = db.query(Booking).filter(Booking.id == payload.booking_id).first()
    if booking is None or booking.tourist_id != principal.id:
        raise HTTPException(status_code=404, detail="Booking not found")
    if booking.status != BookingStatus.completed:
        raise HTTPException(
            status_code=400,
            detail="You can only review a completed booking",
        )
    existing = db.query(Review).filter(Review.booking_id == booking.id).first()
    if existing is not None:
        raise HTTPException(status_code=409, detail="This booking has already been reviewed")

    review = Review(
        user_id=principal.id,
        booking_id=booking.id,
        item_type=booking.type.value,
        item_id=booking.item_id,
        rating=float(payload.rating),
        comment=(payload.comment or "").strip() or None,
    )
    db.add(review)
    db.flush()
    _bump_item_rating(db, review.item_type, review.item_id, review.rating)
    db.commit()
    db.refresh(review)

    response = ReviewResponse.model_validate(review)
    response.reviewer_name = principal.full_name
    return response


@router.get("", response_model=dict)
def list_reviews(
    item_type: str | None = Query(default=None, pattern="^(hotel|transport|guide|destination)$"),
    item_id: int | None = Query(default=None, ge=1),
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    """Public list of reviews for an item (or all reviews)."""
    query = db.query(Review)
    if item_type:
        query = query.filter(Review.item_type == item_type)
    if item_id:
        query = query.filter(Review.item_id == item_id)

    total = query.count()
    rows = query.order_by(Review.id.desc()).offset((page - 1) * limit).limit(limit).all()

    from ...models.user import User

    user_ids = {r.user_id for r in rows}
    names = {
        u.id: u.full_name
        for u in db.query(User).filter(User.id.in_(user_ids)).all()
    } if user_ids else {}

    items = []
    for row in rows:
        item = ReviewResponse.model_validate(row)
        item.reviewer_name = names.get(row.user_id)
        items.append(item)

    return {"items": items, "total": total, "page": page, "limit": limit}
