# USER_JOURNEYS.md Review — Atlas

**Status:** Draft Review Complete
**Version:** 0.1 Review
**Datum:** 2026-08-02
**Reviewer:** Atlas
**Mandat:** Keine Implementation. Keine MVP-Erweiterung.

---

## Gesamturteil: `Approve with Minor Changes`

Die User Journeys sind **praxisnah, klar geschrieben und MVP-geeignet**. Sie decken die Kern-Szenarien ab und geben eine gute Basis für UI-Mockups. Einige technische Präzisierungen und Edge-Case-Betrachtungen fehlen noch.

---

## Stärken

| Punkt | Bewertung |
|-------|-----------|
| **Journey 1 — Couple Setup** | Sehr gut. Invitation Code/Link ist praktikabel. Expliziter Erfolgsfall: "no private weight data exposed" |
| **Journey 3 — Portioning** | Herzstück der App. Gut beschrieben: finished weight → target portions → manual adjustment → actual portions |
| **Journey 4 — Offline Shopping** | Exzellent. Explizit: "no duplicate purchases caused by silent sync failure" — das ist ein echter Pain Point in Shared Lists |
| **Journey 5 — Weight Tracking** | Gut. "remains private" und "remains available offline" sind klare Anforderungen |
| **Journey 7 — Structured Program** | Als "Later MVP extension" markiert. Richtig, da komplexer |
| **Journey 8 — Offline Day** | Sehr wichtig. Zeigt, dass Offline nicht nur "lesen" ist, sondern auch schreiben |

---

## Kritische Anmerkungen & Fragen

### Journey 2 — Mixed Personal and Shared Day

**Frage:** "Michael creates a shared breakfast for both" — Wer setzt die Portionsgrößen? Michael allein, oder beide beim Erstellen?

**Technische Implikation:** Wenn Michael allein das Shared Meal erstellt, sind die Portions vordefiniert (z.B. 50/50). Wenn beide zusammen planen, braucht es einen "Planungsscreen" wo beide Portions angeben.

**Empfehlung:** Im Mockup zwei Modi zeigen:
- **Quick Create:** Ersteller setzt Portions, Partner akzeptiert
- **Collaborative Create:** Beide editieren Portions gleichzeitig (oder nacheinander)

### Journey 3 — Portioning

**Schritt 6:** "The app calculates target portions for each participant" — basierend auf was?

**Offene Frage:** Die Berechnung braucht Input:
- Gesamtgewicht (eingegeben)
- Ziel-Kalorien pro Person? Oder Ziel-Gramm?
- Wenn Ziel-Kalorien: Woher kommen die? Aus dem Profil (Tagesziel) oder aus dem Meal (Rezept-Kalorien pro 100g)?

**Empfehlung:** Präzisieren: "Basiert auf vordefinierten Anteilen (z.B. 60/40) oder auf individuellen Ziel-Kalorien"

### Journey 4 — Shopping

**Schritt 5-6:** "Offline changes remain visible locally. Changes synchronize later."

**Technische Anmerkung:** Was ist der Sync-Trigger? App-Resume? Manueller Sync-Button? Hintergrund?

**Empfehlung:** Im UI-Mockup einen "Sync-Button" oder "Last synced: 2 min ago"-Indikator zeigen.

### Journey 5 — Weight Tracking

**Schritt 3:** "Entry appears immediately" — Gut.

**Aber:** Was ist mit dem Trend? Wenn der Trend über 7 Tage oder 30 Tage berechnet wird, braucht es genug Datenpunkte. Bei erstmaliger Nutzung: Was zeigt der Trend an?

**Empfehlung:** Im Mockup: "Trend erscheint erst nach 3+ Einträgen" oder "Initial: Kein Trend, nur Liste"

### Journey 6 — Training and Steps

**Schritt 1:** "User creates or receives today's step target" — "receives" von wem? Space? Program? System?

**Empfehlung:** Präzisieren: "Setzt eigenes Ziel oder übernimmt aus Program/Space"

### Journey 7 — Structured Program

**Gut als "Later MVP extension" markiert.**

**Aber:** "App returns to the previous or maintenance plan" — Was ist der "maintenance plan"? Ist das ein persistierter Plan, oder implizit ("wie vor dem Programm")?

**Empfehlung:** Technisch: Snapshot des Plans vor Programm-Start, dann Restore. Oder: Programm-Plan überschreibt temporär, dann wieder Original.

### Journey 8 — Offline Day

**Schritt 8-9:** "App synchronizes. User sees confirmed state or clear conflict."

**Kritisch:** "Clear conflict" ist vage. Was zeigt die UI bei einem Conflict?

**Empfehlung:** Im Mockup einen "Conflict Resolution Screen" zeigen:
- "Server hat X, du hast Y"
- "Server gewinnt" / "Deine Version gewinnt" / "Manuell zusammenführen"

---

## Fehlende Journeys (Vorschläge)

| Journey | Warum relevant | MVP oder später? |
|---------|---------------|------------------|
| **Account Recovery** | Passwort vergessen, Gerät wechseln | MVP |
| **Space Verlassen / Löschen** | Beziehungsende, Umzug | MVP |
| **Rezept Erstellen/Bearbeiten** | Core Feature, aber nicht in Journeys | MVP |
| **Meal Prep (Mehrere Portionen)** | In Vision erwähnt, aber nicht in Journeys | Milestone 2 |
| **Einladung Ablehnen / Auslaufen** | Edge Case, aber wichtig | MVP |
| **Sync-Fehler Behebung** | Wenn Sync dauerhaft fehlschlägt | MVP |

---

