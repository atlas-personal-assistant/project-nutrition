# Nutrition App — Architektur-Dokumentation

## Tech Stack
- **Frontend:** Flutter 3.x mit Riverpod + GoRouter
- **Backend:** FastAPI (Python 3.11)
- **Datenbank:** SQLite (lokal im Container)
- **Auth:** JWT Tokens mit bcrypt
- **Netzwerk:** Dio (Flutter) ↔ FastAPI

## Projektstruktur
```
project-nutrition/
├── apps/
│   ├── client/              # Flutter App
│   │   ├── lib/
│   │   │   ├── core/       # Router, Theme, API Config
│   │   │   ├── features/
│   │   │   │   ├── auth/   # Login, Register, Providers
│   │   │   │   ├── home/   # HomeScreen, Tabs
│   │   │   │   └── space/  # Spaces, Join, Create
│   │   │   └── main.dart   # App Entry Point
│   │   └── build/          # APK Output
│   └── server/             # FastAPI Backend
│       ├── app/
│       │   ├── api/routes/ # Auth, Spaces, Users
│       │   ├── core/       # Database, Security
│       │   └── models/     # SQLAlchemy Models
│       ├── data/           # SQLite DB
│       └── requirements.txt
└── memory/                 # Dokumentation
```

## Auth Flow (geplant)
1. Flutter: User gibt Email/Passwort ein
2. POST `/api/v1/auth/login` → JWT Token
3. Token in SharedPreferences speichern
4. Bei jedem Request: `Authorization: Bearer {token}`
5. Token expiriert nach 30 Minuten

## Space Flow (geplant)
1. User erstellt Space → POST `/api/v1/spaces/`
2. Server generiert Invite-Code
3. Anderer User: POST `/api/v1/spaces/join` mit Code
4. Mitgliedschaft wird in DB gespeichert

## Bekannte Probleme
- Docker Port-Mapping für 8000 fehlt
- Flutter App noch offline (local auth)
- Kein HTTPS (nur HTTP für Development)

## Nächste Features
- [ ] Server-Anbindung für Auth
- [ ] Server-Anbindung für Spaces
- [ ] Profil bearbeiten
- [ ] Kalorien/Schritte Tracking
- [ ] Admin Dashboard

---
*Stand: 2026-08-17*