# DATA_MODEL.md Review — Atlas

**Status:** Draft Review Complete
**Version:** 0.1 Review
**Datum:** 2026-08-02
**Reviewer:** Atlas
**Mandat:** Keine Implementation. Keine MVP-Erweiterung.

---

## Gesamturteil: `Approve with Minor Changes`

Das Datenmodell ist **durchdacht, konsistent und MVP-geeignet**. Die UUIDv7-Entscheidung ist exzellent für Offline-First. Die Ownership-Rules sind klar. Einige Felder und Constraints brauchen Präzisierung, aber keine Blocker.

---

## Kritische Anmerkungen

### 1. UUIDv7 — Exzellente Wahl ✅

**Vorteile:**
- Offline-generierbar
- Zeit-sortierbar (keine zusätzlichen Created-At-Indizes nötig für Zeit-Range-Queries)
- Keine Client/Server-ID-Mapping-Complexität

**Empfehlung:** Bestätigt. Keine Änderung.

### 2. Sync Metadata — Konsistent, aber redundant?

**Aktuell:** Jedes synchronisierbare Entity hat:
- `id`
- `revision`
- `created_at`
- `updated_at`
- `deleted_at` optional
- `sync_state` (client-only)
- `last_synced_revision` (client-only)
- `created_by_user_id`
- `updated_by_user_id`

**Frage:** `created_by_user_id` und `updated_by_user_id` — ist das für Audit oder für Business-Logic?

**Empfehlung:**
- `created_by` / `updated_by` für Audit-Trail → später (Post-MVP)
- Für MVP: `created_by` reicht, `updated_by` ist Overhead

### 3. PersonalProfile — `current_weight_kg` als derived field

**Aktuell:** `current_weight_kg` optional derived from latest entry

**Problem:** Derived fields in DB sind ein Anti-Pattern. Sie müssen bei jedem WeightEntry-Insert aktualisiert werden.

**Empfehlung:**
- Entfernen aus PersonalProfile
- Im Client als View/Query berechnen: `SELECT weight_kg FROM WeightEntry WHERE user_id = ? ORDER BY measured_at DESC LIMIT 1`
- Oder: Materialized View auf Server, nicht in Entity

### 4. NutritionGoal — `source` field

**Aktuell:** `source` = manual | calculated | professional_proposal | accepted_program

**Problem:** "calculated" ist in MVP nicht implementiert (Architektur sagt: "MVP supports manual values and simple deterministic calculation later")

**Empfehlung:** Für MVP: `source` = manual only. Andere Werte sind für später reserviert.

### 5. RecipeNutrition — `basis` field

**Aktuell:** `basis` = whole_recipe | per_serving

**Frage:** Was ist mit „per 100g“? Das ist der Standard in Ernährungs-Apps.

**Empfehlung:** `basis` ergänzen:
- `whole_recipe`
- `per_serving`
- `per_100g` ← hinzufügen

### 6. PlannedMeal — `planned_total_quantity` optional

**Aktuell:** `planned_total_quantity` optional

**Frage:** Ist das für die Portionierung? Oder für die Einkaufsmenge?

**Empfehlung:** Präzisieren:
- `planned_total_quantity` = Anzahl der Portionen (für Einkauf)
- Die tatsächliche Portionierung kommt später bei `PreparedMealBatch`

### 7. MealParticipant — `target_share_ratio` optional

**Aktuell:** `target_share_ratio` optional

**Frage:** Ratio wie? 0.6 = 60%? Oder 60 = 60%?

**Empfehlung:** Als Float (0.0 - 1.0) oder als Integer (0-100) definieren. Float ist flexibler (z.B. 0.333 für 1/3).

### 8. PreparedMealAllocation — `allocation_type`

**Aktuell:** `allocation_type` = participant | leftover | meal_prep

**Problem:** `meal_prep` ist ein komplexes Konzept (Meal Prep = mehrere Portionen für spätere Tage). Ist das MVP?

**Empfehlung:** Für MVP: `allocation_type` = participant | leftover only. `meal_prep` als Reserved Value markieren.

### 9. ShoppingListItem — `checked` field

**Aktuell:** `checked` als Boolean

**Problem:** In Offline-Szenarien kann das zu Conflicts führen. User A checkt offline, User B checkt offline, beide pushen.

**Empfehlung:** `checked` ist idempotent (gleicher Zustand ist egal). Aber: `checked_at` und `checked_by_user_id` könnten für Audit nützlich sein. Für MVP: `checked` als Boolean reicht, aber Conflict-Rule beachten (SYNC_STRATEGY.md Punkt 11).

### 10. DailyProgress — "derived read model"

**Aktuell:** "A derived read model, not canonical persistence."

**Frage:** Wo wird das berechnet? Client oder Server?

**Empfehlung:**
- Client-seitig aus lokalen Daten berechnen (für Offline)
- Server-seitig als API-Endpunkt für schnelle Abfragen (für Web/Refresh)
- Nicht in DB persistieren, sondern als View/Query

### 11. TrainingSession — `visibility` field

**Aktuell:** `visibility` field

**Frage:** Wie unterscheidet sich das von `space_id` optional?
- `space_id` = null → private
- `space_id` = value → shared with Space

