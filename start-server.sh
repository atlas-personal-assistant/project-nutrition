#!/bin/bash
set -e

echo "🚀 Nutrition Server Deployment Script"
echo "======================================="

# Farben für Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Konfiguration
PROJECT_NAME="nutrition-server"
SERVER_PORT="8001"
DOCKER_IMAGE="nutrition-server:latest"
DATA_VOLUME="nutrition_data"

# Prüfe ob Docker läuft
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker läuft nicht!${NC}"
    echo "Starte Docker mit: sudo systemctl start docker"
    exit 1
fi

echo -e "${GREEN}✅ Docker läuft${NC}"

# Alten Container stoppen und entfernen (falls vorhanden)
if docker ps -a | grep -q "$PROJECT_NAME"; then
    echo -e "${YELLOW}⚠️  Alter Container gefunden, wird entfernt...${NC}"
    docker stop "$PROJECT_NAME" 2>/dev/null || true
    docker rm "$PROJECT_NAME" 2>/dev/null || true
    echo -e "${GREEN}✅ Alter Container entfernt${NC}"
fi

# Prüfe ob Image existiert, sonst baue es
if ! docker images | grep -q "$DOCKER_IMAGE"; then
    echo -e "${YELLOW}⚠️  Docker Image nicht gefunden, baue es...${NC}"
    
    # Prüfe ob Dockerfile existiert
    if [ ! -f "Dockerfile" ]; then
        echo -e "${RED}❌ Kein Dockerfile gefunden!${NC}"
        echo "Bitte stelle sicher, dass du im Projektverzeichnis bist."
        exit 1
    fi
    
    docker build -t "$DOCKER_IMAGE" .
    echo -e "${GREEN}✅ Image gebaut${NC}"
fi

# Starte den Container
echo -e "${YELLOW}🔄 Starte Server...${NC}"
docker run -d \
    --name "$PROJECT_NAME" \
    -p "$SERVER_PORT:8000" \
    -v "${DATA_VOLUME}:/app/data" \
    -e DATABASE_URL="sqlite:////app/data/nutrition.db" \
    -e SECRET_KEY="$(openssl rand -hex 32)" \
    --restart unless-stopped \
    "$DOCKER_IMAGE"

echo -e "${GREEN}✅ Container gestartet${NC}"

# Warte kurz und prüfe Health
echo -e "${YELLOW}⏳ Warte auf Server-Start...${NC}"
sleep 5

# Health Check
MAX_RETRIES=12
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s "http://localhost:$SERVER_PORT/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server läuft auf Port $SERVER_PORT!${NC}"
        echo ""
        echo "📊 Status:"
        docker ps | grep "$PROJECT_NAME"
        echo ""
        echo "🌐 URL: http://$(curl -s ifconfig.me):$SERVER_PORT"
        echo ""
        echo -e "${GREEN}🎉 Deployment erfolgreich!${NC}"
        exit 0
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo -e "${YELLOW}⏳ Versuch $RETRY_COUNT/$MAX_RETRIES...${NC}"
    sleep 5
done

echo -e "${RED}❌ Server startet nicht!${NC}"
echo "Prüfe die Logs: docker logs $PROJECT_NAME"
exit 1
