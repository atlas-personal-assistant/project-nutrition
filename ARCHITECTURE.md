# Project Nutrition — Architecture

**Status:** Draft for Atlas Review
**Version:** 0.1
**Date:** 2026-08-02
**Project Codename:** Project Nutrition
**Implementation Status:** No production implementation approved yet

## 1. Purpose

This document defines the technical architecture for Project Nutrition.

It is the primary reference for application structure, module boundaries, data ownership, offline-first behavior, frontend/backend responsibilities, future extensibility, and implementation constraints.

It intentionally does not define detailed database tables, API endpoints, UI layouts, nutrition formulas, or synchronization conflict rules. Those belong in separate documents.

Related documents:

- `PROJECT_CHARTER.md`
- `PROJECT_VISION.md`
- `SYSTEM_OVERVIEW.md`
- `DATA_MODEL.md`
- `SYNC_STRATEGY.md`
- `USER_JOURNEYS.md`
- `USER_FLOW.md`

## 2. Scope

### 2.1 MVP scope

The initial product supports:

- personal accounts
- personal profiles and goals
- shared Spaces
- personal and shared meal planning
- recipes
- cooked-meal portioning
- shopping lists
- weight tracking
- nutrition tracking
- simple workout and activity planning
- step targets
- manual data entry
- offline-capable mobile use
- synchronization through a central backend

### 2.2 Not required for the first prototype

The architecture must support, but the MVP does not need to implement:

- AI features
- professional coaching
- professional marketplace
- wearable integrations
- payments
- subscriptions
- advanced workout libraries
- automated medical or health recommendations
- complex analytics
- multi-region infrastructure
- native desktop application

## 3. Architectural Goals

1. Fast prototyping
2. Clear separation of responsibilities
3. Offline-first mobile usage
4. Deterministic business logic
5. Shared and personal planning in one system
6. Privacy by default
7. Future extensibility without early overengineering
8. Testability
9. Cross-platform UI from one primary codebase
10. Independence from AI providers

## 4. Core Architectural Decisions

### 4.1 Frontend

Use **Flutter / Dart** for:

- Android
- iOS
- responsive web application
- optional later desktop builds

Flutter is the primary presentation and client-application platform.

### 4.2 Backend

Use **Python with FastAPI** for:

- authentication orchestration
- account and Space management
- synchronization
- centralized persistence
- shared resource access
- server-side validation
- future integrations
- future background jobs

### 4.3 Persistence

Use:

- **SQLite locally** on the client
- **PostgreSQL centrally** on the server

The local database is not only a cache. It is the operational data store for offline-capable client workflows.

### 4.4 Hosting

Initial deployment:

- Hostinger VPS
- Docker Compose
- reverse proxy
- FastAPI service
- PostgreSQL
- backup service
- optional worker service later

### 4.5 AI

AI is not part of the core architecture.

The full application must remain usable without API keys, model servers, external AI providers, or AI-based calculations.

Future AI features must be implemented as optional adapters on top of existing application services.

## 5. High-Level Architecture

```text
Flutter Client
├── Presentation Layer
├── Application Layer
├── Domain Layer
├── Local Persistence
└── Sync Client
 |
 | HTTPS / REST
 v
FastAPI Backend
├── API Layer
├── Application Services
├── Domain Services
├── Authorization
├── Sync Service
└── Repositories
 |
 v
PostgreSQL
```

## 6. Client Architecture

### 6.1 Presentation Layer

Responsibilities:

- screens
- widgets
- navigation
- visual states
- form interaction
- responsive layout
- accessibility
- user-facing error messages

The presentation layer must not access SQLite directly, call HTTP APIs directly, contain nutrition formulas, calculate permissions, resolve sync conflicts, or contain vendor-specific wearable logic.

### 6.2 Application Layer

Responsibilities:

- execute user actions
- coordinate domain services
- expose screen-ready state
- handle commands and queries
- coordinate local persistence and synchronization
- convert domain failures into application states

