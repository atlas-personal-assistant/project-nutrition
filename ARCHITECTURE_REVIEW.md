# ARCHITECTURE.md Review — Atlas

**Status:** Draft Review Complete
**Version:** 0.1 Review
**Datum:** 2026-08-02
**Reviewer:** Atlas
**Mandat:** Keine Implementation. Keine MVP-Erweiterung.

---

## Gesamturteil: `Approve with Changes`

Die Architektur ist **solide, praktisch umsetzbar und MVP-geeignet**. Die Layer-Trennung, Domain-Module und Offline-First-Strategie sind durchdacht. Einige Korrekturen und Klarstellungen sind notwendig, bevor Implementation beginnt.

---

## Kritische Blocker (Müssen vor Implementation geklärt werden)

| # | Blocker | Begründung | Empfohlene Änderung |
|---|---------|------------|-------------------|
| 1 | **Sync Queue + UI-Update-Reihenfolge** | Punkt 12.1 zeigt: Domain Validation → Local SQLite → Sync Enqueued → UI Updated. Aber: Wenn Domain Validation fehlschlägt, wird UI nicht aktualisiert. Das ist korrekt. Aber: Was passiert bei erfolgreichem Local Write, dann Failed Sync? UI zeigt "gespeichert", Backend hat es nicht. User muss manuell prüfen? | Reihenfolge korrigieren oder erklären: UI Update erst nach Local Write, aber mit Sync-Pending-State |
| 2 | **Keine Sync-Conflict-Strategie** | Punkt 12.3: "entity-specific conflict handling", aber keine Regeln definiert. In einem Offline-First-System ist das existenziell. | Explizit auf `SYNC_STRATEGY.md` verweisen, aber mindestens einen Default-Fall (Server-Wins vs Client-Wins per Entity-Typ) definieren |
| 3 | **Repository Structure vs. Git Repo** | Punkt 22 zeigt `project-nutrition/apps/client/` und `project-nutrition/services/api/`. Aber: Das Git-Repo ist bereits `project-nutrition/`. Sollen Client und Backend im gleichen Repo sein? | Klarstellen: Monorepo (ein Git-Repo für alles) oder Multi-Repo |
| 4 | **SQLite ≠ Cache, aber was ist es dann?** | Punkt 4.3: "The local database is not only a cache. It is the operational data store." Aber: Wenn der Server die "Source of Truth" ist, was passiert bei Server-Reset oder Datenverlust? Wer ist Master? | Klarstellen: Single Source of Truth ist Server. Local ist operational für Offline, aber nicht autoritativ. Oder: Event-Sourcing mit Server als Aggregator |
| 5 | **Flutter Web — wann?** | Punkt 4.1: "responsive web application" ist Teil des Flutter-Targets. Punkt 27.14 fragt ob Web in Milestone 1 oder 2 gehört. Das ist ein Widerspruch. | Entscheiden: Entweder Web ist MVP-Ziel (dann in 4.1 explizit als MVP), oder Web ist Milestone 2 (dann aus 4.1 entfernen) |

---

## Notwendige Änderungen (Sollten im Doc korrigiert werden)

