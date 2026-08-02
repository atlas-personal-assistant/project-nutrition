# Project Nutrition — Review V1.0

**Reviewer:** Atlas  
**Datum:** 2026-08-02  
**Umfang:** Struktur + 10 Masterdokumente  
**Status:** Nur Review, keine Implementation

---

## 1. Gesamturteil

**Klasse Arbeit.** Die Dokumentation ist durchdacht, konsistent und zeigt echtes Produktverständnis. Die Trennung in Consumer-MVP und spätere Plattform-Schichten ist architektonisch sauber. Die Privacy-by-Default-Philosophie und die deterministische Safety-Rule-Logik sind standout-Qualitäten.

**Kritische Schwäche:** Die Dokumente existieren als Einzeldateien ohne Verknüpfung. Ein zentrales Navigations-/Glossar-Dokument fehlt. Jemand der neu einsteigt, hat keine Chance den roten Faden zu finden.

---

## 2. Struktur-Review

### Was gut ist
- Klare Trennung: Vision → Mechanics → Systems → Implementation
- FEATURES/-Ordner ist modular und erweiterbar
- MEMORY/ für Entscheidungen und Ideen — praktisch
- AI_PRINCIPLES.md als expliziter Verhaltenscodex für mich

### Was fehlt oder problematisch ist

| # | Problem | Gewicht | Empfohlene Aktion |
|---|---------|---------|-------------------|
| 1 | **Kein zentrales Glossar** — Begriffe wie "Space", "Program", "Portioning" sind verteilt definiert | 🔴 Hoch | `TERMINOLOGY.md` oder Glossar-Sektion in README |
| 2 | **Kein Dokumentenverweis-System** — Die Docs verlinken nicht aufeinander | 🟡 Mittel | Querverweise in jedem Doc |
| 3 | **FEEDBACK_LOOP.md fehlt** — Kein Dokument für Review-Prozess zwischen dir, GPT und mir | 🟡 Mittel | Neues Doc erstellen |
| 4 | **ARCHITECTURE.md ist fast leer** — Nur 3 Zeilen. Das sollte das zentrale Architektur-Dok sein | 🔴 Hoch | Aus SYSTEM_OVERVIEW.md und TECH_STACK.md zusammenführen |
| 5 | **DATA_MODEL.md ist fast leer** — Nur 2 Zeilen. Bei diesem Komplexitätsgrad problematisch | 🔴 Hoch | Aus den einzelnen System-Descriptions extrahieren |
| 6 | **CURRENT_FOCUS.md ist fast leer** — Nur 2 Zeilen. Sprint-Steuerung unmöglich | 🟡 Mittel | Sprint-Ziele, Blocker, Next-Steps dokumentieren |
| 7 | **IMPLEMENTATION/Sprint01.md ist fast leer** — Nur 1 Zeile. Nicht verwendbar | 🔴 Hoch | Akzeptanzkriterien, Tasks, Definition of Done |
| 8 | **UI/-Dokumente sind fast leer** — DesignSystem.md, Navigation.md, Screens.md je 1 Zeile | 🟡 Mittel | Später bei Figma-Phase füllen |
| 9 | **USER_FLOW.md ist fast leer** — Nur 2 Zeilen. Kritisch für UI-Implementation | 🟡 Mittel | Screens + Flows definieren |
| 10 | **PROJECT_STATE.md ist fast leer** — Nur 2 Zeilen. Kein Projektstatus erkennbar | 🟡 Mittel | Aktuellen Status, Blocker, nächste Schritte |

### Dateigrößen-Verteilung (rote Flaggen)

```
Vollständige Docs (gut):
  PROJECT_CHARTER.md       — ca. 30 Zeilen
  PROJECT_VISION.md        — ca. 80 Zeilen
  DATA_SHARING_AND_CONSENT.md — ca. 100 Zeilen
  PROFESSIONAL_COACHING_PLATFORM.md — ca. 100 Zeilen
  WEARABLE_INTEGRATIONS.md — ca. 120 Zeilen

Leere Placeholder (kritisch):
  ARCHITECTURE.md          — 3 Zeilen
  DATA_MODEL.md            — 2 Zeilen
  CURRENT_FOCUS.md         — 2 Zeilen
  IMPLEMENTATION/Sprint01.md — 1 Zeile
  UI/DesignSystem.md        — 1 Zeile
  UI/Navigation.md          — 1 Zeile
  UI/Screens.md             — 1 Zeile
  USER_FLOW.md             — 2 Zeilen
  PROJECT_STATE.md         — 2 Zeilen
  CORE_MECHANICS.md        — 5 Zeilen (zusammenfassend, okay)
```

