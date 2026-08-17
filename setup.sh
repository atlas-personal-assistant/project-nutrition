#!/bin/bash
# Nutrition App Server Setup Script
# Einmalig auf dem VPS ausführen: bash setup.sh
# Danach läuft alles automatisch

set -e

echo "🚀 Nutrition App Server Setup"
echo "==============================="

# Konfiguration
CONTAINER_NAME="nutrition-server"
HOST_PORT="8001"
CONTAINER_PORT="8000"
API_SECRET="change-me-in-production"

# Prüfen ob Docker läuft
if ! docker info &gt;/dev/null 2&gt;&amp;1; then
    echo "❌ Docker läuft nicht! Bitte Docker starten."
    exit 1
fi

# Alten Container entfernen (falls vorhanden)
echo "🧹 Aufräumen..."
docker rm -f $CONTAINER_NAME 2&gt;/dev/null || true

# Neuen Container starten (mit tail -f /dev/null damit er läuft)
echo "🐳 Container erstellen..."
docker run -d \
    --name $CONTAINER_NAME \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v /root/nutrition-data:/app/data \
    python:3.11-slim \
    tail -f /dev/null

# Warte bis Container bereit
sleep 2

# Verzeichnisse erstellen
echo "📁 Verzeichnisse erstellen..."
docker exec $CONTAINER_NAME bash -c "mkdir -p /app/api/routes /app/core /app/models /app/data /app/logs &amp;&amp; chmod 777 /app/data /app/logs"

# Requirements erstellen
echo "📦 Dependencies vorbereiten..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/requirements.txt &lt;&lt; 'REQEOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
pydantic==2.5.2
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
REQEOF"

# Wichtig: bcrypt 4.0.1 installieren (nicht 5.0.0 - inkompatibel mit passlib)
docker exec $CONTAINER_NAME bash -c "pip install -q bcrypt==4.0.1 passlib==1.7.4"

# main.py erstellen
echo "📝 main.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/main.py &lt;&lt; 'PYEOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api.routes import auth, spaces, admin

app = FastAPI(title='Nutrition App API', version='0.4.0')
app.add_middleware(CORSMiddleware, allow_origins=['*'], allow_credentials=True, allow_methods=['*'], allow_headers=['*'])

app.include_router(auth.router, prefix='/api/auth', tags=['Authentication'])
app.include_router(spaces.router, prefix='/api/spaces', tags=['Spaces'])
app.include_router(admin.router, prefix='/api/admin', tags=['Admin'])

@app.get('/')
def root(): return {'message': 'Nutrition App API laeuft!'}

@app.get('/health')
def health_check(): return {'status': 'healthy'}
PYEOF"

# database.py erstellen (mit ABSOLUTEM Pfad - wichtig!)
echo "📝 database.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/core/database.py &lt;&lt; 'DBEOF'
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