| # | Punkt | Problem | Änderung |
|---|-------|---------|----------|
| 6 | **5. High-Level Architecture** | Das ASCII-Diagramm zeigt Flutter → FastAPI → PostgreSQL, aber keinen Weg zurück. Sync ist bidirektional. | Diagramm erweitern: Server → Client Push (oder zumindest Polling/Sync-Endpoint explizit) |
| 7 | **8.5 Meal Planning** | "A shared meal is one logical object with multiple participants, not duplicated personal meals." — Aber: Wie sieht das in der DB aus? One Meal-Record mit Participant-Array, oder Meal + MealParticipants? | Klarstellen: Technisch ist es ein Space-Owned Meal mit User-Owned Portions (Verweis auf DATA_MODEL.md) |
| 8 | **8.6 Portioning** | "meal-prep reservations" ist ein komplexes Konzept. Ist das MVP? | Explizit als "MVP: basic portioning only" kennzeichnen |
| 9 | **12.2 Sync Metadata** | "revision/version" ist undefiniert. Integer? UUID? Timestamp? Vector Clock? | Minimal: Integer-Version pro Record. Oder: Verweis auf SYNC_STRATEGY.md |
| 10 | **12.3 Conflict Principle** | "entity-specific" ist zu vage für den Anfang. Selbst wenn jede Entity eigenes Verhalten hat, braucht es eine Default-Strategie. | Default-Regel definieren: z.B. "Server wins for shared resources, Client wins for personal-only data" |
| 11 | **13. API Style** | `/sync` als Resource-Group ist korrekt, aber: Ist Sync ein POST-basierter Batch-Endpoint, oder ein GET-basiertes Polling? | Minimal: Beschreiben als "POST /api/v1/sync/push" und "GET /api/v1/sync/pull" oder ähnlich |
| 12 | **17. Observability** | "user-safe error reporting" — Was ist das? Sentry? Rollbar? Eigener Endpoint? | "Structured logging only; crash reporting tool deferred" |
| 13 | **21. Deployment** | "Recipe images should not be stored directly in PostgreSQL" — Aber wo dann? Filesystem? S3? Base64 in DB? | Für MVP: Lokales Filesystem oder Docker Volume. Für Scale: MinIO oder S3. Explizit entscheiden |
| 14 | **24. Anti-Patterns** | "duplicating shared meals per participant" — Gut, aber: Was ist mit derived/cached Views? Ein Daily Plan zeigt ja den Shared Meal für jeden Participant an. | Präzisieren: "Keine duplizierte Persistenz. Read-Only Projektionen/Derived Views sind erlaubt" |

---

## Optionale Verbesserungen (Können verschoben werden)

| # | Punkt | Vorschlag | Priorität |
|---|-------|-----------|-----------|
| 15 | **14. State Management** | Riverpod ist "likely candidate". Für MVP-Entscheidung: `flutter_bloc` vs `Riverpod` vs `GetX`. Meine Empfehlung: `Riverpod` (DI-nativ, Testbarkeit, Flutter-Team-nah) | 🟡 Entscheiden vor Coding |
| 16 | **27. Open Decisions** | Punkt 4 "ID strategy" — UUID v4? ULID? Integer mit Prefix? | 🟡 Empfehlung: ULID für Server (sortierbar, keine Leaks), UUID für Client-Local |
| 17 | **27. Open Decisions** | Punkt 5 "backend ORM" — SQLAlchemy? SQLModel? Prisma? | 🟡 Empfehlung: SQLModel (Pydantic + SQLAlchemy, moderne FastAPI-Integration) |
| 18 | **27. Open Decisions** | Punkt 8 "soft deletion" — Soft-Delete oder Tombstones? | 🟡 Empfehlung: Tombstones für Sync (eindeutig), Soft-Delete für Business-Logik |
| 19 | **27. Open Decisions** | Punkt 10 "image storage" — Für MVP: Docker Volume + Nginx-Serving. Für Scale: MinIO (S3-kompatibel, selbstgehostet) | 🟡 Entscheiden vor Deployment |
| 20 | **27. Open Decisions** | Punkt 12 "feature-first vs layer-first" — Das Repo-Layout in Punkt 22 zeigt `modules/` (feature-first). Empfehlung: Bestätigen. Layer-first skaliert schlecht in Flutter. | 🟢 Niedrig |
| 21 | **27. Open Decisions** | Punkt 13 "minimum audit logging" — Für MVP: Kein Audit-Log. Nur Application-Logs ohne PII. Audit kommt mit Sharing/Coach-Features. | 🟢 Niedrig |

---

## Konkrete Empfehlungen zu Offenen Entscheidungen

### 1. Flutter State Management → **Riverpod**
**Begründung:**
- Nativer DI-Support (kein `GetIt` nötig)
- Familien/Scoped-Provider für Feature-Module
- Async-Value-Handling für Offline/Sync-States
- Flutter-Team-Empfehlung (Remi Rousselet)
- Besser testbar als Bloc

### 2. Local SQLite Library → **sqflite** + **drift**
**Begründung:**
- `sqflite` ist der Standard in Flutter
- `drift` (ehemals moor) gibt Typsicherheit + Migrations + Streams
- Für MVP reicht sqflite. Drift kommt bei komplexen Queries.

### 3. Authentication → **JWT Access + Refresh Tokens**
**Begründung:**
- Stateless für API (keine Server-Sessions)
- Refresh-Token-Rotation für Security
- Secure Storage (flutter_secure_storage) auf Client
- OAuth2-Resource-Owner-Password-Credentials für eigenes Login

