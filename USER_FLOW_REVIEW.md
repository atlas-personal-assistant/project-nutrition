# USER_FLOW.md Review — Atlas

**Status:** Draft Review Complete
**Version:** 0.1 Review
**Datum:** 2026-08-02
**Reviewer:** Atlas
**Mandat:** Keine Implementation. Keine MVP-Erweiterung.

---

## Gesamturteil: `Approve with Minor Changes`

Der User Flow ist **klar strukturiert, navigierbar und mockup-fertig**. Die 14 Wireframe-Anforderungen decken die MVP-Screens ab. Einige UX-Details und Edge-Cases fehlen noch.

---

## Stärken

| Punkt | Bewertung |
|-------|-----------|
| **Navigation (Punkt 1)** | "Today, Planner, Recipes, Shopping, Progress" — 5 Tabs, clean und übersichtlich |
| **First Launch (Punkt 2)** | "Create Space / Join Space / Skip" — Skip ist wichtig für Onboarding-UX |
| **Today Screen (Punkt 3)** | Chronologische Reihenfolge, shared/private markers, sync indicator — alles wichtig |
| **Cooking Flow (Punkt 6)** | "Start Cooking → Steps → Finish → Weight → Allocations → Confirm" — logisch |
| **Conflict Flow (Punkt 10)** | "Keep server / retry local / manually resolve" — gut für MVP |
| **Wireframe-Liste (Punkt 11)** | 14 Screens, vollständig für MVP |

---

## Kritische Anmerkungen

### 1. Navigation — "Space Switcher" als Secondary Entry

**Aktuell:** "Space switcher" unter "Secondary entry points"

**Frage:** Wo genau ist der Space Switcher? In den Tabs? In der Top-Bar? Im Profile?

**Empfehlung:** Space Switcher im Header der Today-Seite (Dropdown oder Chip) — da ist der Space-Kontext am relevantesten.

### 2. Today Screen — "Sync indicator only when needed"

**Aktuell:** "sync indicator only when needed"

**Problem:** Was ist "needed"? Wenn pending? Wenn offline? Wenn conflict?

**Empfehlung:**
- **Immer sichtbar:** Kleiner "Last synced: 2m ago"-Text oder Icon in Header
- **Bei Pending:** Subtiler Dot auf Sync-Icon
- **Bei Conflict:** Roter Dot oder Badge
- **Bei Offline:** Grauer/Deaktivierter Zustand

### 3. Planner Flow — "Select day and meal slot"

**Aktuell:** "Week view → Select day and meal slot"

**Frage:** Ist das ein Kalender-Grid oder eine Listen-Ansicht?

**Empfehlung:** Für MVP: Horizontale Wochen-Leiste (Mo-So) + vertikale Tages-Liste (Breakfast, Lunch, Dinner, Snack). Kein Full-Calendar-Grid (zu komplex).

### 4. Planner Flow — "Choose participants"

**Aktuell:** "Choose participants"

**Problem:** Wann wird gefragt? Beim Erstellen des Meals oder später?

**Empfehlung:**
- **Default:** Wenn User in einem Space ist → Shared Meal (alle Space-Members)
- **Option:** User kann auf "Personal" umstellen
- **Bei Multi-Space:** Space-Auswahl zuerst, dann Participants

### 5. Recipe Flow — "Add to Planner" vs "Add ingredients to Shopping"

**Aktuell:** Beide Optionen aus Recipe Detail

**Frage:** Was passiert bei "Add ingredients to Shopping"? Werden alle Zutaten hinzugefügt oder nur fehlende?

**Empfehlung:**
- "Add to Shopping": Alle Zutaten werden zur Shopping List hinzugefügt (mit Checkbox "Schon vorhanden" für User)
- Später: Smart-Vorschlag ("Du hast schon Eier und Milch")

### 6. Cooking Flow — "Suggested allocations"

**Aktuell:** "Enter finished dish weight → Suggested allocations → Manual adjustment"

**Frage:** Wie werden die Allocations vorgeschlagen? 50/50? Basierend auf Ziel-Kalorien?

**Empfehlung:**
- **Default:** Gleichverteilt (50/50 für 2 Personen)
- **Smart:** Basierend auf `target_calories` / `target_share_ratio` aus MealParticipant
- **Manuell:** User kann Gramm pro Person einstellen

### 7. Cooking Flow — "If no final weight is entered"

**Aktuell:** "user may skip exact portioning → tracking may use planned estimate"

**Problem:** Was ist "planned estimate"? Rezept-Servings × Standard-Portion?

**Empfehlung:**
- Wenn keine Finished Weight: Tracking nutzt `planned_total_quantity` / `default_servings`
- UI zeigt: "Geschätzte Portion: 350g" (aus Rezept)
- User kann trotzdem manuell eingeben

### 8. Shopping Flow — "Category view"

**Aktuell:** "Category view"

**Frage:** Wer definiert die Kategorien? System? User? Rezept?

**Empfehlung:**
- **System-Kategorien:** Obst/Gemüse, Fleisch/Fisch, Milchprodukte, Getreide, etc.
- **Auto-Zuordnung:** Basierend auf `RecipeIngredient.category`
- **Manuell:** User kann verschieben

### 9. Progress Flow — "Trend"

**Aktuell:** "Trend chart updates"

**Frage:** Welcher Zeitraum? 7 Tage? 30 Tage? Benutzer-wählbar?

