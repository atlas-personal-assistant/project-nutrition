from sqlalchemy import Column, Integer, String, DateTime, Boolean
from sqlalchemy.sql import func
from app.core.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    display_name = Column(String, nullable=False)
    status = Column(String, default="active")  # active, inactive, banned
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class Space(Base):
    __tablename__ = "spaces"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    invite_code = Column(String, unique=True, index=True)
    owner_user_id = Column(Integer, nullable=False)
    status = Column(String, default="active")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

class SpaceMembership(Base):
    __tablename__ = "space_memberships"
    
    id = Column(Integer, primary_key=True, index=True)
    space_id = Column(Integer, nullable=False)
    user_id = Column(Integer, nullable=False)
    role = Column(String, default="member")  # owner, admin, member
    status = Column(String, default="active")
    joined_at = Column(DateTime(timezone=True), server_default=func.now())