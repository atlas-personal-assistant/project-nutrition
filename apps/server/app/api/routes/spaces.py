from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
import random
import string

from app.core.database import get_db
from app.models.models import Space, SpaceMembership

router = APIRouter()

class SpaceCreate(BaseModel):
    name: str
    
class SpaceResponse(BaseModel):
    id: int
    name: str
    invite_code: str
    owner_user_id: int
    status: str
    created_at: str
    
    class Config:
        orm_mode = True

class JoinSpace(BaseModel):
    invite_code: str

def generate_invite_code():
    """Generate a random 6-character invite code"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

@router.post("/", response_model=SpaceResponse)
async def create_space(space_data: SpaceCreate, db: Session = Depends(get_db)):
    # For now: hardcode owner_user_id to 1 (should come from auth token)
    owner_id = 1
    
    # Generate unique invite code
    invite_code = generate_invite_code()
    while db.query(Space).filter(Space.invite_code == invite_code).first():
        invite_code = generate_invite_code()
    
    new_space = Space(
        name=space_data.name,
        invite_code=invite_code,
        owner_user_id=owner_id,
        status="active"
    )
    db.add(new_space)
    db.commit()
    db.refresh(new_space)
    
    # Add owner as member
    membership = SpaceMembership(
        space_id=new_space.id,
        user_id=owner_id,
        role="owner",
        status="active"
    )
    db.add(membership)
    db.commit()
    
    return new_space

@router.get("/", response_model=list[SpaceResponse])
async def get_spaces(db: Session = Depends(get_db)):
    spaces = db.query(Space).all()
    return spaces

@router.post("/join", response_model=SpaceResponse)
async def join_space(join_data: JoinSpace, db: Session = Depends(get_db)):
    space = db.query(Space).filter(Space.invite_code == join_data.invite_code).first()
    if not space:
        raise HTTPException(status_code=404, detail="Invalid invite code")
    
    # For now: hardcode user_id to 1
    user_id = 1
    
    # Check if already member
    existing = db.query(SpaceMembership).filter(
        SpaceMembership.space_id == space.id,
        SpaceMembership.user_id == user_id
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Already a member")
    
    # Add membership
    membership = SpaceMembership(
        space_id=space.id,
        user_id=user_id,
        role="member",
        status="active"
    )
    db.add(membership)
    db.commit()
    
    return space

@router.get("/{space_id}", response_model=SpaceResponse)
async def get_space(space_id: int, db: Session = Depends(get_db)):
    space = db.query(Space).filter(Space.id == space_id).first()
    if not space:
        raise HTTPException(status_code=404, detail="Space not found")
    return space