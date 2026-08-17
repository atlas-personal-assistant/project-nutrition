from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from core.database import get_db
from core.security import get_current_user
import models.models as models
import random
import string

router = APIRouter()

# Pydantic Models
class SpaceCreate(BaseModel):
    name: str
    description: str = ""

class SpaceJoin(BaseModel):
    join_code: str

class SpaceResponse(BaseModel):
    id: int
    name: str
    description: str | None
    join_code: str
    
    class Config:
        from_attributes = True

def generate_join_code():
    """Generiert einen 6-stelligen alphanumerischen Code"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

@router.post("/create", response_model=SpaceResponse)
def create_space(
    space_data: SpaceCreate, 
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Join Code generieren (unique)
    join_code = generate_join_code()
    while db.query(models.Space).filter(models.Space.join_code == join_code).first():
        join_code = generate_join_code()
    
    # Space erstellen
    new_space = models.Space(
        name=space_data.name,
        description=space_data.description,
        join_code=join_code
    )
    
    db.add(new_space)
    db.commit()
    db.refresh(new_space)
    
    # Ersteller als Admin hinzufügen
    member = models.SpaceMember(
        user_id=current_user.id,
        space_id=new_space.id,
        role="admin"
    )
    db.add(member)
    db.commit()
    
    return new_space

@router.post("/join", response_model=SpaceResponse)
def join_space(
    join_data: SpaceJoin,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Space finden
    space = db.query(models.Space).filter(models.Space.join_code == join_data.join_code.upper()).first()
    
    if not space:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Ungültiger Join Code"
        )
    
    # Prüfen ob User bereits Mitglied
    existing = db.query(models.SpaceMember).filter(
        models.SpaceMember.user_id == current_user.id,
        models.SpaceMember.space_id == space.id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Du bist bereits Mitglied dieses Spaces"
        )
    
    # Als Mitglied hinzufügen
    member = models.SpaceMember(
        user_id=current_user.id,
        space_id=space.id,
        role="member"
    )
    db.add(member)
    db.commit()
    
    return space

@router.get("/list")
def list_spaces(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Alle Spaces des Users
    memberships = db.query(models.SpaceMember).filter(
        models.SpaceMember.user_id == current_user.id
    ).all()
    
    spaces = []
    for membership in memberships:
        space = db.query(models.Space).filter(models.Space.id == membership.space_id).first()
        if space:
            spaces.append({
                "id": space.id,
                "name": space.name,
                "description": space.description,
                "join_code": space.join_code,
                "role": membership.role,
                "joined_at": membership.joined_at
            })
    
    return spaces
