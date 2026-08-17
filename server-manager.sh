#!/bin/bash
# Nutrition App Server Manager
# Ein umfassendes Management-Skript für den Nutrition Server
# Verwendung: ./server-manager.sh [setup|start|stop|restart|backup|logs|status|update|ssl]

set -e

# Konfiguration
CONTAINER_NAME="nutrition-server"
HOST_PORT="8001"
CONTAINER_PORT="8000"
API_SECRET="change-in-production"
BACKUP_DIR="/root/nutrition-backups"
LOG_DIR="/root/nutrition-logs"
DATA_DIR="/root/nutrition-data"
SSL_EMAIL="your-email@example.com"  # Für Let's Encrypt ändern
DOMAIN="your-domain.com"  # Für SSL ändern

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hilfsfunktionen
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Prüfen ob Docker läuft
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker läuft nicht! Bitte Docker starten."
        exit 1
    fi
}

# Prüfen ob Container läuft
is_container_running() {
    docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" | grep -q "$CONTAINER_NAME"
}

# ============================================
# SETUP - Einmalige Initialisierung
# ============================================
cmd_setup() {
    log_info "🚀 Nutrition App Server Setup"
    log_info "==============================="
    
    check_docker
    
    # Verzeichnisse erstellen
    mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$DATA_DIR"
    
    # Alten Container entfernen
    log_info "🧹 Aufräumen..."
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    
    # Neuen Container starten
    log_info "🐳 Container erstellen..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart=unless-stopped \
        -p "${HOST_PORT}:${CONTAINER_PORT}" \
        -v "$DATA_DIR:/app/data" \
        -v "$LOG_DIR:/app/logs" \
        python:3.11-slim \
        tail -f /dev/null
    
    sleep 2
    
    # Alle Dateien erstellen und installieren
    create_files
    install_dependencies
    init_database
    start_server
    create_master_user
    
    # Health-Check einrichten
    setup_health_check
    
    log_success "Setup abgeschlossen!"
    show_status
}

# ============================================
# DATEIEN ERSTELLEN
# ============================================
create_files() {
    log_info "📁 Dateien erstellen..."
    
    # Verzeichnisse
    docker exec "$CONTAINER_NAME" bash -c "mkdir -p /app/api/routes /app/core /app/models /app/data /app/logs && chmod 777 /app/data /app/logs"
    
    # requirements.txt
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/requirements.txt << 'REQEOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
pydantic==2.5.2
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
REQEOF"
    
    # main.py
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/main.py << 'PYEOF'
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
    
    # database.py (mit ABSOLUTEM Pfad!)
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/core/database.py << 'DBEOF'
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
    
    # security.py
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/core/security.py << 'SECEOF'
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from core.database import get_db
import models.models as models

SECRET_KEY = '$API_SECRET'
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
    
    # models.py
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/models/models.py << 'MODEOF'
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
    
    # auth.py
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/api/routes/auth.py << 'ATHEOF'
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
    
    # spaces.py
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/api/routes/spaces.py << 'SPEOF'
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
    
    # admin.py
    docker exec "$CONTAINER_NAME" bash -c "cat > /app/api/routes/admin.py << 'ADEOF'
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
    
    # __init__.py Dateien
    docker exec "$CONTAINER_NAME" bash -c "touch /app/core/__init__.py /app/models/__init__.py /app/api/__init__.py /app/api/routes/__init__.py"
}

# ============================================
# DEPENDENCIES INSTALLIEREN
# ============================================
install_dependencies() {
    log_info "📦 Dependencies installieren..."
    docker exec "$CONTAINER_NAME" bash -c "cd /app && pip install -q -r requirements.txt"
    docker exec "$CONTAINER_NAME" bash -c "pip install -q bcrypt==4.0.1 passlib==1.7.4"
}

# ============================================
# DATENBANK INITIALISIEREN
# ============================================
init_database() {
    log_info "🗄️  Datenbank initialisieren..."
    docker exec "$CONTAINER_NAME" bash -c "cd /app && python -c 'from core.database import init_db; init_db()'"
}