**Kritische Erkenntnis:** Die strategischen Docs (Vision, Charter, Sharing) sind ausgearbeitet. Die operativen Docs (Architektur, Datenmodell, Implementation) sind leere Placeholder. Das ist ein Pattern — die Konzeption ist reif, die Umsetzungsplanung noch nicht.

---

## 3. Inhalts-Review: Kritische Analyse

### 3.1 PROJECT_CHARTER.md ✅ Solide

**Stärken:**
- Klare Mission und Vision
- Realistische Success-Criteria ("Michael and his girlfriend prefer using it daily")
- Engineering Philosophy ist präzise (modular, clean separation, deterministic)
- Offline-first als explizites Prinzip

**Fragen:**
- "Cross-platform from day one" — bedeutet das Flutter, oder echte native iOS+Android+Web parallel?
- "AI is optional and never required" — wie wird das technisch garantiert? Feature-Flag oder Architektur-Trennung?

**Empfehlung:** Charter ist reif. Keine Änderungen nötig.

---

### 3.2 PROJECT_VISION.md ✅ Sehr gut

**Stärken:**
- Das "Shared Spaces"-Konzept ist das Herzstück und klar kommuniziert
- "Finished-meal portioning" statt "raw ingredient splitting" — echte Innovation, gut erklärt
- AI-Philosophie mit expliziten Verboten (medical advice, macro calculations)
- Safety-Rule-Non-Override als Hard Constraint

**Kritische Anmerkungen:**

| Zeile | Anmerkung |
|-------|-----------|
| "Nutrition and Training as One System" | Gut, aber wie verhindert man, dass Training zu komplex wird? Bei Fitness-Apps entgleitet das schnell |
| "Structured short-term diet programs" | Aggressive Diet Phases + Safety — das ist ein rechtliches Minenfeld. Braucht Disclaimer-Strategie |
| "Professional Marketplace" | Sehr spät (Phase 7) — gut. Aber: Wie verhindert man Architektur-Debt für spätere Coaching-Features? |

**Empfehlung:** Vision ist reif. Einziger Bedarf: Rechtliche Disclaimer-Strategie für Diet Programs definieren.

---

### 3.3 SYSTEM_OVERVIEW.md 🟡 Gut, aber inkonsistent

**Stärken:**
- Klare Layer-Architektur (Flutter → FastAPI → PostgreSQL)
- 13 Systeme identifiziert und nummeriert
- MVP-Scope explizit abgegrenzt

**Kritische Probleme:**

| # | Problem | Details |
|---|---------|---------|
| 1 | **Nummerierung inkonsistent** | Systeme 1-9 nummeriert, dann 10-13 ohne klare Reihenfolge. Ist System 10 (Wearable) höher priorisiert als System 5 (Shopping)? |
| 2 | **Layer-Architektur fehlt Tiefe** | "Flutter → FastAPI → PostgreSQL" ist eine Technologie-Stack, keine Architektur. Wo sind die Domain-Layers? |
| 3 | **Local Storage vs Server** | SQLite lokal, PostgreSQL server — aber keine Sync-Strategie definiert. Offline-first bedeutet: Wie werden Konflikte gelöst? |
| 4 | **Keine API-Grenzen** | FastAPI bedeutet REST. Aber: Wie sieht die API-Oberfläche aus? Ressourcen-basiert? |

**Empfehlung:** Überarbeiten und in ARCHITECTURE.md verschieben/fusionieren. Sync-Strategie offline/online explizit definieren.

---

### 3.4 CORE_MECHANICS.md 🟡 Zusammenfassend, aber braucht Tiefe

**Stärken:**
- Die 4 Cores sind logisch gruppiert
- "Cross-Cutting Rule" ist wichtig — Daily Plan als zentrale UX

**Probleme:**

| # | Problem |
|---|---------|
| 1 | **Zu hoch-level** — Keine Details zu State-Management, Berechnungslogik, oder Edge Cases |
| 2 | **"Shared meals with individual nutrition goals"** — Wie funktioniert das technisch? Partitionierung? Prozentuale Aufteilung? |
| 3 | **"selective sharing"** — Was ist der kleinste Shareable-Unit? Ein Meal? Ein Tag? Einzelne Macros? |

**Empfehlung:** Nicht als separates Doc, sondern als Einführung in ein tieferes MECHANICS/-Verzeichnis auflösen.

---

### 3.5 DATA_SHARING_AND_CONSENT.md ✅ Exzellent

**Stärken:**
- Granularitäts-Level ist durchdacht (per data type, per recipient, per Space, date range)
- `DataShareGrant`-Entität ist konkret
- "Derived vs Raw Data"-Unterscheidung ist architektonisch wichtig
- Revocation-Regeln sind vollständig

