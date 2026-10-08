from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional
from ...core.database import get_db
from ...models.package import Package, UserPackage, PackageStatus
from ...schemas.package import PackageResponse, UserPackageCreate, UserPackageResponse
from ..deps import Principal, get_current_principal, require_non_admin

router = APIRouter(prefix="/packages", tags=["packages"])

@router.get("", response_model=dict)
def get_packages(db: Session = Depends(get_db)):
    packages = db.query(Package).order_by(Package.price).all()
    return {
        "items": [PackageResponse.model_validate(p) for p in packages]
    }

@router.get("/{package_id}", response_model=PackageResponse)
def get_package(package_id: int, db: Session = Depends(get_db)):
    package = db.query(Package).filter(Package.id == package_id).first()
    if not package:
        raise HTTPException(status_code=404, detail="Package not found")
    return PackageResponse.model_validate(package)

# User Package routes
user_package_router = APIRouter(prefix="/user-packages", tags=["user-packages"])


def _active_package(db: Session, user_id: int) -> Optional[UserPackage]:
    return db.query(UserPackage).filter(
        UserPackage.user_id == user_id,
        UserPackage.status == PackageStatus.active,
    ).first()


def _get_priced_package(db: Session, package_id: int) -> Package:
    package = db.query(Package).filter(Package.id == package_id).first()
    if not package:
        raise HTTPException(status_code=404, detail="Package not found")
    return package


def _validate_payment(package: Package, subscription: UserPackageCreate) -> None:
    """Paid plans need a payment method; card payments need card details."""
    if package.price <= 0:
        return
    method = (subscription.payment_method or "").lower()
    if method not in ("card", "cash"):
        raise HTTPException(
            status_code=400,
            detail="payment_method must be 'card' or 'cash' for paid plans",
        )
    if method == "card" and subscription.card_number != "4242424242424242":
        raise HTTPException(status_code=400, detail="Use the sandbox test card 4242 4242 4242 4242")


@user_package_router.get("/current", response_model=UserPackageResponse)
def get_current_package(
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)
    user_package = _active_package(db, principal.id)

    if not user_package:
        raise HTTPException(status_code=404, detail="No active package")

    return UserPackageResponse.model_validate(user_package)


@user_package_router.post("", response_model=UserPackageResponse)
def subscribe_to_package(
    subscription: UserPackageCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)

    existing = _active_package(db, principal.id)
    if existing:
        raise HTTPException(status_code=400, detail="Already have active package")

    package = _get_priced_package(db, subscription.package_id)
    _validate_payment(package, subscription)

    user_package = UserPackage(
        user_id=principal.id,
        package_id=package.id,
        start_date=datetime.utcnow(),
        end_date=datetime.utcnow() + timedelta(days=30),
        status=PackageStatus.active,
    )
    db.add(user_package)
    db.commit()
    db.refresh(user_package)

    return UserPackageResponse.model_validate(user_package)


@user_package_router.put("/upgrade", response_model=UserPackageResponse)
def upgrade_package(
    subscription: UserPackageCreate,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)

    current = _active_package(db, principal.id)
    if not current:
        raise HTTPException(status_code=404, detail="No active package to upgrade")

    new_package = _get_priced_package(db, subscription.package_id)
    if new_package.id == current.package_id:
        raise HTTPException(status_code=400, detail="Already on this package")
    _validate_payment(new_package, subscription)

    current.status = PackageStatus.expired
    upgraded = UserPackage(
        user_id=principal.id,
        package_id=new_package.id,
        start_date=datetime.utcnow(),
        end_date=datetime.utcnow() + timedelta(days=30),
        status=PackageStatus.active,
    )
    db.add(upgraded)
    db.commit()
    db.refresh(upgraded)

    return UserPackageResponse.model_validate(upgraded)


@user_package_router.put("/cancel")
def cancel_package(
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)

    user_package = _active_package(db, principal.id)
    if not user_package:
        raise HTTPException(status_code=404, detail="No active package")

    user_package.status = PackageStatus.cancelled
    db.commit()

    return {"detail": "Package cancelled"}
