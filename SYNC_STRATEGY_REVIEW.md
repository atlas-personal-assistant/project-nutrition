# SYNC_STRATEGY.md Review — Atlas

**Status:** Draft Review Complete
**Version:** 0.1 Review
**Datum:** 2026-08-02
**Reviewer:** Atlas
**Mandat:** Keine Implementation. Keine MVP-Erweiterung.

---

## Gesamturteil: `Approve with Changes`

Die Sync-Strategie ist **pragmatisch, MVP-geeignet und vermeidet Überengineering**. Die Entscheidung gegen CRDTs/WebSockets/Real-Time ist korrekt für den Scope. Aber: Einige Lücken bei Conflict Resolution und Retry-Handling könnten zu User-Frustration führen.

---

## Kritische Anmerkungen

### 1. Source of Truth — Gut definiert ✅

**Aktuell:**
- Server: canonical for accounts, memberships, permissions
- Client: operational store for unsynchronized work
- Pending work remains visible
- No silent disappearance

**Bewertung:** Korrekt. Die Unterscheidung zwischen "canonical" (Server) und "operational" (Client) ist die richtige Wahl für MVP.

### 2. Sync Triggers — Pragmatisch ✅

**Aktuell:**
- after login
- on app start
- on app resume
- after important local writes when online
- on manual refresh
- before logout

**Bewertung:** Akzeptabel. Kein Background Sync ist eine bewusste Einschränkung, die iOS/Android-Complexität vermeidet.

**Aber:** "after important local writes when online" — was ist "important"? Wer entscheidet das?

**Empfehlung:** Definieren:
- **Immer sofort syncen:** Space-Änderungen (Meals, Shopping), da andere User betroffen
- **Batch-syncen:** Personal-Tracking (Weight, Steps), da nur local relevant
- **Deferred:** Bulk-Operations (viele Rezepte importieren)

### 3. Local Transaction — Sauber ✅

**Reihenfolge:**
1. validate domain rule
2. update local entity
3. add outbox operation
4. commit
5. update UI state

**Bewertung:** Korrekt. SQLite-Transaction umfasst Entity + Outbox = atomar.

**Aber:** Punkt 5 "update UI state" ist nicht Teil der Transaction. Was wenn UI-Update fehlschlägt?

**Empfehlung:** UI-Update ist Observer-Pattern (Stream/Reactive). Nicht manuell, sondern automatisch durch DB-Änderung getriggert.

### 4. Sync States — Gut, aber UI-Integration fehlt 🟡

**Aktuell:** local, pending, synced, conflict, failed

**Problem:** "Normal screens should avoid excessive icons." — Aber: Wie weiß der User, ob seine Änderung angekommen ist?

**Empfehlung:**
- **Subtil:** Kleiner Dot oder "Last synced: 2m ago" in Header/Profile
- **Explizit:** Bei Shared Items (Shopping, Meals) — "Pending"-Badge
- **Aktiv:** Sync-Status-Screen für Detail-Ansicht

### 5. Push Endpoint — Gut spezifiziert ✅

**Request/Response:**
- Batch of ordered operations
- Per-Operation Response: accepted, rejected_validation, rejected_authorization, conflict, duplicate_already_applied, temporary_failure

**Bewertung:** Korrekt. Die Granularität (pro Operation) ist wichtig für Retry.

**Aber:** Was ist der HTTP-Status-Code?
- 200 OK mit mixed responses?
- 207 Multi-Status?
- 409 Conflict wenn mindestens ein Conflict?

**Empfehlung:** 200 OK mit mixed responses im Body. Der Client muss sowieso jede Operation einzeln prüfen.

### 6. Pull Endpoint — Gut spezifiziert ✅

**Aktuell:** `GET /api/v1/sync/pull?cursor=<cursor>`

**Bewertung:** Korrekt. Cursor-basiert ist besser als Timestamp (wegen Race Conditions).

**Aber:** Was ist der `cursor`-Format? Integer? UUID? Base64-String?

**Empfehlung:** Cursor als opaque String (Base64-encoded JSON oder UUID). Nicht dokumentieren als "Integer" — Implementation kann wechseln.

### 7. Idempotency — Wichtig, aber nicht vollständig 🟡

**Aktuell:** "Outbox operation IDs are globally unique."

**Problem:** Woher kommt die Eindeutigkeit? UUIDv7? Wie stellt der Server sicher, dass er die ID noch nicht gesehen hat?

**Empfehlung:**
- Operation-ID = UUIDv7 (client-generiert)
- Server speichert verarbeitete Operation-IDs (TTL: 30 Tage)
- Bei Retry: Server prüft "schon gesehen?" → skipped/duplicate_already_applied

### 8. Revision Model — Integer, gut 🟡

