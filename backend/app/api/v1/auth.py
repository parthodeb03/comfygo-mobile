from fastapi import APIRouter, Depends, HTTPException, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from ...core.config import settings
from ...core.database import get_db
from ..deps import Principal, get_current_principal, require_non_admin
from ...services.auth_service import (
    authenticate_user,
    create_access_token,
    create_refresh_token,
    create_user,
    get_password_hash
)
from ...schemas.user import (
    LoginRequest,
    RegisterRequest,
    AuthResponse,
    UserResponse,
    ForgotPasswordRequest
)
from ...models.user import User, UserRole

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/login", response_model=AuthResponse)
def login(request: LoginRequest, db: Session = Depends(get_db)):
    user = authenticate_user(db, request.email, request.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    access_token = create_access_token(data={"sub": str(user.id), "role": user.role.value})
    refresh_token = create_refresh_token(data={"sub": str(user.id), "role": user.role.value})
    
    return AuthResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserResponse.model_validate(user)
    )

@router.post("/register", response_model=AuthResponse)
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    # Admin accounts are created internally — never through public signup
    if request.role == UserRole.admin:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot self-register as admin",
        )

    # Check if email exists
    existing_user = db.query(User).filter(User.email == request.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered"
        )
    
    user = create_user(
        db,
        email=request.email,
        password=request.password,
        full_name=request.full_name,
        phone=request.phone or "",
        role=request.role.value,
        address=request.address,
        nationality=request.nationality,
        bio=request.bio,
        languages=request.languages,
        specialization=request.specialization,
        experience=request.experience,
        daily_rate=request.daily_rate
    )
    
    access_token = create_access_token(data={"sub": str(user.id), "role": user.role.value})
    refresh_token = create_refresh_token(data={"sub": str(user.id), "role": user.role.value})
    
    return AuthResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserResponse.model_validate(user)
    )

@router.post("/forgot-password")
def forgot_password(request: ForgotPasswordRequest):
    # In production, send email with reset link
    return {"detail": "Password reset email sent"}

@router.post("/refresh", response_model=dict)
def refresh(request: dict, db: Session = Depends(get_db)):
    """Issue a new access token for a valid refresh token.

    The Flutter ApiClient calls this automatically when it receives a 401.
    """
    token = request.get("refresh_token")
    if not token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="refresh_token is required",
        )

    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        user_id = payload.get("sub")
        role = payload.get("role", "user") or "user"
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    if role == "admin":
        from ...models.user import Admin

        admin = db.query(Admin).filter(Admin.id == int(user_id)).first()
        if not admin:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Admin not found",
            )
        return {
            "access_token": create_access_token(
                data={"sub": str(admin.id), "role": "admin"}
            ),
            "token_type": "bearer",
        }

    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    access_token = create_access_token(
        data={"sub": str(user.id), "role": user.role.value}
    )
    return {
        "access_token": access_token,
        "token_type": "bearer",
    }

@router.get("/profile", response_model=UserResponse)
def get_profile(principal: Principal = Depends(get_current_principal)):
    if principal.is_admin:
        assert principal.admin is not None
        return UserResponse(
            id=principal.admin.id,
            email=principal.admin.email,
            full_name=principal.admin.full_name,
            phone="",
            role="admin",
            created_at=principal.admin.created_at,
        )
    return UserResponse.model_validate(principal.user)

@router.put("/profile", response_model=UserResponse)
def update_profile(
    data: dict,
    principal: Principal = Depends(get_current_principal),
    db: Session = Depends(get_db),
):
    require_non_admin(principal)
    current_user = principal.user

    # Only allow updating safe, mutable fields
    allowed_fields = {
        "full_name", "phone", "address", "nationality", "bio",
        "languages", "specialization", "experience", "daily_rate",
    }
    for key, value in data.items():
        if key in allowed_fields and value is not None:
            setattr(current_user, key, value)

    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return UserResponse.model_validate(current_user)