## Technische Implikationen für Architecture/Data Model

### Aus Journey 1 (Couple Setup)
- **Entity:** Space hat Creator (User) + Members (Users)
- **Constraint:** Space-Name ist editierbar? Wer kann löschen?
- **Data Model:** Invitation Code = UUID? Expiry?

### Aus Journey 2 (Mixed Day)
- **Entity:** Meal hat Type (personal/shared), Participants (Array), Owner (User oder Space)
- **Constraint:** Shared Meal ohne Participants = ungültig
- **UI:** Daily Plan zeigt beide: Personal Meals + Shared Meals (als Referenz)

### Aus Journey 3 (Portioning)
- **Entity:** Meal → PortionSet (totalWeight, participants[], targetGrams[], actualGrams[], leftovers)
- **Berechnung:** Portion = (targetCalories / totalCalories) * totalWeight? Oder einfacher: Nutzer definiert Anteil (60/40)?
- **Data Model:** Target vs Actual als separate Felder

### Aus Journey 4 (Shopping)
- **Entity:** ShoppingList (Space-owned), Items (checked/unchecked, category, addedBy)
- **Sync:** Shopping-Items sind CRDT-freundlich (last-writer-wins pro Item ist akzeptabel)
- **Offline:** Lokale Queue von Operationen (add, check, delete)

### Aus Journey 5 (Weight)
- **Entity:** WeightEntry (user-owned, timestamp, value, unit=kg)
- **Privacy:** Nie Space-shared, außer expliziter Grant
- **Trend:** Client-seitige Berechnung aus lokalen Daten

### Aus Journey 6 (Training)
- **Entity:** StepTarget (user-owned, date, targetValue, actualValue)
- **Entity:** WorkoutSession (user-owned, date, type, completed)
- **Daily Plan:** Projektion von Meals + StepTargets + Workouts

### Aus Journey 7 (Program)
- **Entity:** ProgramTemplate (system-owned), UserProgram (user-owned, startDate, endDate, status)
- **Constraint:** Program überschreibt temporär den Daily Plan
- **Data Model:** Program-Tasks als separate Entität oder als markierte Meals/Workouts?

---

## Konsistenz-Check mit Architecture

| Journey | Arch-Anforderung | Status |
|---------|-----------------|--------|
| Journey 1 | Identity + Spaces Module | ✅ Abgedeckt |
| Journey 2 | Meal Planning + Shared Meals | ✅ Abgedeckt |
| Journey 3 | Portioning Module | ✅ Abgedeckt |
| Journey 4 | Shopping + Offline-First + Sync | 🟡 Sync-Strategie fehlt noch |
| Journey 5 | Tracking + Privacy + Offline | ✅ Abgedeckt |
| Journey 6 | Training + Daily Plan | ✅ Abgedeckt |
| Journey 7 | Programs Module | ✅ Als "later" markiert |
| Journey 8 | Offline-First + Sync | 🟡 Sync-Strategie fehlt noch |

---

## Empfohlene Änderungen zum Dokument

### 1. Journey 3 — Portioning (Schritt 6 präzisieren)

**Aktuell:**
> The app calculates target portions for each participant.

**Vorschlag:**
> The app calculates target portions for each participant based on their individual nutrition goals or predefined shares.

### 2. Journey 4 — Shopping (Sync-Trigger ergänzen)

**Aktuell:**
> Changes synchronize later.

**Vorschlag:**
> Changes synchronize automatically when online or via manual sync trigger.

### 3. Journey 8 — Offline Day (Conflict-UI ergänzen)

**Aktuell:**
> User sees confirmed state or clear conflict.

**Vorschlag:**
> User sees confirmed state. In case of conflict, the app presents a resolution screen (server version / local version / merge).

### 4. Neuer Journey: Account Recovery (MVP)

**Vorschlag einfügen:**
```
## Journey 9 — Account Recovery

1. User forgets password.
2. User requests reset via email.
3. User receives reset link.
4. User sets new password.
5. User remains logged in on other devices (optional).
6. User data is preserved.
```

---

## Abschlussbewertung

| Kategorie | Bewertung | Kommentar |
|-----------|-----------|-----------|
| **Vollständigkeit** | 🟡 Gut | 8 Journeys, aber Account Recovery fehlt |
| **Klarheit** | ✅ Exzellent | Jeder Schritt ist nachvollziehbar |
| **Erfolgskriterien** | ✅ Exzellent | Jedes Journey hat expliziten Success-State |
| **Offline-Berücksichtigung** | ✅ Gut | Journey 4 und 8 explizit |
| **Privacy-Berücksichtigung** | ✅ Gut | Journey 1 und 5 explizit |
| **Technische Präzision** | 🟡 Ausreichend | Einige Berechnungsdetails fehlen |
| **Mockup-Tauglichkeit** | ✅ Exzellent | Jeder Schritt ist UI-übersetzbar |

---

## Empfohlener Ablauf

1. **Jetzt:** Korrekturen einarbeiten (meine 4 Vorschläge oben)
2. **Dann:** Journey 9 (Account Recovery) hinzufügen
3. **Dann:** Figma-Mockups erstellen (ihr beide)
4. **Parallel:** DATA_MODEL.md erstellen (abhängig von Journeys)
5. **Parallel:** SYNC_STRATEGY.md erstellen (abhängig von Journey 4 + 8)

---

**Atlas' Urteil: `Approve with Minor Changes`**

Die Journeys sind solide und mockup-fertig. 4 kleine Präzisierungen und 1 neues Journey (Account Recovery) würden die Qualität erhöhen. Keine Blocker für UI-Phase.
