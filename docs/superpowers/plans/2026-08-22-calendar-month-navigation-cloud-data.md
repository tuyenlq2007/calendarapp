# Calendar Month Navigation Cloud Data Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add month navigation and month selection to the mobile Calendar tab, then seed Supabase Cloud with published dummy calendar entries.

**Architecture:** Keep the existing sync service and store. Change mobile state to retain all synchronized rows and derive the visible month from a selected `DateTime` cursor. Add calendar UI controls to change that cursor and render empty months.

**Tech Stack:** Flutter/Dart widget tests, Supabase REST API, Android emulator deployment.

---

## File Map

- `apps/mobile/test/widget_test.dart`: widget tests for month navigation and month selector behavior.
- `apps/mobile/lib/features/calendar/domain/calendar_entry.dart`: helpers to derive an arbitrary month from feed rows.
- `apps/mobile/lib/features/calendar/presentation/month_screen.dart`: previous/next controls, January-December selector, empty state.
- `apps/mobile/lib/app.dart`: selected month state and synchronized row retention.
- `docs/superpowers/specs/2026-08-22-calendar-month-navigation-cloud-data-design.md`: approved design.

## Task 1: Add Failing Calendar Navigation Tests

- [ ] Add a widget test that opens Calendar, taps the next-month button, and expects the title to change from the initial month to the next month.
- [ ] Add a widget test that opens Calendar, taps the December selector, and expects the December selector to be selected.
- [ ] Run `flutter test test/widget_test.dart` and confirm the tests fail because the controls do not exist.

## Task 2: Implement Month Derivation and UI Controls

- [ ] Add a helper that derives a `CalendarMonth` for a requested year/month from synchronized rows.
- [ ] Store the selected month cursor and synchronized calendar rows in `CalendarHomeScreen`.
- [ ] Pass month-change callbacks to `MonthScreen`.
- [ ] Add previous/next icon buttons and a January-December selector.
- [ ] Add an empty-state message for months with no entries.
- [ ] Run `flutter test test/widget_test.dart` and confirm the tests pass.

## Task 3: Seed Supabase Cloud and Deploy APK

- [ ] Insert dummy published rows into `public.calendar_entries` for January through December.
- [ ] Build the release APK with `flutter build apk --release --dart-define-from-file=../../.env.local`.
- [ ] Install the APK with `adb install -r`.
- [ ] Launch `org.baromkagyu` on the Android emulator.
