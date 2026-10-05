from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import Optional, List
from ...core.database import get_db
from ...models.destination import Destination
from ...schemas.destination import DestinationCreate, DestinationResponse

router = APIRouter(prefix="/destinations", tags=["destinations"])

@router.get("", response_model=dict)
def get_destinations(
    search: Optional[str] = None,
    division: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    query = db.query(Destination)
    
    if search:
        query = query.filter(Destination.name.ilike(f"%{search}%"))
    if division:
        query = query.filter(Destination.division == division)
    
    total = query.count()
    destinations = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "items": [DestinationResponse.model_validate(d) for d in destinations],
        "total": total,
        "page": page,
        "limit": limit
    }

@router.get("/featured", response_model=dict)
def get_featured_destinations(db: Session = Depends(get_db)):
    destinations = db.query(Destination).filter(Destination.is_featured == True).limit(10).all()
    return {
        "items": [DestinationResponse.model_validate(d) for d in destinations]
    }

@router.get("/{destination_id}", response_model=DestinationResponse)
def get_destination(destination_id: int, db: Session = Depends(get_db)):
    destination = db.query(Destination).filter(Destination.id == destination_id).first()
    if not destination:
        raise HTTPException(status_code=404, detail="Destination not found")
    return DestinationResponse.model_validate(destination)