SQLALCHEMY_DATABASE_URL = 'sqlite:////app/data/nutrition.db'
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={'check_same_thread': False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()

def init_db(): Base.metadata.create_all(bind=engine)
DBEOF"

# security.py erstellen
echo "📝 security.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/core/security.py &lt;&lt; 'SECEOF'
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from core.database import get_db
import models.models as models

SECRET_KEY = '${API_SECRET}'
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
SECEOF"

# models.py erstellen
echo "📝 models.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/models/models.py &lt;&lt; 'MODEOF'
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
MODEOF"

# auth.py erstellen
echo "📝 auth.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/api/routes/auth.py &lt;&lt; 'ATHEOF'
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
ATHEOF"

# spaces.py erstellen
echo "📝 spaces.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/api/routes/spaces.py &lt;&lt; 'SPEOF'
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
SPEOF"

# admin.py erstellen
echo "📝 admin.py erstellen..."
docker exec $CONTAINER_NAME bash -c "cat &gt; /app/api/routes/admin.py &lt;&lt; 'ADEOF'
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session
from core.database import get_db
from core.security import get_current_user, get_password_hash, verify_password
import models.models as models

router = APIRouter()

class PasswordChange(BaseModel):
    old_password: str
    new_password: str

class PasswordReset(BaseModel):
    new_password: str

@router.get('/users')
def list_all_users(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.username != 'master':
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail='Nur Admin erlaubt')
    users = db.query(models.User).all()
    return [{'id': u.id, 'username': u.username, 'email': u.email, 'created_at': u.created_at} for u in users]

@router.delete('/users/{user_id}')
def delete_user(user_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.username != 'master':
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail='Nur Admin erlaubt')
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User nicht gefunden')
    db.delete(user); db.commit()
    return {'message': f'User {user.username} geloescht'}

@router.post('/change-password')
def change_password(pw_data: PasswordChange, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if not verify_password(pw_data.old_password, current_user.hashed_password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Altes Passwort falsch')
    current_user.hashed_password = get_password_hash(pw_data.new_password)
    db.commit()
    return {'message': 'Passwort geaendert'}

@router.post('/users/{user_id}/reset-password')
def reset_password(user_id: int, pw_data: PasswordReset, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    if current_user.username != 'master':
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail='Nur Admin erlaubt')
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='User nicht gefunden')
    user.hashed_password = get_password_hash(pw_data.new_password)
    db.commit()
    return {'message': f'Passwort fuer {user.username} zurueckgesetzt'}
ADEOF"

# __init__.py Dateien erstellen
echo "📝 __init__.py Dateien erstellen..."
docker exec $CONTAINER_NAME bash -c "touch /app/core/__init__.py /app/models/__init__.py /app/api/__init__.py /app/api/routes/__init__.py"

# Dependencies installieren
echo "📦 Dependencies installieren..."
docker exec $CONTAINER_NAME bash -c "cd /app && pip install -q -r requirements.txt"

# Datenbank initialisieren
echo "🗄️  Datenbank initialisieren..."
docker exec $CONTAINER_NAME bash -c "cd /app && python -c 'from core.database import init_db; init_db()'"

# Server starten
echo "🚀 Server starten..."
docker exec -d $CONTAINER_NAME bash -c "cd /app && nohup python -m uvicorn main:app --host 0.0.0.0 --port ${CONTAINER_PORT} &gt; /app/logs/server.log 2&gt;&amp;1 &amp;"

# Warte bis Server bereit
sleep 3

# Master-User erstellen
echo "👤 Master-User erstellen..."
docker exec $CONTAINER_NAME bash -c "cd /app && python -c '
import sys
sys.path.insert(0, \"/app\")
from core.database import SessionLocal
from core.security import get_password_hash
from models.models import User

db = SessionLocal()
master = db.query(User).filter(User.username == \"master\").first()
if not master:
    master = User(username=\"master\", email=\"master@nutrition.local\", hashed_password=get_password_hash(\"***\"))
    db.add(master)
    db.commit()
    print(\"Master-User erstellt!\")
else:
    print(\"Master-User existiert bereits!\")
db.close()
'"

# Testen
echo ""
echo "✅ Setup abgeschlossen!"
echo "==============================="
echo "🌐 API erreichbar unter: http://DEINE_VPS_IP:${HOST_PORT}"
echo "🔑 Master-User: master / ***"
echo ""
echo "📋 Nützliche Befehle:"
echo "  docker logs ${CONTAINER_NAME}         # Server-Logs anzeigen"
echo "  docker restart ${CONTAINER_NAME}    # Server neu starten"
echo "  docker exec -it ${CONTAINER_NAME} bash # In Container einsteigen"
echo ""
echo "🧪 Testen:"
echo "  curl http://DEINE_VPS_IP:${HOST_PORT}/health"
echo "  curl -X POST http://DEINE_VPS_IP:${HOST_PORT}/api/auth/login -d \"username=master&password=***\""
