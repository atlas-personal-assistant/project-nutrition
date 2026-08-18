#!/bin/bash
# Nutrition Server - Auto-Start Script für OpenClaw Container
# Usage: ./start-local-server.sh [port]

PORT="${1:-8001}"
LOG_FILE="/tmp/nutrition-server.log"
PID_FILE="/tmp/nutrition-server.pid"
SERVER_DIR="/data/.openclaw/workspace/project-nutrition/apps/server"

echo "🚀 Starting Nutrition Server on port $PORT..."

# Kill existing server
if [ -f "$PID_FILE" ]; then
    kill $(cat "$PID_FILE") 2>/dev/null
    rm -f "$PID_FILE"
fi

# Start server
cd "$SERVER_DIR"
nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port $PORT > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

sleep 2

# Check if running
if curl -s "http://localhost:$PORT/health" >/dev/null 2>&1; then
    echo "✅ Server running on port $PORT"
    echo "   Health: http://localhost:$PORT/health"
    echo "   Public: http://$(curl -s ifconfig.me):$PORT/health"
else
    echo "❌ Server failed to start. Check logs: $LOG_FILE"
    exit 1
fi
