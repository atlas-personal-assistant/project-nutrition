---
# Project Nutrition — Data Model

**Status:** Approved for MVP implementation
**Version:** 0.1
**Date:** 2026-08-02

## 1. Purpose

This document defines the MVP domain entities, ownership rules, relationships and synchronization requirements.

The model supports:

- personal accounts
- shared Spaces
- personal and shared meals
- cooked-meal portioning
- shopping lists
- tracking
- workouts and step targets
- offline-first synchronization

Future coaching, wearables, AI and marketplace features must build on this model without changing the fundamental ownership rules.

---

## 2. Global Conventions

### 2.1 IDs

All persistent entities use UUIDv7 identifiers.

Benefits:

- can be generated offline
- sortable by creation time
- no separate client/server ID mapping
- safe for distributed creation

### 2.2 Timestamps

All stored timestamps use UTC.

Display uses the user's configured timezone.

### 2.3 Sync Metadata

Synchronizable entities include:

- `id`
- `revision`
- `created_at`
- `updated_at`
- `deleted_at` optional
- `sync_state` on the client
- `last_synced_revision` on the client
- `created_by_user_id`
- `updated_by_user_id`

### 2.4 Ownership

Every entity must be explicitly:

- user-owned
- Space-owned
- system-owned
- imported/provider-owned
- derived

Visibility is separate from ownership.

---

## 3. Identity and Profiles

### User

Represents an authenticated person.

Fields:

- `id`
- `email`
- `password_hash` server-only
- `status`
- `created_at`
- `updated_at`

Relationships:

- one User has one PersonalProfile
- one User has zero or many SpaceMemberships
- one User owns personal tracking data
- one User may participate in many meals and activities

### PersonalProfile

Stores personal planning information.

Fields:

- `id`
- `user_id`
- `display_name`
- `birth_date` optional
- `biological_sex` optional
- `height_cm` optional
- `current_weight_kg` optional derived from latest entry
- `activity_level`
- `timezone`
- `preferred_units`
- `created_at`
- `updated_at`

Privacy:

Private by default.

### NutritionGoal

Fields:

- `id`
- `user_id`
- `valid_from`
- `valid_to` optional
- `goal_type`
- `daily_calorie_target`
- `daily_protein_target_g`
- `daily_fat_target_g`
- `daily_carbohydrate_target_g`
- `source`
- `notes` optional
- sync metadata

`source` values:

- manual
- calculated
- professional_proposal
- accepted_program

The MVP supports manual values and simple deterministic calculation later.

### ActivityGoal

Fields:

- `id`
- `user_id`
- `valid_from`
- `valid_to` optional
- `daily_step_target`
- `weekly_workout_target` optional
- `notes` optional
- sync metadata

---

## 4. Spaces

### Space

Represents a household or collaboration context.

Fields:

- `id`
- `name`
- `owner_user_id`
- `status`
- sync metadata

### SpaceMembership

Fields:

- `id`
- `space_id`
- `user_id`
- `role`
- `status`
- `joined_at`
- `left_at` optional
- sync metadata

MVP roles:

- owner
- member

Rules:

- Space ownership does not grant access to private tracking data.
- Membership and permission changes are server-authoritative.
- A User may belong to multiple Spaces.

### SpaceInvitation

Fields:

- `id`
- `space_id`
- `invited_email`
- `token_hash`
- `expires_at`
- `status`
- `created_by_user_id`
- server revision metadata

---

## 5. Recipes

### Recipe

Fields:

- `id`
- `owner_type`
- `owner_user_id` optional
- `owner_space_id` optional
- `title`
- `description`
- `default_servings`
- `preparation_time_minutes`
- `cooking_time_minutes`
- `difficulty`
- `image_reference` optional
- `visibility`
- sync metadata

`owner_type`:

- user
- space
- system

### RecipeIngredient

Fields:

- `id`
- `recipe_id`
- `ingredient_name`
- `quantity`
- `unit`
- `category`
- `optional`
- `sort_order`
- sync metadata

### RecipeStep

Fields:

- `id`
- `recipe_id`
- `instruction`
- `sort_order`
- `duration_minutes` optional
- sync metadata

### RecipeNutrition

Fields:

- `id`
- `recipe_id`
- `basis`
- `calories`
- `protein_g`
- `fat_g`
- `carbohydrate_g`
- `fiber_g` optional
- sync metadata

MVP `basis`:

- whole_recipe
- per_serving

---

## 6. Meal Planning

### MealPlan

Represents a planning container for a user or Space.

Fields:

- `id`
- `owner_type`
- `owner_user_id` optional
- `owner_space_id` optional
- `start_date`
- `end_date`
- `status`
- sync metadata

### PlannedMeal

Represents one logical meal.

Fields:

- `id`
- `meal_plan_id`
- `space_id` optional
- `created_by_user_id`
- `date`
- `meal_type`
- `recipe_id` optional
- `custom_title` optional
- `status`
- `visibility`
- `planned_total_quantity` optional
- sync metadata

`meal_type`:

- breakfast
- lunch
- dinner
- snack
- other

Rules:

- a shared meal is stored once
- personal plans reference the same shared meal through participants
- a personal meal has one participant
- a shared meal has two or more participants from the same Space

### MealParticipant

Fields:

- `id`
- `planned_meal_id`
- `user_id`
- `target_calories` optional
- `target_share_ratio` optional
- `target_portion_g` optional
- `actual_portion_g` optional
- `participation_status`
- sync metadata

`participation_status`:

- planned
- confirmed
- skipped
- completed

### PreparedMealBatch

Represents the finished cooked result.

Fields:

- `id`
- `planned_meal_id`
- `finished_weight_g`
- `prepared_at`
- `notes` optional
- sync metadata