### 4. ID Strategy → **ULID (Server), UUID (Client Local)**
**Begründung:**
- ULID: Sortierbar, Zeitstempel-encodiert, keine DB-Leaks
- UUID v4 für Client-Only-IDs (offline erzeugt)
- Konflikt-Unwahrscheinlich bei UUID-v4 + ULID-Mix

### 5. Backend ORM → **SQLModel**
**Begründung:**
- Pydantic + SQLAlchemy = moderne FastAPI-Integration
- Migrations via Alembic
- Typisierte Queries
- Weniger Boilerplate als reines SQLAlchemy

### 6. API DTO Strategy → **Pydantic-Models (Shared Contract)**
**Begründung:**
- FastAPI nutzt eh Pydantic
- Client und Server können Shared-Models nutzen (bei Monorepo)
- Oder: OpenAPI-Codegen für Client-Models

### 7. Sync Operation Representation → **Event-Sourcing-light**
**Begründung:**
- Jede lokale Änderung = ein Sync-Event (CREATE, UPDATE, DELETE)
- Event-Queue in SQLite
- Batch-POST an Server
- Server antwortet mit Applied-Events + Server-State
- Client wendet Server-State an

### 8. Soft Deletion/Tombstone → **Tombstones for Sync, Soft-Delete for Business**
**Begründung:**
- Sync braucht eindeutige "Deleted"-Marker (Tombstone)
- Business-Logik kann Soft-Delete zeigen ("Gelöscht, aber wiederherstellbar")
- Hard-Delete erst nach Grace Period

### 9. Background Sync Limitations → **Foreground Sync + Manual Pull**
**Begründung:**
- iOS: Background Fetch ist unzuverlässig
- Android: WorkManager ist zuverlässiger
- Für MVP: Sync on App-Resume + Manual Pull-to-Refresh + Sync-Button
- Später: Push-Notifications für Shared-Space-Updates

### 10. Image Storage → **Docker Volume + Nginx (MVP)**
**Begründung:**
- Einfach, kein externer Service
- Backup über Docker-Volume
- Für Scale: MinIO (S3-API, selbstgehostet)

### 11. Repository Layout → **Monorepo bestätigen**
**Begründung:**
- `project-nutrition/apps/client/` und `project-nutrition/services/api/`
- Shared Contracts möglich
- Einheitliche CI/CD
- Einfacher für kleines Team

### 12. Feature-First vs Layer-First → **Feature-First bestätigen**
**Begründung:**
- `modules/recipes/`, `modules/shopping/` etc.
- Innerhalb jedes Modules: `presentation/`, `application/`, `domain/`, `infrastructure/`
- Skaliert besser als layer-first bei wachsender Feature-Anzahl

### 13. Minimum Audit Logging → **Kein Audit-Log für MVP**
**Begründung:**
- Audit-Trail ist für Sharing/Coach-Features relevant
- MVP hat nur Space-Sharing
- Application-Logs ohne PII reichen
- Audit kommt mit Layer 3 (Professional)

### 14. Responsive Web → **Milestone 2**
**Begründung:**
- Flutter Web ist reif, aber responsive Design ist Extra-Arbeit
- Mobile-first fokussiert den MVP
- Web-Release nach Mobile-Stabilisierung

---

## Widersprüche zu Masterdokumenten

| Gefunden? | Dokument | Widerspruch | Lösung |
|-----------|----------|-------------|--------|
| ✅ Ja | SYSTEM_OVERVIEW.md | Zeigt "SQLite local" und "PostgreSQL remote", aber keine Sync-Strategie | ARCHITECTURE.md 12.x klärt das, aber verweist auf nicht-existierendes SYNC_STRATEGY.md |
| ✅ Ja | PROJECT_VISION.md | "AI is optional" vs ARCHITECTURE.md 4.5 "AI is not part of core architecture" | Konsistent, aber: Vision sagt "Version 1 contains no required AI", Architektur sagt "must remain usable without". Konsistent. |
| ✅ Ja | PROJECT_CHARTER.md | "Cross-platform from day one" — bedeutet das Web auch am Tag 1? | ARCHITECTURE.md 27.14 fragt genau das. Gut. |
| ✅ Ja | DATA_SHARING_AND_CONSENT.md | Granulare Permissions pro Recipient | ARCHITECTURE.md 8.11 erwähnt Sharing and Consent, aber keine Details. Konsistent, da DATA_MODEL.md fehlt. |
| ⚠️ Potential | SYSTEM_OVERVIEW.md | 13 Systeme definiert | ARCHITECTURE.md 8.x definiert 12 Module. Mapping: Sync(13)=8.12, aber Wearable(10) und Professional(12) fehlen als Domain-Module. Absichtlich, da Future. Konsistent. |