Examples:

- `CreateSpace`
- `PlanMeal`
- `JoinSharedMeal`
- `RecordWeight`
- `CompleteWorkout`
- `AddRecipeToShoppingList`
- `CalculateCookedMealPortions`

### 6.3 Domain Layer

Responsibilities:

- core entities
- value objects
- business rules
- deterministic calculations
- validation rules
- invariants

The domain layer must not depend on Flutter widgets, HTTP, SQLite, PostgreSQL, external APIs, or AI services.

### 6.4 Infrastructure Layer

Responsibilities:

- SQLite repositories
- HTTP client
- backend DTO mapping
- synchronization queue
- secure token storage
- platform health adapters later
- file and image handling

Infrastructure implementations satisfy interfaces defined by higher layers.

## 7. Backend Architecture

The FastAPI backend uses a **modular monolith**.

This is preferred over microservices for the MVP because deployment, transactions, observability, and maintenance remain simpler while domain boundaries can still be enforced.

### 7.1 Backend Layers

```text
API / Transport
 ↓
Application Services
 ↓
Domain
 ↓
Repositories / Infrastructure
 ↓
PostgreSQL
```

### 7.2 API Layer

Responsibilities:

- HTTP request parsing
- authentication checks
- request validation
- response serialization
- status codes
- API versioning
- rate limiting later

The API layer must not contain domain calculations.

### 7.3 Application Services

Responsibilities:

- use-case orchestration
- transaction boundaries
- authorization coordination
- repository interaction
- event creation
- sync operation handling

### 7.4 Domain Services

Responsibilities:

- rules spanning multiple entities
- portion allocation
- meal-plan validation
- Space participation rules
- plan revision rules
- deterministic program constraints later

### 7.5 Repositories

Examples:

- `UserRepository`
- `SpaceRepository`
- `MealPlanRepository`
- `RecipeRepository`
- `TrackingRepository`
- `ShoppingListRepository`

Application and domain layers must not use raw SQL directly.

## 8. Domain Modules

### 8.1 Identity and Accounts

Owns user identity, login state, profile ownership, account lifecycle, and authentication mapping.

### 8.2 Profiles and Goals

Owns personal attributes required for planning, nutrition targets, activity targets, user preferences, and visibility defaults.

### 8.3 Spaces and Membership

Owns shared Spaces, membership, invitations, roles, Space lifecycle, and shared-resource ownership.

A Space never automatically gains access to all personal data of its members.

### 8.4 Recipes

Owns recipe metadata, ingredients, preparation steps, nutrition data, optional image references, tags, visibility, and later revisions.

### 8.5 Meal Planning

Owns daily and weekly plans, meal slots, personal meals, shared meals, participant assignment, changes, and status.

A shared meal is one logical object with multiple participants, not duplicated personal meals.

### 8.6 Portioning

Owns total cooked weight, participant targets, serving allocation, leftovers, meal-prep reservations, and actual served portions.

### 8.7 Shopping

Owns shared and personal shopping lists, aggregated ingredients, category assignment, manual items, checked state, ownership, and collaboration.

### 8.8 Tracking

Owns weight entries, calorie intake, macro intake, meal completion, personal progress, and manual activity entries.

### 8.9 Training and Activity

Owns workout sessions, step targets, completion status, personal/shared activities, and simple daily-plan integration.

### 8.10 Structured Programs

Later owns temporary program templates, start/end dates, combined nutrition/activity tasks, safety constraints, and transition plans.

### 8.11 Sharing and Consent

Owns recipient-specific grants, data-scope permissions, temporary sharing, revocation, future coach access, and audit metadata.

### 8.12 Sync

Owns change tracking, local operation queue, server synchronization, conflict detection, retry handling, sync state, and revision metadata.

Detailed conflict rules belong in `SYNC_STRATEGY.md`.

## 9. Central Daily Plan

The personal daily plan is the main product view.

It combines:

- personal meals
- shared Space meals
- snacks
- workouts
- step targets
- recovery items
- structured-program tasks
- tracking reminders

A daily plan is a projection of multiple domain sources, not necessarily one large database record.

## 10. Data Ownership

Every persistent object must have an explicit ownership model:

- user-owned
- Space-owned
- system-owned
- provider-owned/imported
- derived

Visibility is separate from ownership.

Examples:

- shared dinner: Space-owned
- consumed portion: user-owned
- shopping list: Space-owned
- weight: user-owned and private

No entity may rely on implicit ownership.

## 11. Authorization

Authorization is evaluated server-side.

Decisions use:

- authenticated user
- entity ownership
- Space membership
- Space role
- explicit data-sharing grants
- entity status
- requested action

Authorization should be centralized in policies or services rather than repeated in route handlers.

## 12. Offline-First Architecture

Core offline-capable MVP workflows:

- view downloaded recipes
- view current plans
- record weight
- record meals
- update shopping lists
- mark workouts complete
- enter step counts
- calculate cooked-meal portions
- create local changes for later sync

### 12.1 Local Write Model

```text
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

### 12.2 Sync Metadata

Synchronizable records should support:

- local ID
- server ID
- revision/version
- created time
- updated time
- deleted/tombstone state
- sync state
- last synced revision
- actor/user ID

### 12.3 Conflict Principle

Conflict handling must be entity-specific.

The project must not use one universal blind Last-Write-Wins rule.

## 13. API Style

Use versioned REST APIs for the MVP.

Example:

```text
/api/v1/
```

Resource groups:

- `/auth`
- `/users`
- `/profiles`
- `/spaces`
- `/recipes`
- `/meal-plans`
- `/meals`
- `/shopping-lists`
- `/tracking`
- `/activities`
- `/sync`

Detailed contracts belong in `API_CONTRACT.md`.

## 14. State Management

The exact Flutter state-management package may be selected by Atlas during technical review.

Required properties:

- testable
- supports dependency injection
- supports asynchronous state
- supports offline and sync states
- avoids global mutable state
- separates application state from widgets

Riverpod is a likely candidate, but not yet a hard requirement.

## 15. Dependency Injection

Inject repositories, API clients, clock/time providers, ID generators, sync services, health-data providers, and future AI adapters at composition boundaries.

Avoid hidden singletons in domain and application code.

## 16. Error Handling

Classify errors as:

- validation
- authorization
- not found
- conflict
- network
- sync
- persistence
- server
- integration

The UI receives structured application failures, not raw exceptions.

## 17. Observability

Required initially:

- structured backend logs
- request IDs
- user-safe error reporting
- database backup verification
- sync failure logging
- deployment health checks

Sensitive nutrition or health data must not be written to logs.

## 18. Security

Initial requirements:

- HTTPS only
- established password/authentication handling
- secure access and refresh token handling
- encrypted secrets
- least-privilege database user
- server-side authorization
- backups
- dependency updates
- audit trail for permission changes

Future third-party API keys must never be stored in client code.

## 19. Privacy

Requirements:

- private by default
- explicit sharing
- data minimization
- clear ownership
- revocable grants
- future export and deletion support
- no advertising use of health data
- no automatic sharing of wearable data
- separate raw and derived-data sharing

Initial legal target: EU/Germany.

## 20. Future Integration Boundaries

### 20.1 Wearables

```text
HealthDataProvider
├── ManualEntryProvider
├── AppleHealthProvider
├── HealthConnectProvider
├── FitbitProvider
└── GarminProvider
```

### 20.2 AI

```text
SuggestionProvider
├── NoAiProvider
├── ExternalApiProvider
└── SelfHostedProvider
```

AI may suggest but not replace deterministic calculations.

### 20.3 Professional Coaching

Builds on accounts, explicit sharing, plan revisions, comments/proposals, and auditability.

### 20.4 Marketplace

A separate later module built on professional profiles and coaching relationships.

## 21. Deployment Architecture

Initial Docker Compose services:

```text
reverse-proxy
backend
postgres
backup
```

Possible later additions:

```text
worker
scheduler
object-storage adapter
monitoring
```

Recipe images should not be stored directly in PostgreSQL.

## 22. Repository Structure

```text
project-nutrition/
├── apps/
│   └── client/
├── services/
│   └── api/
├── docs/
├── infrastructure/
│   ├── docker/
│   └── deployment/
├── scripts/
├── tests/
└── README.md
```

Possible Flutter structure:

```text
apps/client/lib/
├── app/
├── core/
├── modules/
│   ├── identity/
│   ├── profiles/
│   ├── spaces/
│   ├── recipes/
│   ├── meal_planning/
│   ├── portioning/
│   ├── shopping/
│   ├── tracking/
│   └── activity/
└── infrastructure/
```

Possible FastAPI structure:

```text
services/api/app/
├── api/
├── application/
├── domain/
├── infrastructure/
├── modules/
├── config/
└── main.py
```

## 23. Testing Strategy at Architecture Level

Required categories:

- domain unit tests
- repository tests
- API tests
- sync integration tests
- critical UI tests

Detailed planning belongs in `TESTING_STRATEGY.md`.

## 24. Architectural Anti-Patterns

Prohibited:

- business logic inside Flutter widgets
- direct SQLite access from screens
- direct HTTP calls from widgets
- raw SQL in route handlers
- one large global application state
- duplicating shared meals per participant
- using AI for mandatory calculations
- universal Last-Write-Wins conflict handling
- implicit data ownership
- unrestricted Space-owner access to private health data
- vendor-specific wearable logic in the domain
- premature microservices
- secrets in the client
- marketplace features inside MVP modules
- full workout-platform complexity before the daily plan works

## 25. Architecture Decision Records

Suggested directory:

```text
docs/adr/
```

Initial ADRs:

- ADR-001: Flutter as cross-platform client
- ADR-002: FastAPI modular monolith
- ADR-003: SQLite local and PostgreSQL remote
- ADR-004: Offline-first local-write model
- ADR-005: Shared meal as one object with participants
- ADR-006: AI optional adapter only
- ADR-007: Explicit sharing grants
- ADR-008: Hostinger VPS and Docker Compose for prototype

## 26. MVP Architecture Freeze

Before implementation starts, approve:

- architecture layers
- module boundaries
- ownership model
- local-first write flow
- sync responsibilities
- shared meal representation
- Space permission principles
- repository structure

The following can remain deferred:

- exact API endpoints
- final database columns
- advanced conflict resolution
- wearable providers
- AI provider
- marketplace services
- exercise library
- subscription billing

## 27. Open Decisions for Atlas Review

Atlas should review and recommend:

1. Flutter state management
2. local SQLite library
3. authentication implementation
4. ID strategy
5. backend ORM and migration tooling
6. API DTO strategy
7. sync operation representation
8. soft deletion/tombstone approach
9. background sync limitations on iOS and Android
10. image storage for the prototype
11. repository layout
12. feature-first versus layer-first module organization
13. minimum audit logging for MVP
14. whether responsive web belongs in prototype milestone one or two

Atlas must not expand the MVP while reviewing these decisions.

## 28. Approval Criteria

This document can be approved when:

- Atlas confirms the architecture is implementable
- major module boundaries are accepted
- no critical contradiction exists with the master documents
- offline-first responsibilities are clear
- future modules are isolated from the MVP
- open decisions are resolved or explicitly deferred

## 29. Next Documents

After this review:

1. `DATA_MODEL.md`
2. `USER_JOURNEYS.md`
3. `SYNC_STRATEGY.md`
4. `USER_FLOW.md`
5. UI wireframes and mockups
6. implementation plan for the first vertical prototype

The planning phase should end after these documents are sufficiently implementation-ready. The goal is not exhaustive documentation; it is avoiding structural rework while reaching a usable prototype quickly.