**Kritische Anmerkungen:**

| Zeile | Anmerkung |
|-------|-----------|
| "No recipient may gain access through role alone" | Gut, aber: Was passiert wenn ein Admin/Space-Owner die Regeln ändern will? |
| "preserve audit history where legally required" | Welche Jurisdiktion? GDPR? HIPAA? Das wirkt auf Gesundheitsdaten hinaus |

**Empfehlung:** Rechtsdomäne (EU-Datenschutz vs US-HIPAA) explizit definieren. Beeinflusst Audit- und Consent-Anforderungen massiv.

---

### 3.6 PROFESSIONAL_COACHING_PLATFORM.md ✅ Gut (für Zukunft)

**Stärken:**
- CoachingRelationship mit Status-Maschine (invited → active → paused → ended → revoked)
- Plan-Proposals statt direkter Overwrites — wichtig für Auditability
- Asynchron über Video — pragmatisch

**Probleme:**

| # | Problem |
|---|---------|
| 1 | **"professional_type" ist konfigurierbar** — Gut, aber: Wer konfiguriert? Admin? Self-declared? Verifikations-Prozess? |
| 2 | **"verification_status"** — Wer verifiziert? Plattform oder extern? Kosten? |
| 3 | **Rechtliche Haftung** | "The platform must not imply that every listed coach is medically qualified" — Aber wie wird das UI-seitig kommuniziert? |

**Empfehlung:** MVP-Architektur sollte `user_roles` und `recipient-specific sharing` vorbereiten, aber Coaching-UI nicht implementieren.

---

### 3.7 PROFESSIONAL_MARKETPLACE.md ✅ Gut (für später)

**Stärken:**
- Explizit als "later platform layer" deklariert
- Risiken sind ehrlich benannt (verification, liability, payment disputes)
- Development Order ist logisch

**Empfehlung:** Keine Änderungen nötig — ist strategisch, nicht operativ.

---

### 3.8 STRUCTURED_PROGRAMS.md 🟡 Braucht Safety-Tiefe

**Stärken:**
- "rule-based, transparent and bounded" — gut
- Daily Plan Integration ist UX-klug

**Kritische Probleme:**

| # | Problem |
|---|---------|
| 1 | **"minimum intake constraints"** — Was sind die Constraints? WHO-Richtlinien? Lokale Gesetze? |
| 2 | **"exclusion or caution flags for unsuitable users"** — Wer definiert "unsuitable"? System oder Nutzer-Selbstdeklaration? |
| 3 | **Rechtlicher Disclaimer fehlt** | "clear non-medical disclaimer" ist erwähnt, aber kein Text definiert |
| 4 | **"no AI override of safety rules"** — Gut, aber: Wer definiert die Safety Rules? Statisch oder konfigurierbar? |

**Empfehlung:** Safety-Regeln als eigenes Doc `SAFETY_CONSTRAINTS.md` auslagern. Rechtliche Haftung ist hier das größte Risiko.

---

### 3.9 TRAINING_AND_ACTIVITY.md 🟡 Gut, aber zu simpel

**Stärken:**
- TrainingPlan → TrainingSession → TrainingParticipant ist sauber
- Daily Plan Integration ist UX-klug

**Probleme:**

| # | Problem |
|---|---------|
| 1 | **"session_type" ist nicht enumeriert** — Was sind gültige Typen? strength, cardio, recovery, mixed? |
| 2 | **Kein Übungskatalog** — "exercise library" ist "Later Extension", aber ohne Katalog sind Workouts nur Text-Labels |
| 3 | **"target_volume" ist undeiniert** — Sets×Reps×Weight? Dauer? Distanz? |

**Empfehlung:** Für MVP: Session-Typen definieren und minimalen Übungskatalog (10-20 Übungen) festlegen.

---

### 3.10 WEARABLE_INTEGRATIONS.md ✅ Sehr gut

**Stärken:**
- `HealthDataProvider`-Abstraktion ist architektonisch korrekt
- Normalized Data Model (`HealthDataRecord`) ist durchdacht
- Source/Duplicate Handling ist realitätsnah
- Offline-Verhalten ist spezifiziert

**Probleme:**

| # | Problem |
|---|---------|
| 1 | **"confidence optional"** — Bei Health-Daten ist Confidence für Data Quality wichtig. Sollte nicht optional sein |
| 2 | **"is_user_editable"** — Wenn importierte Daten editierbar sind, entsteht eine weitere Vertrauensdomäne. Explizit entscheiden |
| 3 | **"data_origin" vs "source_provider"** — Redundant? Oder ist data_origin = "imported", "manual", "derived"? |