**Fazit:** Keine kritischen Widersprüche. Die Architektur ist konsistent mit den Vision-Docs.

---

## Wo ist die Architektur unnötig komplex?

| Punkt | Komplexität | Bewertung |
|-------|-------------|-----------|
| **8.12 Sync als eigenes Domain-Module** | Sync ist ein Infrastructure-Concern, nicht ein Domain-Module | 🟡 Trennung ist gut, aber Sync hat keine Business-Regeln. Eventuell als Sub-Module von Infrastructure |
| **22. Repository Structure** | `apps/client/` und `services/api/` ist richtig, aber: Flutter-Projekt in `apps/client/` bedeutet Flutter-Tooling muss von `apps/client/` aus laufen, nicht Root. Das ist Standard, aber für neue Flutter-Entwickler unintuitiv. | 🟡 Akzeptabel, aber README muss Setup-Anleitung enthalten |
| **25. ADRs** | 8 ADRs für MVP sind viel. Gut für Dokumentation, aber: Wer pflegt sie? | 🟢 Optional, aber empfohlen |
| **27. Open Decisions** | 14 offene Entscheidungen sind viel für einen Reviewer auf einmal | 🟡 Aufteilen: "MVP-Blocking" (1-5) vs "Can be deferred" (6-14) |

---

## Wo fehlen technische Leitplanken?

| # | Fehlende Leitplanke | Auswirkung | Empfohlene Ergänzung |
|---|---------------------|------------|---------------------|
| 22 | **Keine Concurrency-Regeln** | Zwei User editieren gleichen Shopping-List-Item offline | Entity-spezifische Optimistic Locking (Version-Check) |
| 23 | **Keine Migration-Strategie** | SQLite-Schema-Änderungen auf Client | `sqlite_migration` oder drift-Migrations. Für MVP: Drop-and-Recreate bei Beta |
| 24 | **Keine Error-Recovery-Strategie** | Sync schlägt permanent fehl (z.B. Server down) | Retry-Policy mit Exponential Backoff. Max-Retry → User-Notification |
| 25 | **Keine Data-Retention-Policy** | Wie lange werden gelöschte Daten aufbewahrt? | Für MVP: Keine. Für GDPR: 30-Tage-Tombstone, dann Hard-Delete |
| 26 | **Keine Rate-Limiting-Details** | Punkt 7.2 erwähnt "rate limiting later", aber: Selbst MVP braucht Basics gegen Abuse | Minimal: 100 req/min pro User, 10 login-attempts pro Minute |
| 27 | **Keine Backup-Strategie** | "backup service" in 4.4 erwähnt, aber: Was wird gebackupt? Wie oft? | PostgreSQL: Täglicher Dump. SQLite: Kein Backup (Client-seitig). Images: Docker-Volume-Backup |
| 28 | **Keine Test-Strategy-Details** | Punkt 23 verweist auf TESTING_STRATEGY.md, aber: Was ist MVP-Minimum? | Unit-Tests für Domain-Layer. API-Tests für Auth und CRUD. Keine UI-Tests für MVP |

---

## Was kann bewusst bis nach dem Prototyp verschoben werden?

