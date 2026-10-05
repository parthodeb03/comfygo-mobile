from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional
from ...core.database import get_db
from ...models.transport import Transport
from ...schemas.transport import TransportCreate, TransportUpdate, TransportResponse
from ..deps import get_current_admin

router = APIRouter(prefix="/transports", tags=["transports"])

@router.get("", response_model=dict)
def get_transports(
    search: Optional[str] = None,
    type: Optional[str] = None,
    from_location: Optional[str] = None,
    to_location: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
):
    query = db.query(Transport).filter(Transport.is_approved == True)
    
    if search:
        query = query.filter(Transport.name.ilike(f"%{search}%"))
    if type:
        query = query.filter(Transport.type == type)
    if from_location:
        query = query.filter(Transport.from_location.ilike(f"%{from_location}%"))
    if to_location:
        query = query.filter(Transport.to_location.ilike(f"%{to_location}%"))
    
    total = query.count()
    transports = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [TransportResponse.model_validate(t) for t in transports],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/{transport_id}", response_model=TransportResponse)
def get_transport(transport_id: int, db: Session = Depends(get_db)):
    transport = db.query(Transport).filter(Transport.id == transport_id).first()
    if not transport:
        raise HTTPException(status_code=404, detail="Transport not found")
    return TransportResponse.model_validate(transport)


@router.post("", response_model=TransportResponse)
def create_transport(
    transport: TransportCreate,
    _admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    db_transport = Transport(
        **transport.model_dump(),
        # Fresh services are fully seat-available
        available_seats=transport.total_seats,
    )
    db.add(db_transport)
    db.commit()
    db.refresh(db_transport)
    return TransportResponse.model_validate(db_transport)


@router.put("/{transport_id}", response_model=TransportResponse)
def update_transport(
    transport_id: int,
    updates: TransportUpdate,
    _admin=Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    transport = db.query(Transport).filter(Transport.id == transport_id).first()
    if not transport:
        raise HTTPException(status_code=404, detail="Transport not found")

    for key, value in updates.model_dump(exclude_unset=True).items():
        setattr(transport, key, value)
    db.commit()
    db.refresh(transport)
    return TransportResponse.model_validate(transport)
