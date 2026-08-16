import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Check if we're in Docker with PostgreSQL (environment variable set)
# Otherwise use SQLite for local development
database_url = os.getenv("DATABASE_URL")

if database_url:
    # Production: PostgreSQL
    DATABASE_URL = database_url
    engine = create_engine(DATABASE_URL)
else:
    # Development: SQLite
    DATABASE_URL = "sqlite:///./nutrition.db"
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def init_db():
    """Create all tables if they don't exist."""
    Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
