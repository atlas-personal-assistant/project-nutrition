#!/bin/bash
# Nutrition Server Watchdog - Auto-start & Auto-restart
# Läuft als Hintergrundprozess und stellt sicher, dass der Server immer läuft

PORT="${1:-8001}"
SERVER_DIR="/data/.openclaw/workspace/project-nutrition/apps/server"
LOG_FILE="/tmp/nutrition-server.log"
PID_FILE="/tmp/nutrition-server.pid"
WATCHDOG_LOG="/tmp/nutrition-watchdog.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$WATCHDOG_LOG"
}

log "🐕 Watchdog gestartet (Port: $PORT)"

while true; do
    # Prüfe ob Server läuft
    if ! curl -s "http://localhost:$PORT/health" >/dev/null 2>&1; then
        log "⚠️  Server nicht erreichbar, starte neu..."
        
        # Kill alten Prozess falls vorhanden
        if [ -f "$PID_FILE" ]; then
            kill $(cat "$PID_FILE") 2>/dev/null
            rm -f "$PID_FILE"
            sleep 2
        fi
        
        # Starte Server
        cd "$SERVER_DIR"
        nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port $PORT > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
        
        sleep 5
        
        if curl -s "http://localhost:$PORT/health" >/dev/null 2>&1; then
            log "✅ Server erfolgreich gestartet auf Port $PORT"
        else
            log "❌ Server-Start fehlgeschlagen, retry in 30s..."
            sleep 30
        fi
    fi
    
    # Prüfe alle 10 Sekunden
    sleep 10
done