**Aktuell:**
- Integer revisions
- Start bei 1
- Jede Mutation increment
- Client sendet `base_revision`
- Mismatch = Conflict

**Bewertung:** Pragmatisch. Einfacher als Vector Clocks.

**Aber:** Was passiert bei Server-Seitigen Änderungen (z.B. Admin-Import, Migration)?

**Empfehlung:** Server-Änderungen müssen auch Revision increments auslösen. Keine DB-Migration ohne Revision-Bump.

### 9. Default Conflict Rules — Gut strukturiert 🟡

| Regel | Bewertung |
|-------|-----------|
| Server-authoritative | ✅ Korrekt für Auth/Permissions |
| Append/coexist | ✅ Korrekt für Tracking |
| Optimistic concurrency | ✅ Korrekt für Shared Data |
| Simple field merge | 🟡 Risky — "clearly independent" ist subjektiv |

**Problem:** "Simple field merge allowed" — Wer definiert "clearly independent"?

**Beispiel:** Shopping Item:
- User A ändert `quantity` (1 → 2)
- User B ändert `checked` (false → true)

Sind das "independent fields"? Ja, technisch. Aber: Was wenn `quantity` geändert wird, während der andere User einkauft?

**Empfehlung:** Für MVP: **Kein automatic merge**. Stattdessen:
- Server rejectet bei Mismatch
- Client zeigt Conflict-UI
- User entscheidet

Später (Post-MVP): Feld-Level-Merging für spezifische Entities (Shopping Items).

### 10. Entity-Specific MVP Handling — Gut, aber unvollständig 🟡

**Shopping Item:** "Latest accepted server mutation wins if no other field changed." → Was ist "no other field changed"? Wie erkennt der Server das?

**Empfehlung:** Feld-Level-Revisionen? Oder: Shopping Items sind so simpel, dass Last-Write-Wins akzeptabel ist (User sieht sofort, kann korrigieren).

**Shared Meal:** "Conflicts remain visible and require refresh or retry." → Was bedeutet "remain visible"? In der App oder in einem speziellen Conflict-Screen?

**Empfehlung:**
- Shared Meal wird nicht gelöscht/überschrieben
- Stattdessen: "Outdated"-Badge
- Tap öffnet Conflict-Resolution
- Optionen: "Server-Version annehmen" / "Meine Version pushen (als neue Revision)" / "Abbrechen"

### 11. Retry Policy — Gut 🟡

**Aktuell:** 5s → 15s → 60s → 5min → 15min

**Bewertung:** Akzeptabel.

**Aber:** Was passiert nach 15min? Nochmal? Wie oft?

**Empfehlung:**
- Max 5 Retries
- Danach: "Failed"-State
- User-Notification: "Einige Änderungen konnten nicht synchronisiert werden"
- Manual Retry-Button

### 12. User Recovery — Gut, aber UI-spezifisch 🟡

**Aktuell:** Sync-Status-Area mit:
- pending count
- last successful sync
- conflicts
- permanent failures
- retry action

**Empfehlung:**
- "Sync-Status" als eigenständiger Screen (nicht nur Badge)
- Einstellungen → Sync & Offline → Status anzeigen
- Conflicts als Liste (nicht nur Zahl)
- "Discard" nur nach Bestätigung ("Wirklich verwerfen? Diese Daten gehen verloren.")

### 13. Offline Authentication — Gut ✅

**Aktuell:** Previously authenticated user → offline access while local session valid

**Frage:** Wie lange ist "local session valid"?

**Empfehlung:**
- Access Token: 15min (im Memory)
- Refresh Token: 7 Tage (in Secure Storage)
- Offline-Nutzung: Unbegrenzt (solange Token nicht expired)
- Bei Token-Ablauf: "Login required" (nur Online)

### 14. Deletion and Tombstones — Gut ✅

**Aktuell:**
- Deletion → Tombstone
- Tombstones pull to clients
- Hard deletion deferred
- Cleanup policy later

**Bewertung:** Korrekt.

**Aber:** Wie lange Tombstones aufbewahren?

**Empfehlung:**
- Server: 90 Tage (für Sync von Offline-Clients)
- Client: Permanent (damit User weiß, was gelöscht wurde)
- Hard-Delete: Nach 90 Tagen + User-Request

### 15. Security — Gut ✅

**Aktuell:** Auth, AuthZ, no client trust, no sensitive logs

**Empfehlung:** Ergänzen:
- HTTPS mit TLS 1.3
- Certificate Pinning (optional für MVP)
- Rate Limiting: 100 req/min pro User

### 16. MVP Non-Goals — Exzellent ✅

**Explizit ausgeschlossen:**
- Real-time push
- WebSockets
- CRDTs
- Vector clocks
- P2P sync
- Full event sourcing
- Automatic semantic conflict resolution

