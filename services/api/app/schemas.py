from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional
from uuid import UUID

class UserCreate(BaseModel):
    email: EmailStr
    display_name: str

class UserResponse(BaseModel):
    id: UUID
    email: str
    display_name: str
    status: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True
