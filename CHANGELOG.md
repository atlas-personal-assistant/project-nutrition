# Nutrition App — Changelog

## v0.3.4 (2026-08-17) — Lokale Spaces
- ✅ Space erstellen mit Invite-Code
- ✅ Space beitreten mit Code
- ✅ Lokale Space-Liste im HomeScreen
- ✅ Lokale Datenspeicherung (SharedPreferences)

## v0.3.3 (2026-08-17) — UI Interaktionsfix
- ✅ Fixed: HomeScreen reagiert wieder auf Klicks
- ✅ Root Cause: `ref.watch(routerProvider)` hat App neu gebaut
- ✅ Lösung: Router nur einmal in `initState()` erstellen

## v0.3.2 (2026-08-17) — ChangeNotifier Router Fix
- ✅ AuthNotifier extends ChangeNotifier (statt StateNotifier)
- ✅ `notifyListeners()` bei Auth-State-Änderungen
- ✅ GoRouter bemerkt Auth-Änderungen

## v0.3.1 (2026-08-17) — Router Rebuild Fix
- ✅ MyApp als ConsumerWidget (statt StatefulWidget)
- ✅ `ref.watch(routerProvider)` statt `ref.read()`
- ✅ App wird bei Auth-Änderungen neu gebaut

## v0.3.0 (2026-08-17) — Deklarative Auth Navigation
- ✅ Enum-basierte Auth States (initial, loading, authenticated, unauthenticated)
- ✅ GoRouter Redirect basierend auf Auth-State
- ✅ Keine manuelle Navigation mehr in Login/Register

## v0.2.4 (2026-08-16) — Navigation Fix Attempt
- ✅ `mounted` check in separaten Methoden
- ✅ Debug-UI mit Schnell-Test Button

## v0.2.3 (2026-08-16) — Controller Fix
- ✅ LoginScreen als ConsumerStatefulWidget
- ✅ TextEditingController nicht mehr in build

## v0.2.2 (2026-08-16) — Erster Build
- ✅ Lokaler Auth Service (SharedPreferences)
- ✅ Offline Login/Register
- ✅ HomeScreen Tabs

## Nächste Version (v0.4.0)
- 🔄 Server-Anbindung für Auth
- 🔄 Server-Anbindung für Spaces
- 🔄 API-Integration statt lokalem Storage
- 🔄 JWT Token Handling

---
*Stand: 2026-08-17*