# Improve UI Calendar and Dharma Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename Teachings to Dharma, make Calendar/Day active-date behavior consistent, and derive Dharma online event status from loaded datetimes.

**Architecture:** Keep active date ownership in `CalendarHomeScreen`; pass derived active date into `MonthScreen`; expose previous/next date callbacks to `TodayScreen`. Convert `TeachingsScreen` to a stateful screen that owns one minute timer and derives event statuses without requerying network data.

**Tech Stack:** Flutter, Dart widget tests, existing mobile localization files, existing Supabase row parsing.

---

## File Structure

- Modify `apps/mobile/lib/app.dart` for bottom navigation, active date state, and date selection callbacks.
- Modify `apps/mobile/lib/features/calendar/presentation/month_screen.dart` to highlight an injected active date.
- Modify `apps/mobile/lib/features/today/presentation/today_screen.dart` to detect horizontal swipes.
- Modify `apps/mobile/lib/features/teachings/data/online_teaching_database.dart` to parse `start_datetime` and `end_datetime`, keep compatibility fallbacks, and derive status.
- Modify `apps/mobile/lib/features/teachings/presentation/teachings_screen.dart` to show Dharma and refresh derived statuses with one timer.
- Modify `apps/mobile/lib/l10n/app_en.arb` and generated localization Dart files for the English Dharma label.
- Modify `apps/mobile/test/widget_test.dart` for behavior coverage.

## Tasks

- [x] Add failing tests for Dharma label, Calendar active date behavior, Day/Today swipes, and derived event status.
- [x] Run targeted Flutter widget tests and confirm the new tests fail for the expected missing behavior.
- [x] Implement active date state and Calendar tab behavior in `CalendarHomeScreen`.
- [x] Implement active date highlighting in `MonthScreen`.
- [x] Implement Day/Today horizontal swipe callbacks in `TodayScreen`.
- [x] Implement derived online teaching status and datetime parsing compatibility.
- [x] Convert `TeachingsScreen` to stateful timer-driven derived status refresh.
- [x] Update English localization label to Dharma.
- [x] Run targeted Flutter widget tests and confirm they pass.
- [x] Run full mobile tests and analyzer.
