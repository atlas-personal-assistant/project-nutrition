#!/bin/bash
# AUF DEM VPS AUSFÜHREN — Ein Befehl, alles fertig

docker run -d \
  --name nutrition-server \
  -p 8001:8000 \
  -v /root/nutrition-data:/app/data \
  python:3.11-slim \
  bash -c "
    mkdir -p /app/api/routes /app/core /app/models /app/data /app/logs
    
    cat > /app/requirements.txt << 'REQEOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
pydantic==2.5.2
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
REQEOF

    cat > /app/main.py << 'PYEOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import auth, spaces

app = FastAPI(title='Nutrition App API', version='0.4.0')
app.add_middleware(CORSMiddleware, allow_origins=['*'], allow_credentials=True, allow_methods=['*'], allow_headers=['*'])
app.include_router(auth.router, prefix='/api/auth', tags=['Authentication'])
app.include_router(spaces.router, prefix='/api/spaces', tags=['Spaces'])

@app.get('/')
def root(): return {'message': 'Nutrition App API laeuft!'}

@app.get('/health')
def health_check(): return {'status': 'healthy'}
PYEOF

    cat > /app/core/database.py << 'DBEOF'
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

SQLALCHEMY_DATABASE_URL = 'sqlite:///app/data/nutrition.db'
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={'check_same_thread': False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()

def init_db(): Base.metadata.create_all(bind=engine)
DBEOF

    cat > /app/core/security.py << 'SECEOF'
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from core.database import get_db
import models.models as models

SECRET_KEY = 'nutrit…2345'
ALGORITHM = 'HS256'
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 30

pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
oauth2_scheme = OAuth2PasswordBearer(tokenUrl='api/auth/login')

def verify_password(plain_password, hashed_password): return pwd_context.verify(plain_password, hashed_password)
def get_password_hash(password): return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({'exp': expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Could not validate credentials', headers={'WWW-Authenticate': 'Bearer'})
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get('sub')
        if user_id is None: raise credentials_exception
    except JWTError: raise credentials_exception
    user = db.query(models.User).filter(models.User.id == int(user_id)).first()
    if user is None: raise credentials_exception
    return user
SECEOF

    cat > /app/models/models.py << 'MODEOF'
from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from core.database import Base
import datetime

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    spaces = relationship('SpaceMember', back_populates='user')

class Space(Base):
    __tablename__ = 'spaces'
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String, nullable=True)
    join_code = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    members = relationship('SpaceMember', back_populates='space')

class SpaceMember(Base):
    __tablename__ = 'space_members'
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    space_id = Column(Integer, ForeignKey('spaces.id'))
    role = Column(String, default='member')
    joined_at = Column(DateTime, default=datetime.datetime.utcnow)
    user = relationship('User', back_populates='spaces')
    space = relationship('Space', back_populates='members')
MODEOF

    cat > /app/api/routes/auth.py << 'ATHEOF'
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel
from sqlalchemy.orm import Session
from core.database import get_db, init_db
from core.security import verify_password, get_password_hash, create_access_token, get_current_user
import models.models as models

router = APIRouter()

class UserRegister(BaseModel):
    username: str
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str = 'bearer'

class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    class Config: from_attributes = True

@router.post('/register', response_model=Token)
def register(user_data: UserRegister, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter((models.User.username == user_data.username) | (models.User.email == user_data.email)).first()
    if db_user: raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Username oder Email bereits vergeben')
    new_user = models.User(username=user_data.username, email=user_data.email, hashed_password=get_password_hash(user_data.password))
    db.add(new_user); db.commit(); db.refresh(new_user)
    return {'access_token': create_access_token(data={'sub': str(new_user.id)}), 'token_type': 'bearer'}

@router.post('/login', response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.username == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Falscher Username oder Passwort', headers={'WWW-Authenticate': 'Bearer'})
    return {'access_token': create_access_token(data={'sub': str(user.id)}), 'token_type': 'bearer'}

@router.get('/me', response_model=UserResponse)
def get_me(current_user: models.User = Depends(get_current_user)): return current_user
ATHEOF

    cat > /app/api/routes/spaces.py << 'SPEOF'
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from core.database import get_db
from core.security import get_current_user
import models.models as models
import random, string

router = APIRouter()

class SpaceCreate(BaseModel):
    name: str
    description: str = ''

class SpaceJoin(BaseModel):
    join_code: str

class SpaceResponse(BaseModel):
    id: int
    name: str
    description: str | None
    join_code: str
    class Config: from_attributes = True

def generate_join_code(): return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

@router.post('/create', response_model=SpaceResponse)
def create_space(space_data: SpaceCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    join_code = generate_join_code()
    while db.query(models.Space).filter(models.Space.join_code == join_code).first(): join_code = generate_join_code()
    new_space = models.Space(name=space_data.name, description=space_data.description, join_code=join_code)
    db.add(new_space); db.commit(); db.refresh(new_space)
    db.add(models.SpaceMember(user_id=current_user.id, space_id=new_space.id, role='admin')); db.commit()
    return new_space

@router.post('/join', response_model=SpaceResponse)
def join_space(join_data: SpaceJoin, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    space = db.query(models.Space).filter(models.Space.join_code == join_data.join_code.upper()).first()
    if not space: raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Ungueltiger Join Code')
    if db.query(models.SpaceMember).filter(models.SpaceMember.user_id == current_user.id, models.SpaceMember.space_id == space.id).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Du bist bereits Mitglied dieses Spaces')
    db.add(models.SpaceMember(user_id=current_user.id, space_id=space.id, role='member')); db.commit()
    return space

@router.get('/list')
def list_spaces(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    return [{'id': s.space.id, 'name': s.space.name, 'description': s.space.description, 'join_code': s.space.join_code, 'role': s.role, 'joined_at': s.joined_at}
            for s in db.query(models.SpaceMember).filter(models.SpaceMember.user_id == current_user.id).all()
            if s.space]
SPEOF

    touch /app/core/__init__.py /app/models/__init__.py /app/api/__init__.py /app/api/routes/__init__.py
    
    pip install -q -r /app/requirements.txt
    python -c 'import sys; sys.path.insert(0, \'/app\'); from core.database import init_db; init_db(); print(\"DB OK\")'
    
    # Server starten (im Vordergrund, damit der Container läuft)
    exec python -m uvicorn main:app --host 0.0.0.0 --port 8000 --app-dir /app
  "
