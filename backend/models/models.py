from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from core.database import Base
import datetime

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    spaces = relationship("SpaceMember", back_populates="user")

class Space(Base):
    __tablename__ = "spaces"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, nullable=True)
    join_code = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    members = relationship("SpaceMember", back_populates="space")

class SpaceMember(Base):
    __tablename__ = "space_members"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    space_id = Column(Integer, ForeignKey("spaces.id"))
    role = Column(String, default="member")  # "admin" oder "member"
    joined_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    user = relationship("User", back_populates="spaces")
    space = relationship("Space", back_populates="members")