**Empfehlung:** Für MVP: 7-Tage-Durchschnitt als Standard. Später: 30 Tage, 90 Tage, 1 Jahr.

### 10. Space Flow — "Leave / Delete according to role"

**Aktuell:** "Leave / Delete according to role"

**Problem:** Was passiert mit Shared Meals/Shopping Lists wenn ein Member leaves?

**Empfehlung:**
- **Leave:** Member wird aus Space entfernt. Seine historischen MealParticipants bleiben (für Tracking).
- **Delete Space:** Nur Owner. Alle Space-Daten werden gelöscht (oder archiviert?)
- **Transfer Ownership:** Owner kann Ownership an anderen Member übertragen

### 11. Conflict Flow — "Keep server / retry local"

**Aktuell:** "Keep server / retry local / manually resolve"

**Problem:** Was ist der Unterschied zwischen "retry local" und "manually resolve"?

**Empfehlung:**
- **Keep Server:** Lokale Änderung verwerfen, Server-Version annehmen
- **Retry Local:** Lokale Änderung als neue Revision pushen (überschreibt Server)
- **Manually Resolve:** Feld-für-Feld Vergleich, User wählt pro Feld (Post-MVP)

---

## Fehlende Flows (Vorschläge)

| Flow | Warum | MVP oder später? |
|------|-------|-----------------|
| **Account Recovery** | Passwort vergessen | MVP |
| **Onboarding Tutorial** | Erste Nutzung erklären | MVP (optional) |
| **Recipe Creation** | Neue Rezepte hinzufügen | MVP |
| **Recipe Edit** | Bestehende Rezepte ändern | MVP |
| **Meal Template/Save** | Häufige Meals als Template | Später |
| **Bulk Import** | Rezepte importieren (z.B. aus Website) | Später |
| **Notification Settings** | Welche Benachrichtigungen? | Später |
| **Data Export** | GDPR-Compliance | Später |
| **Account Deletion** | GDPR-Compliance | Später |

---

## Konsistenz-Check mit anderen Dokumenten

| Dokument | Status | Anmerkung |
|----------|--------|-----------|
| **USER_JOURNEYS.md** | ✅ Konsistent | Alle Journeys sind in Flows abgedeckt |
| **DATA_MODEL.md** | ✅ Konsistent | Entities (PlannedMeal, ShoppingList, etc.) passen zu Flows |
| **SYNC_STRATEGY.md** | ✅ Konsistent | Offline/Conflict Flows passen zu Sync-Regeln |
| **ARCHITECTURE.md** | ✅ Konsistent | Module (Meal Planning, Shopping, etc.) passen zu Screens |

---

## Empfohlene Änderungen (Inline)

### Punkt 3 — Today Screen
**Ergänzen:**
```
Sync indicator states:
- synced: green dot or "Synced 2m ago"
- pending: orange dot
- conflict: red dot with badge
- offline: greyed out
```

### Punkt 4 — Planner Flow
**Ergänzen:**
```
Default participant behavior:
- User in Space → Shared meal (all Space members)
- User taps "Personal" → Private meal
- Multi-Space user → Space selection first
```

### Punkt 6 — Cooking Flow
**Ergänzen:**
```
Suggested allocation calculation:
- Default: equal distribution (50/50 for 2 people)
- Optional: based on target_calories or target_share_ratio
- Manual override: user enters grams per person
```

### Punkt 7 — Shopping Flow
**Ergänzen:**
```
Categories:
- System-defined: Produce, Meat, Dairy, Grains, etc.
- Auto-assigned from RecipeIngredient.category
- User can reassign manually
```

### Punkt 9 — Space Flow
**Ergänzen:**
```
Leave/Delete behavior:
- Leave: Member removed. Historical data preserved.
- Delete: Owner only. All Space data deleted.
- Transfer: Owner can transfer ownership to member.
```

### Punkt 10 — Conflict Flow
**Präzisieren:**
```
Conflict resolution options:
- Keep Server: Discard local, accept server version
- Retry Local: Push local as new revision (overwrites server)
- Manually Resolve: Field-by-field comparison (Post-MVP)
```

---

## Abschlussbewertung

| Kategorie | Bewertung | Kommentar |
|-----------|-----------|-----------|
| **Vollständigkeit** | 🟡 Gut | 14 Screens, aber Account Recovery fehlt |
| **Klarheit** | ✅ Exzellent | Jeder Flow ist nachvollziehbar |
| **UX-Details** | 🟡 Ausreichend | Einige Defaults und Edge-Cases fehlen |
| **Mockup-Tauglichkeit** | ✅ Exzellent | Jeder Punkt ist Figma-übersetzbar |
| **MVP-Fokus** | ✅ Gut | Keine überflüssigen Features |
| **Offline-Berücksichtigung** | ✅ Gut | Offline/Conflict Flow explizit |

---

## Atlas' Urteil: `Approve with Minor Changes`

Der User Flow ist reif für Figma-Mockups nach folgenden Änderungen:

1. **Punkt 3:** Sync indicator states präzisieren
2. **Punkt 4:** Default participant behavior ergänzen
3. **Punkt 6:** Allocation calculation ergänzen
4. **Punkt 7:** Category system ergänzen
5. **Punkt 9:** Leave/Delete behavior ergänzen
6. **Punkt 10:** Conflict resolution options präzisieren
7. **Neuer Flow:** Account Recovery (Login-Flow)

Keine Blocker. Keine strukturellen Änderungen.
