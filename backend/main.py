from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import auth, spaces
import os

app = FastAPI(
    title="Nutrition App API",
    description="API für die Nutrition Tracking App",
    version="0.4.0"
)

# CORS für Flutter App (alle Origins erlaubt für Entwicklung)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers einbinden
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(spaces.router, prefix="/api/spaces", tags=["Spaces"])

@app.get("/")
def root():
    return {"message": "Nutrition App API läuft! 🚀"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
