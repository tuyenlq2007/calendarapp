# Online Teachings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add cloud-backed online teaching cards to the mobile Teachings tab.

**Architecture:** Add a focused online-teachings data model and Supabase feed client. Load online teachings from cloud in `main.dart`, pass them into `BaromKagyuCalendarApp`, and render approved cards in `TeachingsScreen`.

**Tech Stack:** Flutter/Dart, Supabase Flutter client, widget tests, PowerShell/cloud SQL handoff.

---

### Task 1: Data Model and Feed

**Files:**
- Create: `apps/mobile/lib/features/teachings/data/online_teaching_database.dart`
- Create: `apps/mobile/lib/core/network/supabase_online_teaching_feed.dart`
- Test: `apps/mobile/test/core/network/supabase_online_teaching_feed_test.dart`

- [ ] Write failing tests for parsing online teaching rows and rejecting invalid status.
- [ ] Implement `OnlineTeachingRow` and `SupabaseOnlineTeachingFeed`.
- [ ] Run the new feed tests.

### Task 2: App Wiring

**Files:**
- Modify: `apps/mobile/lib/main.dart`
- Modify: `apps/mobile/lib/app.dart`
- Test: `apps/mobile/test/widget_test.dart`

- [ ] Write failing widget test showing cloud online teachings render in the Teachings tab.
- [ ] Add `onlineTeachingStore` injection and load rows on startup.
- [ ] Run the widget test.

### Task 3: Teachings UI

**Files:**
- Modify: `apps/mobile/lib/features/teachings/presentation/teachings_screen.dart`
- Test: `apps/mobile/test/widget_test.dart`

- [ ] Write failing widget test for active `JOIN NOW` on ongoing and disabled join on upcoming/finished.
- [ ] Render card list matching the mockup.
- [ ] Run widget tests.

### Task 4: Cloud SQL

**Files:**
- Create: `docs/sql/online_teachings_cloud.sql`

- [ ] Add runnable Supabase Cloud SQL for table, RLS, sample rows, and policies.
- [ ] Include the Zoom URL example.

### Task 5: Verification

- [ ] Run `flutter analyze` in `apps/mobile`.
- [ ] Run `flutter test` in `apps/mobile`.
- [ ] Report the cloud SQL path and any manual cloud DB step.