**Bewertung:** Korrekt. Diese Technologien wären Overengineering für MVP.

---

## Konsistenz-Check mit anderen Dokumenten

| Dokument | Status | Anmerkung |
|----------|--------|-----------|
| **ARCHITECTURE.md** | ✅ Konsistent | 12. Offline-First, 12.1 Local Write Model, 12.2 Sync Metadata → passen |
| **DATA_MODEL.md** | ✅ Konsistent | SyncOutboxOperation, SyncCursor, revision fields → passen |
| **USER_JOURNEYS.md** | ✅ Konsistent | Journey 4 (Shopping), Journey 8 (Offline) → abgedeckt |
| **USER_FLOW.md** | ✅ Konsistent | Punkt 10 (Offline/Conflict) → abgedeckt |

---

## Fehlende Details (Vorschläge)

| Punkt | Detail | Warum wichtig |
|-------|--------|---------------|
| **Cursor-Format** | Opaque String (Base64) | Implementation-Flexibilität |
| **Max Retry Count** | 5 Retries, dann Failed | Endlosschleife vermeiden |
| **Session-Lifetime** | 7 Tage Offline-Access | User-Experience |
| **Tombstone-TTL** | 90 Tage Server | Speicherplatz |
| **Conflict-UI Details** | Server/Local/Merge | User muss entscheiden können |
| **Bulk-Sync** | Initialer Download | Neuer User braucht alle Daten |
| **Delta-Sync** | Nur Änderungen seit Cursor | Bandbreite sparen |

---

## Empfohlene Änderungen (Inline)

### Punkt 2 — Source of Truth
**Ergänzen:**
```
Server is canonical for:
- accounts, memberships, permissions
- accepted shared revisions
- Space ownership

Client is operational for:
- unsynchronized local work
- offline reads
- pending writes

Conflict resolution:
- Server wins for permissions/ownership
- Optimistic concurrency for shared data
- User decision for complex conflicts
```

### Punkt 5 — Push Endpoint
**Ergänzen:**
```
HTTP Status: 200 OK (always, even with mixed responses)
Content-Type: application/json

Response includes per-operation:
- status: accepted | rejected | conflict | duplicate | temporary_failure
- server_revision (if accepted)
- error_code (if rejected/failed)
- error_message (user-safe)
```

### Punkt 6 — Pull Endpoint
**Ergänzen:**
```
Cursor format: opaque string (Base64-encoded JSON)
Client must not parse or assume cursor structure

Initial sync (no cursor): Full dump of visible records
Delta sync (with cursor): Only changes since cursor
```

### Punkt 9 — Default Conflict Rules
**Ändern:**
```
### Simple field merge

For MVP: Not implemented.
All conflicts are presented to the user for resolution.

Post-MVP: Field-level merge may be added for Shopping Items only.
```

### Punkt 10 — Entity-Specific Handling
**Ergänzen:**
```
### Shared Meal Conflict

UI behavior:
- Meal remains visible
- "Outdated" badge appears
- Tap opens conflict resolution
- Options: Accept Server / Push Local / Cancel

### Shopping Item Conflict

UI behavior:
- Item remains visible with pending state
- "Conflict" badge appears
- Options: Keep Server / Keep Local / Manual Merge
```

---

## Abschlussbewertung

| Kategorie | Bewertung | Kommentar |
|-----------|-----------|-----------|
| **Richtigkeit** | ✅ Exzellent | Pragmatisch, keine Overengineering |
| **Vollständigkeit** | 🟡 Gut | Einige UI/Retry-Details fehlen |
| **MVP-Fokus** | ✅ Exzellent | CRDTs/WebSockets explizit ausgeschlossen |
| **Conflict Handling** | 🟡 Ausreichend | Grundgerüst da, UI-Details fehlen |
| **Security** | ✅ Gut | Auth, AuthZ, keine sensiblen Logs |
| **Testbarkeit** | ✅ Gut | Accept Scenarios sind klar |
| **User-Experience** | 🟡 Gut | Aber: Silent Failures vermeiden |

---

## Atlas' Urteil: `Approve with Changes`

Die Sync-Strategie ist reif für Implementation nach folgenden Änderungen:

1. **Punkt 9:** Kein automatic merge für MVP (alles User-Resolution)
2. **Punkt 5:** HTTP 200 + mixed responses dokumentieren
3. **Punkt 6:** Cursor als opaque String definieren
4. **Punkt 11:** Max Retry Count definieren (5x)
5. **Punkt 13:** Offline Session Lifetime definieren (7 Tage)
6. **Punkt 14:** Tombstone TTL definieren (90 Tage)

Keine Blocker. Die Grundarchitektur (Push/Pull, Revisionen, Outbox) ist solide.
