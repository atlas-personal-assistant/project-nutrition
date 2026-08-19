from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.api.routes import auth, spaces, users
from app.core.database import engine, Base

# Create tables
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Server starting up...")
    yield
    print("🛑 Server shutting down...")

app = FastAPI(
    title="Project Nutrition API",
    description="Backend API for Project Nutrition Flutter App",
    version="1.0.0",
    lifespan=lifespan
)

# CORS für Flutter App
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production: spezifische Domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(spaces.router, prefix="/api/v1/spaces", tags=["spaces"])
app.include_router(spaces.router, prefix="/api/spaces", tags=["spaces"])  # Alias für Flutter Client
app.include_router(users.router, prefix="/api/v1/users", tags=["users"])

@app.get("/")
async def root():
    return {"message": "Project Nutrition API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

from datetime import datetime