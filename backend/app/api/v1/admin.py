from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from ...core.database import get_db
from ...models.user import User, Admin
from ...models.booking import Booking
from ...models.payment import Payment, PaymentStatus
from ...models.hotel import Hotel
from ...models.package import UserPackage, PackageStatus
from ...services.auth_service import authenticate_admin, create_access_token
from ...schemas.user import AdminLoginRequest, AuthResponse, UserResponse
from ...schemas.payment import PaymentResponse, VoidRequest
from ...schemas.booking import BookingResponse
from ...schemas.hotel import HotelResponse
from ...schemas.package import UserPackageResponse
from ..deps import get_current_admin
from ...core.rate_limit import rate_limit

router = APIRouter(prefix="/admin", tags=["admin"])

_admin_login_limit = rate_limit("admin:login", "AUTH_RATE_LIMIT")

@router.post("/login", response_model=AuthResponse)
def admin_login(
    request: AdminLoginRequest,
    db: Session = Depends(get_db),
    _limit: None = Depends(_admin_login_limit),
):
    admin = authenticate_admin(db, request.email, request.password)
    if not admin:
        raise HTTPException(status_code=401, detail="Invalid admin credentials")
    
    access_token = create_access_token(data={"sub": str(admin.id), "role": "admin"})
    
    return AuthResponse(
        access_token=access_token,
        refresh_token=access_token,  # Admin uses same token
        user=UserResponse(
            id=admin.id,
            email=admin.email,
            full_name=admin.full_name,
            phone="",
            role="admin",
        )
    )

@router.get("/users", response_model=dict)
def get_users(
    search: Optional[str] = None,
    role: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    query = db.query(User)
    
    if search:
        query = query.filter(User.full_name.ilike(f"%{search}%") | User.email.ilike(f"%{search}%"))
    if role:
        query = query.filter(User.role == role)
    
    total = query.count()
    users = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [UserResponse.model_validate(u) for u in users],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/bookings", response_model=dict)
def get_all_bookings(
    status: Optional[str] = None,
    type: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    query = db.query(Booking)
    
    if status:
        query = query.filter(Booking.status == status)
    if type:
        query = query.filter(Booking.type == type)
    
    total = query.count()
    bookings = query.order_by(Booking.id.desc()).offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [BookingResponse.model_validate(b) for b in bookings],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/payments", response_model=dict)
def get_all_payments(
    status: Optional[str] = None,
    method: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    query = db.query(Payment)
    
    if status:
        query = query.filter(Payment.status == status)
    if method:
        query = query.filter(Payment.method == method)
    
    total = query.count()
    payments = query.order_by(Payment.id.desc()).offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [PaymentResponse.model_validate(p) for p in payments],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/listings", response_model=dict)
def get_all_listings(
    type: Optional[str] = None,
    approved: Optional[bool] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    # Listings are hotel records (transports/guides are approved at creation)
    query = db.query(Hotel)

    if approved is not None:
        query = query.filter(Hotel.is_approved == approved)
    
    total = query.count()
    listings = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [HotelResponse.model_validate(l) for l in listings],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.put("/listings/{listing_id}/approve")
def approve_listing(
    listing_id: int,
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    hotel = db.query(Hotel).filter(Hotel.id == listing_id).first()
    if hotel:
        hotel.is_approved = True
        db.commit()
        return {"detail": "Listing approved"}
    raise HTTPException(status_code=404, detail="Listing not found")

@router.delete("/listings/{listing_id}")
def remove_listing(
    listing_id: int,
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    hotel = db.query(Hotel).filter(Hotel.id == listing_id).first()
    if hotel:
        db.delete(hotel)
        db.commit()
        return {"detail": "Listing removed"}
    raise HTTPException(status_code=404, detail="Listing not found")

@router.put("/payments/{payment_id}/void", response_model=PaymentResponse)
def void_payment(
    payment_id: int,
    data: VoidRequest,
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    payment = db.query(Payment).filter(Payment.id == payment_id).first()
    if payment:
        payment.status = PaymentStatus.voided
        payment.notes = data.reason
        db.commit()
        db.refresh(payment)
        return PaymentResponse.model_validate(payment)
    raise HTTPException(status_code=404, detail="Payment not found")

@router.get("/user-packages", response_model=dict)
def get_user_packages(
    status: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    _: Admin = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    query = db.query(UserPackage)
    if status:
        query = query.filter(UserPackage.status == status)
    total = query.count()
    items = query.order_by(UserPackage.id.desc()).offset((page - 1) * limit).limit(limit).all()
    return {
        "items": [UserPackageResponse.model_validate(item) for item in items],
        "total": total,
        "page": page,
        "limit": limit,
    }


@router.get("/stats")
def get_stats(_: Admin = Depends(get_current_admin), db: Session = Depends(get_db)):
    users_count = db.query(User).count()
    bookings_count = db.query(Booking).count()
    payments = db.query(Payment).all()
    total_revenue = sum(p.amount for p in payments if p.status == PaymentStatus.completed)
    active_packages = db.query(UserPackage).filter(
        UserPackage.status == PackageStatus.active
    ).count()
    
    return {
        "users": users_count,
        "bookings": bookings_count,
        "revenue": total_revenue,
        "active_packages": active_packages,
    }