# ============================================
# SERVER STARTEN
# ============================================
start_server() {
    log_info "🚀 Server starten..."
    docker exec -d "$CONTAINER_NAME" bash -c "cd /app && nohup python -m uvicorn main:app --host 0.0.0.0 --port $CONTAINER_PORT > /app/logs/server.log 2>&1 &"
    sleep 3
}

# ============================================
# MASTER-USER ERSTELLEN
# ============================================
create_master_user() {
    log_info "👤 Master-User erstellen..."
    docker exec "$CONTAINER_NAME" bash -c "cd /app && python -c '
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
}

# ============================================
# HEALTH-CHECK EINRICHTEN
# ============================================
setup_health_check() {
    log_info "🏥 Health-Check einrichten..."
    
    # Cron-Job für Health-Check alle 5 Minuten
    (crontab -l 2>/dev/null || true; echo "*/5 * * * * $PWD/$0 health-check >> $LOG_DIR/health-check.log 2>&1") | crontab -
    
    log_success "Health-Check alle 5 Minuten eingerichtet"
}

# ============================================
# HEALTH-CHECK AUSFÜHREN
# ============================================
cmd_health_check() {
    if ! is_container_running; then
        log_warning "Container nicht läuft! Starte neu..."
        cmd_start
        return
    fi
    
    # API testen
    if ! curl -s -f "http://localhost:$HOST_PORT/health" >/dev/null 2>&1; then
        log_warning "API nicht erreichbar! Starte Server neu..."
        start_server
    fi
}

# ============================================
# BACKUP
# ============================================
cmd_backup() {
    log_info "💾 Backup erstellen..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/nutrition_backup_$TIMESTAMP.db"
    
    if docker exec "$CONTAINER_NAME" test -f /app/data/nutrition.db; then
        docker cp "$CONTAINER_NAME:/app/data/nutrition.db" "$BACKUP_FILE"
        log_success "Backup erstellt: $BACKUP_FILE"
        
        # Alte Backups löschen (nur die letzten 10 behalten)
        ls -t "$BACKUP_DIR"/nutrition_backup_*.db 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
    else
        log_warning "Keine Datenbank gefunden, nichts zu sichern"
    fi
}

# ============================================
# LOGS
# ============================================
cmd_logs() {
    if [ -f "$LOG_DIR/server.log" ]; then
        echo "=== Letzte 50 Zeilen ==="
        tail -50 "$LOG_DIR/server.log"
    else
        log_warning "Keine Log-Datei gefunden"
    fi
}

# ============================================
# STATUS
# ============================================
cmd_status() {
    echo "==============================="
    echo "📊 Server Status"
    echo "==============================="
    
    if is_container_running; then
        echo -e "Container: ${GREEN}läuft ✅${NC}"
        
        # API testen
        if curl -s -f "http://localhost:$HOST_PORT/health" >/dev/null 2>&1; then
            echo -e "API:       ${GREEN}erreichbar ✅${NC}"
        else
            echo -e "API:       ${RED}nicht erreichbar ❌${NC}"
        fi
    else
        echo -e "Container: ${RED}läuft nicht ❌${NC}"
    fi
    
    # DB-Größe
    if [ -f "$DATA_DIR/nutrition.db" ]; then
        DB_SIZE=$(du -h "$DATA_DIR/nutrition.db" | cut -f1)
        echo -e "Datenbank: ${BLUE}$DB_SIZE${NC}"
    fi
    
    # Backups
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/nutrition_backup_*.db 2>/dev/null | wc -l)
    echo -e "Backups:   ${BLUE}$BACKUP_COUNT${NC}"
    
    echo "==============================="
    echo "🔗 URL: http://localhost:$HOST_PORT"
    echo "📁 Daten: $DATA_DIR"
    echo "📁 Logs:  $LOG_DIR"
    echo "📁 Backups: $BACKUP_DIR"
}

