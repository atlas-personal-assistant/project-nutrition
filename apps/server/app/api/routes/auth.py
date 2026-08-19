from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
from app.core.security import verify_password, get_password_hash, create_access_token
from app.models.models import User

router = APIRouter()

class UserCreate(BaseModel):
    email: str
    password: str
    display_name: str
    
class UserLogin(BaseModel):
    email: str
    password: str
    
class UserResponse(BaseModel):
    id: int
    email: str
    display_name: str
    status: str
    created_at: str
    
    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

@router.post("/register", response_model=Token)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    existing_user = db.query(User).filter(User.email == user_data.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Create user
    hashed_pw = get_password_hash(user_data.password)
    new_user = User(
        email=user_data.email,
        hashed_password=hashed_pw,
        display_name=user_data.display_name,
        status="active"
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Create token
    token = create_access_token({"sub": str(new_user.id)})
    
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": new_user.id,
            "email": new_user.email,
            "display_name": new_user.display_name,
            "status": new_user.status,
            "created_at": str(new_user.created_at)
        }
    }

@router.post("/login", response_model=Token)
async def login(credentials: UserLogin, db: Session = Depends(get_db)):
    # Try email first, then username (display_name)
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user:
        # Fallback: try login with display_name (for master account etc.)
        user = db.query(User).filter(User.display_name == credentials.email).first()
    
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    token = create_access_token({"sub": str(user.id)})
    
    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "display_name": user.display_name,
            "status": user.status,
            "created_at": str(user.created_at)
        }
    }

from fastapi import Request
from jose import JWTError, jwt
from app.core.security import SECRET_KEY, ALGORITHM

async def get_current_user_id(request: Request) -> int:
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    token = auth_header[7:]  # Remove "Bearer "
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return int(user_id)
    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid token")

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == current_user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {
        "id": user.id,
        "email": user.email,
        "display_name": user.display_name,
        "status": user.status,
        "created_at": str(user.created_at)
    }