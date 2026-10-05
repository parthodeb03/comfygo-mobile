from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
import uuid
from ...core.database import get_db
from ...models.booking import Booking, BookingStatus
from ...models.payment import Payment, PaymentStatus, PaymentMethod
from ...schemas.payment import PaymentCreate, PaymentResponse
from ..deps import Principal, get_current_principal, require_non_admin

router = APIRouter(prefix="/payments", tags=["payments"])

# Tolerance when comparing the submitted amount to the booking total
_AMOUNT_EPSILON = 0.01


def _owns_booking(db: Session, booking_id: int, principal: Principal) -> Optional[Booking]:
    """Load a booking the principal is allowed to pay for."""
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if booking is None:
        return None
    if not principal.is_admin and booking.tourist_id != principal.id:
        return None
    return booking


def _confirm_booking(db: Session, booking: Optional[Booking]) -> None:
    """A successful payment confirms a pending booking."""
    if booking is not None and booking.status == BookingStatus.pending:
        booking.status = BookingStatus.confirmed


@router.get("", response_model=dict)
def get_payments(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    # Users only see their own payments; admins see everything
    query = db.query(Payment)
    if not principal.is_admin:
        query = query.filter(Payment.user_id == principal.id)

    total = query.count()
    payments = query.order_by(Payment.id.desc()).offset((page - 1) * limit).limit(limit).all()

    return {
        "items": [PaymentResponse.model_validate(p) for p in payments],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/{payment_id}", response_model=PaymentResponse)
def get_payment(
    payment_id: int,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    if not principal.is_admin and payment.user_id != principal.id:
        raise HTTPException(status_code=404, detail="Payment not found")
    return PaymentResponse.model_validate(payment)


@router.post("", response_model=PaymentResponse)
def create_payment(
    payment: PaymentCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)

    booking = _owns_booking(db, payment.booking_id, principal)
    if booking is None:
        raise HTTPException(status_code=404, detail="Booking not found")

    if payment.amount <= 0:
        raise HTTPException(status_code=400, detail="Amount must be positive")

    if abs(payment.amount - booking.total_price) > _AMOUNT_EPSILON:
        raise HTTPException(
            status_code=400,
            detail=f"Amount does not match booking total ({booking.total_price:.0f})",
        )

    # One completed payment per booking
    existing = db.query(Payment).filter(
        Payment.booking_id == booking.id,
        Payment.status == PaymentStatus.completed,
    ).first()
    if existing is not None:
        raise HTTPException(status_code=400, detail="Booking is already paid")

    transaction_id = str(uuid.uuid4())
    card_last_four = payment.card_number[-4:] if payment.card_number else None

    # Card payments settle immediately; cash is collected later (admin confirms)
    status = (
        PaymentStatus.completed
        if payment.method == PaymentMethod.card
        else PaymentStatus.pending
    )

    db_payment = Payment(
        user_id=principal.id,
        transaction_id=transaction_id,
        card_last_four=card_last_four,
        status=status,
        **payment.model_dump(
            exclude={"card_number", "expiry_date", "cvv", "cardholder_name"}
        ),
    )
    db.add(db_payment)
    if status == PaymentStatus.completed:
        _confirm_booking(db, booking)
    db.commit()
    db.refresh(db_payment)
    return PaymentResponse.model_validate(db_payment)


@router.put("/{payment_id}/confirm", response_model=PaymentResponse)
def confirm_payment(
    payment_id: int,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    # Confirming cash collection is an admin action
    if not principal.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")

    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    payment.status = PaymentStatus.completed
    booking = db.query(Booking).filter(Booking.id == payment.booking_id).first()
    _confirm_booking(db, booking)
    db.commit()
    db.refresh(payment)
    return PaymentResponse.model_validate(payment)


@router.put("/{payment_id}/refund", response_model=PaymentResponse)
def refund_payment(
    payment_id: int,
    data: dict,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    if not principal.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")

    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")

    payment.status = PaymentStatus.refunded
    db.commit()
    db.refresh(payment)
    return PaymentResponse.model_validate(payment)