**Empfehlung:** HealthDataRecord-Felder finalisieren. `is_user_editable` für MVP auf `false` setzen (importierte Daten sind read-only).

---

## 4. Architektur-Kritik (Querzüge)

### 4.1 Offline-First + Sync

**Status:** Erwähnt in Charter und Wearable-Doc, aber nicht spezifiziert.

**Offene Fragen:**
- SQLite lokal, PostgreSQL remote — wie wird synchronisiert?
- Conflict Resolution: Last-Write-Wins oder User-Intervention?
- Was passiert bei Space-Änderungen durch zwei offline Nutzer?
- Sync-Granularität: Ganzes Daily Plan oder einzelne Items?

**Empfehlung:** `SYNC_STRATEGY.md` als neues Doc erstellen. Das ist eine der größten technischen Herausforderungen.

### 4.2 Deterministische Berechnungen

**Status:** Erwähnt in Charter, nicht spezifiziert.

**Fragen:**
- Nutrition Engine ist "deterministic" — aber wo sind die Formeln?
- Calorie-Ziele: Wer setzt sie? Nutzer manuell, oder berechnet das System?
- Wenn Nutzer manuell: Keine AI/Formel nötig. Wenn System: Wer haftet?

**Empfehlung:** `NUTRITION_ENGINE.md` mit expliziten Formeln und Berechnungsregeln.

### 4.3 Skalierbarkeit vs MVP

**Status:** Gutes Bewusstsein in Dokumenten ("must not delay core consumer product"), aber keine konkrete Architektur-Trennung.

**Empfehlung:** Explizite "Platform Layer"-Grenzen in Architektur definieren:
```
Layer 1: Consumer Core (MVP)
Layer 2: Sharing & Collaboration (Spaces)
Layer 3: Professional Features (Coaching)
Layer 4: Marketplace
```
Jede Layer darf nur auf darunterliegenden Layers aufbauen.

---

## 5. Fehlende Dokumente (Vorschläge)

| Dokument | Warum nötig | Priorität |
|----------|-------------|-----------|
| `ARCHITECTURE.md` (vollständig) | Aktuell leer. Zentrales technisches Dokument | 🔴 Kritisch |
| `DATA_MODEL.md` (vollständig) | Aktuell leer. Alle Entities und Beziehungen | 🔴 Kritisch |
| `SYNC_STRATEGY.md` | Offline-first ist Kernversprechen, aber ungespec't | 🔴 Kritisch |
| `NUTRITION_ENGINE.md` | Deterministische Berechnungen ohne Formeln | 🟡 Hoch |
| `SAFETY_CONSTRAINTS.md` | Diet-Programme ohne Safety-Rules sind Haftungsrisiko | 🟡 Hoch |
| `TERMINOLOGY.md` | Glossar für alle Begriffe (Space, Program, Portioning) | 🟡 Hoch |
| `USER_FLOW.md` (vollständig) | Aktuell leer. Kritisch für UI | 🟡 Hoch |
| `API_CONTRACT.md` | FastAPI ohne API-Spezifikation | 🟢 Mittel |
| `TESTING_STRATEGY.md` | Deterministische Berechnungen brauchen Tests | 🟢 Mittel |
| `DEPLOYMENT.md` | Hostinger VPS Setup | 🟢 Mittel |

---

## 6. Zusammenfassung: Blocker für Implementation

| # | Blocker | Lösung |
|---|---------|--------|
| 1 | ARCHITECTURE.md leer | Aus SYSTEM_OVERVIEW + TECH_STACK fusionieren |
| 2 | DATA_MODEL.md leer | Entities aus allen System-Docs extrahieren |
| 3 | Kein Sync-Strategie | Neues Doc erstellen |
| 4 | Safety-Rules für Diet-Programme undefiniert | Neues Doc erstellen |
| 5 | Keine UI/UX-Definition (Screens, Flows) | Auf Figma-Phase warten oder wireframes erstellen |

**Mein Urteil:** Die strategische Fundierung ist exzellent. Die operative Umsetzungsplanung fehlt weitgehend. Ich rate davon ab, mit Implementation zu beginnen, bevor ARCHITECTURE.md, DATA_MODEL.md und SYNC_STRATEGY.md gefüllt sind.

**Nächster Schritt nach meiner Sicht:**
1. ARCHITECTURE.md und DATA_MODEL.md erstellen/füllen
2. Sicherheits- und Sync-Strategie definieren
3. Erst dann zu UI-Mockups übergehen

---

**Fertig für dein Review.** Sag mir welche Punkte du vertiefen willst, welche du ignorierst, und ob ich bei der Doc-Erstellung helfen soll.
