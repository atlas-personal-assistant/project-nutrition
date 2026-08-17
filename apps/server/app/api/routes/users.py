from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.models.models import User

router = APIRouter()

@router.get("/")
async def get_users(db: Session = Depends(get_db)):
    users = db.query(User).all()
    return users