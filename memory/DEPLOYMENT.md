# Nutrition App API Deployment — Protokoll

**Datum:** 2026-08-17  
**Status:** ✅ ERFOLGREICH

## Probleme & Lösungen

### Problem 1: Docker-Dateien konnten nicht direkt kopiert werden
`docker cp` zwischen Containern wird nicht unterstützt.

### Problem 2: Datenbank-Initialisierung schlägt fehl
**Fehler:** `sqlite3.OperationalError: unable to open database file`
**Ursache:** Das Verzeichnis `/app/data` fehlt — SQLite kann die DB-Datei nicht erstellen, wenn das Verzeichnis nicht existiert.
**Lösung:** Verzeichnis VORHER erstellen: `mkdir -p /app/data /app/logs && chmod 777 /app/data /app/logs`

### Problem 3: SQLAlchemy mit relativem Pfad schlägt fehl
**Fehler:** `unable to open database file` trotz existierendem Verzeichnis
**Ursache:** SQLAlchemy braucht absoluten Pfad in Docker
**Lösung:** `sqlite:///app/data/nutrition.db` → `sqlite:////app/data/nutrition.db` (drei Slash)

### Problem 4: bcrypt/Passlib Inkompatibilität
**Fehler:** `(trapped) error reading bcrypt version` / `ValueError: password cannot be longer than 72 bytes`
**Ursache:** bcrypt 5.0.0 ist inkompatibel mit passlib 1.7.4
**Lösung:** Downgrade auf `bcrypt==4.0.1`
```bash
docker exec nutrition-server bash -c "pip install bcrypt==4.0.1 passlib==1.7.4"
```

## Wichtiger Hinweis

**Reihenfolge ist entscheidend:**
1. Container starten (mit `tail -f /dev/null` damit er läuft)
2. Dateien kopieren
3. **`/app/data` und `/app/logs` Verzeichnisse erstellen!**
4. Dependencies installieren
5. Datenbank initialisieren (erst nach Schritt 3!)
6. Server starten

## Lösung: Zwei-Stufen-Kopie

### Schritt 1: Dateien vom OpenClaw-Container auf den VPS-Host kopieren
```bash
docker cp openclaw-3qyl-openclaw-1:/tmp/nutrition-backend /root/nutrition-backend
```
Ergebnis: `Successfully copied 20kB to /root/nutrition-backend`

### Schritt 2: Vom VPS-Host in den Ziel-Container kopieren
```bash
docker cp /root/nutrition-backend/. nutrition-server:/app/
```
Ergebnis: `Successfully copied 8.83kB (transferred 20kB) to nutrition-server:/app/`

### Schritt 3: Dependencies installieren & DB initialisieren
```bash
docker exec nutrition-server bash -c "cd /app && pip install -q -r requirements.txt && python -c 'from core.database import init_db; init_db()'"
```

### Schritt 4: Server starten (im Hintergrund mit nohup)
```bash
docker exec -d nutrition-server bash -c "cd /app && nohup python -m uvicorn main:app --host 0.0.0.0 --port 8000 > /app/logs/server.log 2>&1 &"
```

**Wichtig:** Ohne `nohup` und `&` läuft der Server nur solange das Terminal offen ist!

## Test
```bash
curl http://187.124.23.28:8001/health
```
Erwartetes Ergebnis: `{"status":"healthy"}`

## API Endpunkte
- `GET /` → `{"message":"Nutrition App API laeuft!"}`
- `GET /health` → `{"status":"healthy"}`
- `POST /api/auth/register` → Registrierung
- `POST /api/auth/login` → Login
- `GET /api/auth/me` → Aktueller User
- `POST /api/spaces/create` → Space erstellen
- `POST /api/spaces/join` → Space beitreten
- `GET /api/spaces/list` → Spaces auflisten

## Container Info
- **Name:** nutrition-server
- **Image:** python:3.11-slim
- **Host Port:** 8001
- **Container Port:** 8000
- **Dateien:** /app/

## Nächste Schritte
1. Flutter App API-URL auf `http://187.124.23.28:8001` umstellen
2. Auth Provider auf Server-API umstellen
3. Space Provider auf Server-API umstellen
4. SECRET_KEY in production ändern (aktuell: `***`)
