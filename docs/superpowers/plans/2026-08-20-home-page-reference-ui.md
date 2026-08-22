# Home Page Reference UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild the Flutter Today/home tab to closely match the supplied red-and-gold Tibetan calendar reference UI.

**Architecture:** Keep the current Flutter app structure and data model. Implement the reference layout inside `TodayScreen`, update the shared app theme and bottom navigation styling in `app.dart`, and cover the UI with widget/theme tests before production changes.

**Tech Stack:** Flutter, Dart, Material widgets, flutter_test.

---

## File Structure

- `apps/mobile/test/widget_test.dart`: Add failing widget expectations for reference-style home labels and large text resilience.
- `apps/mobile/test/core/theme/app_theme_test.dart`: Add failing theme expectations for the new red/gold navigation and scaffold palette.
- `apps/mobile/lib/features/today/presentation/today_screen.dart`: Replace the parchment card layout with the red full-screen reference-style layout.
- `apps/mobile/lib/app.dart`: Style the bottom `NavigationBar` to match the red/gold reference while keeping existing destinations.
- `apps/mobile/lib/core/theme/app_theme.dart`: Add the shared dark red scaffold surface and navigation bar theme.

### Task 1: Add Failing Home UI Tests

**Files:**
- Modify: `apps/mobile/test/widget_test.dart`

- [ ] **Step 1: Write the failing home layout expectations**

Add assertions to `today screen shows bilingual Barom Kagyu calendar content`:

```dart
expect(find.text('Select Day'), findsOneWidget);
expect(find.text('Water - Wind'), findsOneWidget);
expect(find.text('Negative Elemental Combination'), findsOneWidget);
expect(find.text('Date'), findsOneWidget);
expect(find.text('Month'), findsOneWidget);
expect(find.text('Year'), findsOneWidget);
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/widget_test.dart`

Expected: FAIL because the current Today screen does not render `Select Day` or elemental metadata.

### Task 2: Add Failing Theme Tests

**Files:**
- Modify: `apps/mobile/test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Write the failing reference palette expectations**

Add:

```dart
test('home reference theme uses dark red surfaces and gold navigation', () {
  expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFF610005));
  expect(AppTheme.light.colorScheme.secondary, const Color(0xFFF6D985));
  expect(AppTheme.light.navigationBarTheme.backgroundColor, const Color(0xFF570005));
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`

Expected: FAIL because the current scaffold background is parchment and no navigation bar background color is configured.

### Task 3: Implement the Reference Today Layout

**Files:**
- Modify: `apps/mobile/lib/features/today/presentation/today_screen.dart`

- [ ] **Step 1: Replace the current card layout**

Implement a `Scaffold` with a dark red body, a `SafeArea`, a scroll view, a top header, a hero day panel, an elemental panel, and a Date / Month / Year panel. Use the existing `entry` and `monthTitle` values for dynamic calendar content.

- [ ] **Step 2: Run the home widget test**

Run: `flutter test test/widget_test.dart`

Expected: PASS for the new home layout expectations and existing navigation expectations.

### Task 4: Implement the Theme and Navigation Polish

**Files:**
- Modify: `apps/mobile/lib/core/theme/app_theme.dart`
- Modify: `apps/mobile/lib/app.dart`

- [ ] **Step 1: Update `AppTheme.light`**

Set the scaffold background to dark red, keep high-contrast white/red text colors, and configure `navigationBarTheme` with dark red, gold labels/icons, and a pale selected indicator.

- [ ] **Step 2: Update the bottom navigation wrapper**

Wrap the existing `NavigationBar` in a rounded dark red surface only if needed by Flutter rendering, while preserving the same four destinations and existing localization labels.

- [ ] **Step 3: Run theme and widget tests**

Run: `flutter test test/core/theme/app_theme_test.dart test/widget_test.dart`

Expected: PASS with the new reference palette and unchanged app behavior.

### Task 5: Verify Mobile Checks

**Files:**
- No production file changes unless verification exposes issues.

- [ ] **Step 1: Run focused tests**

Run: `flutter test test/widget_test.dart test/core/theme/app_theme_test.dart`

Expected: all focused tests pass.

- [ ] **Step 2: Run analyzer**

Run: `flutter analyze`

Expected: analyzer exits 0.

- [ ] **Step 3: Run the mobile test suite**

Run: `flutter test`

Expected: all mobile tests pass.
