from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime
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

class JoinSpace(BaseModel):
    invite_code: str = None
    join_code: str = None
    
    def get_code(self):
        return self.invite_code or self.join_code or ''

def generate_invite_code():
    """Generate a random 6-character invite code"""
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def space_to_dict(space):
    """Convert SQLAlchemy Space object to dictionary"""
    return {
        "id": space.id,
        "name": space.name,
        "invite_code": space.invite_code,
        "owner_user_id": space.owner_user_id,
        "status": space.status,
        "created_at": str(space.created_at)
    }

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
    
    return space_to_dict(new_space)

@router.get("/", response_model=list[SpaceResponse])
async def get_spaces(db: Session = Depends(get_db)):
    spaces = db.query(Space).all()
    return [space_to_dict(s) for s in spaces]

@router.post("/join", response_model=SpaceResponse)
async def join_space(join_data: JoinSpace, db: Session = Depends(get_db)):
    code = join_data.get_code()
    space = db.query(Space).filter(Space.invite_code == code).first()
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
    
    return space_to_dict(space)

# Alias Endpunkte für Flutter Client
@router.post("/create", response_model=SpaceResponse)
async def create_space_alias(space_data: SpaceCreate, db: Session = Depends(get_db)):
    return await create_space(space_data, db)

@router.get("/list", response_model=list[SpaceResponse])
async def get_spaces_alias(db: Session = Depends(get_db)):
    return await get_spaces(db)

@router.get("/{space_id}", response_model=SpaceResponse)
async def get_space(space_id: int, db: Session = Depends(get_db)):
    space = db.query(Space).filter(Space.id == space_id).first()
    if not space:
        raise HTTPException(status_code=404, detail="Space not found")
    return space_to_dict(space)
