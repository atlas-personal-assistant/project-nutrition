# Project Nutrition — Core User Journeys

**Status:** Approved for MVP mockups
**Version:** 0.1
**Date:** 2026-08-02

## Journey 1 — First Setup as a Couple

1. Michael installs the app.
2. He creates an account.
3. He enters basic profile and planning values.
4. He creates a Space.
5. He receives an invitation code or link.
6. His girlfriend creates her own account.
7. She joins the Space.
8. Both retain private profiles and tracking.
9. Shared meals and lists become available in the Space.

Success:

- two independent accounts
- one shared Space
- no private weight data exposed

## Journey 2 — Mixed Personal and Shared Day

Goal:

Plan breakfast and dinner together while keeping lunch separate.

1. Michael opens the weekly planner.
2. He creates a shared breakfast for both.
3. He creates his own lunch as a ready-made meal.
4. His girlfriend creates her own lunch.
5. Michael creates a shared dinner.
6. Both see complete personal day views.
7. The Space view shows only shared meals.

Success:

- shared meals exist once
- both personal plans show the same shared objects
- private lunches remain private
- calorie targets remain individual

## Journey 3 — Cook and Portion a Shared Meal

1. One participant opens the shared dinner.
2. The app shows total ingredients.
3. The meal is cooked together.
4. The user weighs the finished dish.
5. The finished weight is entered.
6. The app calculates target portions for each participant.
7. The user may adjust portions manually.
8. Actual portions are confirmed.
9. The personal tracking logs receive the corresponding portions.
10. Leftover weight may be recorded.

Success:

- no raw ingredient splitting per person
- finished-dish portions are clear
- actual portions remain attributable to individuals

## Journey 4 — Shared Shopping

1. Planned recipes create shopping-list suggestions.
2. Both users see one shared list.
3. Ingredients are grouped by category.
4. Either user may check items.
5. Offline changes remain visible locally.
6. Changes synchronize later.
7. The other user receives the updated list.

Success:

- shared list works with intermittent connectivity
- no duplicate purchases caused by silent sync failure

## Journey 5 — Personal Weight Tracking

1. User opens Tracking.
2. User enters current weight.
3. Entry appears immediately.
4. Trend chart updates.
5. Entry remains private.
6. Entry synchronizes when online.

Success:

- fast entry
- no Space sharing by default
- trend view remains available offline

## Journey 6 — Training and Step Target

1. User creates or receives today's step target.
2. User adds a workout.
3. Both appear in the daily plan.
4. User enters current steps manually.
5. User marks workout complete.
6. Daily progress updates.

Success:

- nutrition and activity coexist in one daily plan
- wearable is not required

## Journey 7 — Short Structured Diet Phase

Later MVP extension:

1. User selects a one-week predefined program.
2. The app shows scope, duration and warnings.
3. User confirms the program.
4. Daily meals, protein target, steps and workouts appear in the normal daily plan.
5. User tracks adherence.
6. Program ends automatically.
7. App returns to the previous or maintenance plan.

Success:

- program uses existing planning modules
- no separate disconnected subsystem
- AI is not required

## Journey 8 — Offline Day

1. User opens app without internet.
2. Current plan and downloaded recipes remain visible.
3. User checks shopping items.
4. User records weight and steps.
5. User portions a prepared meal.
6. App marks changes as pending.
7. Connection returns.
8. App synchronizes.
9. User sees confirmed state or clear conflict.

Success:

- core use remains helpful offline
- no data is silently lost