### PreparedMealAllocation

Fields:

- `id`
- `prepared_meal_batch_id`
- `user_id` optional
- `allocation_type`
- `weight_g`
- `calories` optional derived
- sync metadata

`allocation_type`:

- participant
- leftover
- meal_prep

For the MVP, participant allocation and simple leftover allocation are sufficient.

---

## 7. Shopping

### ShoppingList

Fields:

- `id`
- `owner_type`
- `owner_user_id` optional
- `owner_space_id` optional
- `name`
- `status`
- sync metadata

### ShoppingListItem

Fields:

- `id`
- `shopping_list_id`
- `source_recipe_id` optional
- `source_planned_meal_id` optional
- `name`
- `quantity` optional
- `unit` optional
- `category`
- `checked`
- `manually_added`
- `sort_order`
- sync metadata

Rules:

- derived recipe items may be edited manually
- checking an item is a shared mutable operation
- duplicate ingredients may be aggregated by a service, not by database identity

---

## 8. Tracking

### WeightEntry

Fields:

- `id`
- `user_id`
- `measured_at`
- `weight_kg`
- `source`
- `notes` optional
- sync metadata

Weight entries are user-owned and private by default.

### NutritionLogEntry

Fields:

- `id`
- `user_id`
- `logged_at`
- `planned_meal_id` optional
- `recipe_id` optional
- `title`
- `calories`
- `protein_g`
- `fat_g`
- `carbohydrate_g`
- `source`
- sync metadata

### DailyProgress

A derived read model, not canonical persistence.

May include:

- calorie target versus actual
- macro target versus actual
- step target versus actual
- completed meals
- completed workout status
- current weight trend

---

## 9. Training and Activity

### TrainingPlan

Fields:

- `id`
- `user_id`
- `name`
- `start_date`
- `end_date` optional
- `status`
- sync metadata

### TrainingSession

Fields:

- `id`
- `training_plan_id` optional
- `space_id` optional
- `created_by_user_id`
- `date`
- `session_type`
- `title`
- `target_duration_minutes` optional
- `target_steps` optional
- `notes` optional
- `visibility`
- sync metadata

MVP `session_type`:

- strength
- cardio
- walking
- mobility
- recovery
- other

### TrainingParticipant

Fields:

- `id`
- `training_session_id`
- `user_id`
- `completion_status`
- `actual_duration_minutes` optional
- `actual_steps` optional
- `notes` optional
- sync metadata

### StepEntry

Fields:

- `id`
- `user_id`
- `date`
- `steps`
- `source`
- sync metadata

MVP source:

- manual

Later:

- health_connect
- healthkit
- fitbit
- garmin

---

## 10. Structured Programs

### StructuredProgram

Architecture placeholder, not required for first vertical prototype.

Fields:

- `id`
- `owner_type`
- `name`
- `program_type`
- `duration_days`
- `status`
- sync metadata

### ProgramEnrollment

Fields:

- `id`
- `program_id`
- `user_id`
- `start_date`
- `end_date`
- `status`
- sync metadata

### ProgramTask

Fields:

- `id`
- `enrollment_id`
- `date`
- `task_type`
- `reference_id` optional
- `target_value` optional
- `completion_status`
- sync metadata

This allows future short-term programs to create meals, step targets, workouts and check-ins without replacing the normal daily-plan model.

---

## 11. Sharing and Consent

### DataShareGrant

Not required in the first household prototype except as architecture support.

Fields:

- `id`
- `owner_user_id`
- `recipient_user_id`
- `space_id` optional
- `data_scope`
- `access_level`
- `start_date`
- `end_date` optional
- `status`
- sync metadata

The MVP initially supports sharing through Space-owned objects. Private user data remains private unless a future explicit grant exists.

---

## 12. Synchronization

### SyncOutboxOperation

Client-local entity.

Fields:

- `id`
- `entity_type`
- `entity_id`
- `operation_type`
- `base_revision`
- `payload`
- `created_at`
- `attempt_count`
- `next_retry_at`
- `status`
- `last_error_code` optional

`operation_type`:

- create
- update
- delete

### SyncCursor

Client-local entity.

Fields:

- `scope`
- `cursor`
- `last_successful_sync_at`

---

## 13. Relationship Summary

```text
User
├── PersonalProfile
├── NutritionGoal*
├── ActivityGoal*
├── WeightEntry*
├── NutritionLogEntry*
├── SpaceMembership*
└── TrainingPlan*

Space
├── SpaceMembership*
├── MealPlan*
├── PlannedMeal*
└── ShoppingList*

MealPlan
└── PlannedMeal*
 ├── MealParticipant*
 ├── PreparedMealBatch*
 │ └── PreparedMealAllocation*
 └── Recipe optional
```

---

## 14. MVP Required Entities

First vertical prototype requires:

- User
- PersonalProfile
- Space
- SpaceMembership
- Recipe
- RecipeIngredient
- RecipeStep
- PlannedMeal
- MealParticipant
- PreparedMealBatch
- PreparedMealAllocation
- ShoppingList
- ShoppingListItem
- WeightEntry
- TrainingSession
- TrainingParticipant
- StepEntry
- SyncOutboxOperation
- SyncCursor

Other entities may follow after the first prototype.

---

## 15. Acceptance Criteria

The model is implementation-ready when it can represent:

1. Michael and his girlfriend as separate Users.
2. Both as members of one shared Space.
3. A shared breakfast and dinner.
4. Separate lunches.
5. One shared cooked meal with different finished portions.
6. A shared shopping list.
7. Private weight entries.
8. A personal step target and workout.
9. Local offline edits with pending synchronization.