# ============================================
# START
# ============================================
cmd_start() {
    if is_container_running; then
        log_warning "Container läuft bereits!"
        return
    fi
    
    log_info "Starte Container..."
    docker start "$CONTAINER_NAME" 2>/dev/null || {
        log_error "Container nicht gefunden. Bitte erst setup ausführen."
        exit 1
    }
    
    sleep 2
    start_server
    log_success "Server gestartet!"
}

# ============================================
# STOP
# ============================================
cmd_stop() {
    log_info "Stoppe Server..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    log_success "Server gestoppt"
}

# ============================================
# RESTART
# ============================================
cmd_restart() {
    log_info "Server wird neu gestartet..."
    cmd_stop
    sleep 2
    cmd_start
}

# ============================================
# UPDATE (nur Dateien aktualisieren, DB behalten)
# ============================================
cmd_update() {
    log_info "🔄 Update Server..."
    
    # Backup vor Update
    cmd_backup
    
    # Container neu starten
    docker restart "$CONTAINER_NAME"
    sleep 2
    
    # Dateien neu erstellen
    create_files
    install_dependencies
    
    # Server starten (DB bleibt erhalten)
    start_server
    
    log_success "Update abgeschlossen!"
}

# ============================================
# SSL/HTTPS EINRICHTEN
# ============================================
cmd_ssl() {
    log_info "🔒 SSL/HTTPS einrichten..."
    log_warning "Dies erfordert einen Domain-Namen!"
    
    if [ "$DOMAIN" = "your-domain.com" ]; then
        log_error "Bitte DOMAIN in diesem Skript anpassen!"
        echo "Aktuell: $DOMAIN"
        echo "Bitte ändern zu deiner echten Domain"
        exit 1
    fi
    
    # nginx als Reverse Proxy installieren
    log_info "nginx wird als Reverse Proxy eingerichtet..."
    
    # Dies ist ein Platzhalter - für echtes SSL braucht man:
    # 1. Domain die auf den VPS zeigt
    # 2. certbot für Let's Encrypt
    # 3. nginx Konfiguration
    
    log_warning "SSL Setup ist ein Platzhalter. Für echtes SSL:"
    echo "1. Domain auf VPS zeigen lassen"
    echo "2. certbot installieren: apt install certbot python3-certbot-nginx"
    echo "3. Zertifikat erstellen: certbot --nginx -d $DOMAIN"
    
    # Hier würde die echte SSL-Einrichtung kommen
}

# ============================================
# HILFE
# ============================================
show_help() {
    echo "Nutrition App Server Manager"
    echo "==============================="
    echo ""
    echo "Verwendung: $0 [BEFEHL]"
    echo ""
    echo "Befehle:"
    echo "  setup         - Einmalige Initialisierung"
    echo "  start         - Server starten"
    echo "  stop          - Server stoppen"
    echo "  restart       - Server neu starten"
    echo "  update        - Dateien aktualisieren (DB bleibt erhalten)"
    echo "  backup        - Datenbank sichern"
    echo "  logs          - Server-Logs anzeigen"
    echo "  status        - Status anzeigen"
    echo "  health-check  - Health-Check durchführen"
    echo "  ssl           - SSL/HTTPS einrichten (Platzhalter)"
    echo "  help          - Diese Hilfe"
    echo ""
    echo "Beispiele:"
    echo "  $0 setup      - Erstmalige Einrichtung"
    echo "  $0 status     - Status prüfen"
    echo "  $0 backup     - Backup erstellen"
}

# ============================================
# HAUPTPROGRAMM
# ============================================
main() {
    case "${1:-help}" in
        setup)
            cmd_setup
            ;;
        start)
            cmd_start
            ;;
        stop)
            cmd_stop
            ;;
        restart)
            cmd_restart
            ;;
        update)
            cmd_update
            ;;
        backup)
            cmd_backup
            ;;
        logs)
            cmd_logs
            ;;
        status)
            cmd_status
            ;;
        health-check)
            cmd_health_check
            ;;
        ssl)
            cmd_ssl
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unbekannter Befehl: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
