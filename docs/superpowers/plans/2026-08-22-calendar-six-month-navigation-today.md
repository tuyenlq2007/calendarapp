# Calendar Six-Month Navigation Today Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show only six nearby month chips in Calendar and make Calendar Today open the current day on the Today tab.

**Architecture:** Keep `CalendarHomeScreen` as the owner of selected date state. `MonthScreen` renders a derived six-month chip window and exposes a Today callback. Current date is injectable for tests and defaults to `DateTime.now()`.

**Tech Stack:** Flutter/Dart widget tests, existing mobile app state, Android APK deployment.

---

## Tasks

- [ ] Add failing widget tests for six visible month chips and Calendar Today navigation.
- [ ] Implement current-date injection and current-day entry derivation.
- [ ] Update `MonthScreen` to render six month chips and clickable Today action.
- [ ] Run tests and analyzer.
- [ ] Build and install release APK on emulator.