**Empfehlung:** `visibility` entfernen und durch `space_id` + `visibility_rules` ersetzen? Oder: `visibility` = private | space_members | public (future).

### 12. SyncOutboxOperation — `base_revision`

**Aktuell:** `base_revision` in Outbox

**Problem:** Was ist `base_revision` für ein `create`-Operation? Null? 0?

**Empfehlung:** Für `create`: `base_revision` = null. Für `update`/`delete`: `base_revision` = letzte bekannte Server-Revision.

### 13. SyncCursor — `scope` field

**Aktuell:** `scope` field

**Frage:** Was sind die Scopes? Per User? Per Space? Per Module?

**Empfehlung:** Für MVP: `scope` = "account". Später: "account", "space:<id>", "module:shopping", etc.

### 14. Relationship Summary — Diagramm

**Aktuell:** ASCII-Diagramm in Punkt 13

**Problem:** `RecipeNutrition` und `RecipeIngredient`/`RecipeStep` fehlen im Diagramm.

**Empfehlung:** Ergänzen:
```
Recipe
├── RecipeIngredient*
├── RecipeStep*
└── RecipeNutrition*
```

---

## Konsistenz-Check mit anderen Dokumenten

| Dokument | Status | Anmerkung |
|----------|--------|-----------|
| **ARCHITECTURE.md** | ✅ Konsistent | 12 Domain Modules → 12 Entity-Gruppen. Mapping passt. |
| **SYNC_STRATEGY.md** | 🟡 Teilweise | Revision-Model (Punkt 9) passt. Aber: `sync_state` und `last_synced_revision` sind Client-only Felder — das ist hier nicht explizit markiert. |
| **USER_JOURNEYS.md** | ✅ Konsistent | Alle Journeys können abgebildet werden. |
| **USER_FLOW.md** | ✅ Konsistent | Alle Flows haben Entities. |

---

## Fehlende Entities (Vorschläge)

| Entity | Warum | MVP oder später? |
|--------|-------|-----------------|
| **UnitConversion** | Rezepte haben verschiedene Einheiten (g, ml, Stück, EL) | MVP (für Rezepte) |
| **FoodItem** | Zutaten-DB für Ernährungsdaten (Nährwerte pro 100g) | MVP (für Tracking) |
| **MealPlanTemplate** | Wochenplan als Template speichern/wiederverwenden | Später |
| **Notification** | In-App Notifications (z.B. "Gemeinsames Dinner heute") | Später |
| **UserPreference** | App-Einstellungen (Dark Mode, Einheiten, etc.) | MVP |

---

## Empfohlene Änderungen (Inline)

### Punkt 3.2 — PersonalProfile
**Entfernen:** `current_weight_kg`
**Grund:** Derived field, Anti-Pattern

### Punkt 3.3 — NutritionGoal
**Ändern:** `source` MVP-Values
```
source:
  - manual          # MVP
  - calculated      # reserved
  - professional    # reserved
  - program         # reserved
```

### Punkt 5.4 — RecipeNutrition
**Ergänzen:** `per_100g`
```
basis:
  - whole_recipe
  - per_serving
  - per_100g        # neu
```

### Punkt 6.5 — MealParticipant
**Präzisieren:** `target_share_ratio`
```
target_share_ratio: Float (0.0 - 1.0)
# Beispiel: 0.6 = 60% Anteil
```

### Punkt 6.8 — PreparedMealAllocation
**Ergänzen:** MVP-Scope
```
allocation_type:
  - participant     # MVP
  - leftover        # MVP
  - meal_prep       # reserved for later
```

### Punkt 9.2 — TrainingSession
**Präzisieren:** `visibility`
```
visibility:
  - private         # MVP (space_id = null)
  - space           # MVP (space_id gesetzt)
  - public          # reserved
```

---

## Abschlussbewertung

| Kategorie | Bewertung | Kommentar |
|-----------|-----------|-----------|
| **Vollständigkeit** | 🟡 Gut | 19 Entities für MVP, aber UnitConversion fehlt |
| **Konsistenz** | ✅ Exzellent | UUIDv7, Sync Metadata, Ownership überall gleich |
| **Offline-Fähigkeit** | ✅ Gut | UUIDv7 + Outbox + Cursor = solide Basis |
| **Skalierbarkeit** | ✅ Gut | Future Entities (Programs, Sharing) als Placeholder |
| **Präzision** | 🟡 Ausreichend | Einige Felder brauchen Typ/Range-Definition |
| **MVP-Fokus** | ✅ Gut | Accept Criteria in Punkt 15 sind testbar |

---

## Atlas' Urteil: `Approve with Minor Changes`

Das Datenmodell ist reif für Implementation nach den folgenden Änderungen:

1. `current_weight_kg` aus PersonalProfile entfernen (derived)
2. `NutritionGoal.source` auf MVP-Values einschränken
3. `RecipeNutrition.basis` um `per_100g` erweitern
4. `target_share_ratio` als Float (0.0-1.0) definieren
5. `allocation_type` für MVP einschränken (participant/leftover)
6. `visibility` in TrainingSession präzisieren

Keine Blocker. Keine strukturellen Änderungen nötig.