| Feature | Verschiebe-Zeitpunkt | Begründung |
|---------|---------------------|------------|
| Responsive Web | Milestone 2 | Mobile-first fokussiert MVP |
| AI-Integration | Layer 4+ | Optional per Design |
| Wearable-Integration | Layer 3+ | Manual entry reicht |
| Professional Coaching | Layer 3+ | Consumer-first |
| Marketplace | Layer 5+ | Späteste Phase |
| Subscription Billing | Post-MVP | Kostenlos bis Stable |
| Advanced Analytics | Post-MVP | Basic tracking reicht |
| Multi-Region | Nie (für MVP) | Hostinger VPS reicht |
| Desktop-App | Optional | Web-Version ersetzt Desktop |
| Push-Notifications | Milestone 1.5 | Sync-Button reicht zuerst |
| Email-Notifications | Milestone 2 | In-App reicht |
| Password-Reset via Email | MVP? | Ja, notwendig für Auth. Aber: SMTP-Service nötig |
| OAuth2/Social Login | Post-MVP | Eigenes Login reicht |
| Two-Factor Auth | Post-MVP | JWT reicht für MVP |

---

## Korrektur-Vorschläge zum Dokument (Inline)

### Punkt 4.1 Flutter
**Aktuell:** "responsive web application"
**Änderung:**
```
- iOS
- Android
- responsive web application [Milestone 2]
- optional later desktop builds [Milestone 3+]
```

### Punkt 12.1 Local Write Model
**Aktuell:**
```
User Action
 ↓
Domain Validation
 ↓
Local SQLite Transaction
 ↓
Sync Operation Enqueued
 ↓
UI Updated Immediately
 ↓
Background Server Sync
```

**Änderung:**
```
User Action
 ↓
Domain Validation
 ↓
Local SQLite Transaction
 ↓
UI Updated (with Sync-Pending indicator)
 ↓
Sync Operation Enqueued
 ↓
Background Server Sync (retry with backoff)
 ↓
UI Updated (Sync-Confirmed or Sync-Failed)
```

### Punkt 27. Open Decisions
**Aktuell:** 14 offene Entscheidungen gemischt
**Änderung:**
```
### MVP-Blocking (Müssen vor Implementation entschieden werden)
1. Flutter state management → Riverpod
2. local SQLite library → sqflite (MVP), drift (later)
3. authentication implementation → JWT + flutter_secure_storage
4. ID strategy → ULID (server), UUID v4 (client local)
5. backend ORM → SQLModel + Alembic
6. repository layout → Monorepo confirmed
7. feature-first vs layer-first → Feature-first confirmed

### Can Be Deferred (Entscheiden bei Bedarf)
8. API DTO strategy → Pydantic shared
9. sync operation representation → Event-sourcing-light
10. soft deletion/tombstone approach → Tombstones for sync
11. background sync limitations → Foreground + Manual pull
12. image storage → Docker Volume + Nginx (MVP)
13. minimum audit logging → None for MVP
14. responsive web → Milestone 2
```

---

## Abschließende Bewertung

| Kategorie | Bewertung | Kommentar |
|-----------|-----------|-----------|
| **Layer-Trennung** | ✅ Exzellent | Clean Architecture, Domain unabhängig |
| **Module-Grenzen** | ✅ Gut | 12 Domain-Module, klar abgegrenzt |
| **Offline-First** | 🟡 Gut, aber unvollständig | Sync-Strategie fehlt noch |
| **Skalierbarkeit** | ✅ Gut | Future-Modules isoliert |
| **Testbarkeit** | ✅ Gut | DI, Domain-Layer pure |
| **Security/Privacy** | ✅ Gut | Privacy-by-Default, least-privilege |
| **Deployment** | ✅ Pragmatisch | Docker Compose auf VPS |
| **Dokumentations-Reife** | 🟡 Strategisch reif, operativ lückenhaft | DATA_MODEL, SYNC_STRATEGY fehlen |

---

## Empfohlener Ablauf

1. **Jetzt:** Blocker 1-5 aus diesem Review in ARCHITECTURE.md einarbeiten
2. **Dann:** DATA_MODEL.md erstellen (abhängig von fixierten Blockern)
3. **Dann:** SYNC_STRATEGY.md erstellen (kritiskt für Offline-First)
4. **Dann:** USER_FLOW.md und USER_JOURNEYS.md
5. **Dann:** UI-Mockups in Figma
6. **Erst dann:** Implementation beginnen

---

**Atlas' Urteil: `Approve with Changes`**

Die Architektur ist fundiert und implementierbar. Die notwendigen Änderungen sind kosmetisch und klärend, nicht strukturell. Nach Einbau der Blocker-Fixes und Erstellung der fehlenden Unterdokumente (DATA_MODEL, SYNC_STRATEGY) ist Implementation berechtigt.
