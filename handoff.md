# Handoff

## Current State

- Repository: `C:\BaromKagyu\CalendarApp`
- Current branch: `phase-4`
- Base branch: `master`
- Branch started from: `85fcf88 Reduce launcher logo scale`
- Latest release APK: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
- APK built with real Supabase config from `.env.local`.

## Completed Work

- Added explicit Practice Day support for `public.calendar_entries`.
- Added startup sync so a fresh install immediately loads the latest Supabase data.
- Preserved hourly foreground sync and hourly Workmanager background sync.
- Updated Day/Today screen to show a Practice Day section below the day number/logo and above normal daily content.
- Updated Calendar screen so only rows with `is_practice_day = true` are highlighted and listed as Practice days.
- Updated Day/Today typography:
  - Practice Day title is maroon and bold.
  - Practice Day description is green, italic, and normal weight, matching `description_en`.
  - Daily calendar text renders normal weight.
  - Element text renders normal weight.

## Database Changes

- Added migration: `supabase/migrations/202609060001_calendar_practice_days.sql`
- New `public.calendar_entries` columns:
  - `is_practice_day boolean NOT NULL DEFAULT false`
  - `practice_day_title text`
  - `practice_day_description text`
  - `practice_day_image_url text`
- Updated the calendar change trigger function so Practice Day fields bump row versions when public published data changes.
- Added real Supabase helper SQL: `docs/sql/calendar_practice_days_cloud.sql`

## Key Files

- `apps/mobile/lib/app.dart`
- `apps/mobile/lib/features/calendar/data/calendar_database.dart`
- `apps/mobile/lib/features/calendar/data/shared_preferences_calendar_store.dart`
- `apps/mobile/lib/features/calendar/domain/calendar_entry.dart`
- `apps/mobile/lib/features/calendar/presentation/month_screen.dart`
- `apps/mobile/lib/features/today/presentation/today_screen.dart`
- `apps/mobile/test/widget_test.dart`
- `apps/mobile/test/core/network/supabase_calendar_feed_test.dart`
- `apps/mobile/test/features/calendar/data/shared_preferences_calendar_store_test.dart`
- `packages/contracts/src/calendar-entry.ts`
- `packages/contracts/src/calendar-entry.test.ts`
- `supabase/tests/calendar_entries_test.sql`
- `docs/mockups/practice-day-ui.html`

## Real Supabase Notes

- Do not use local Supabase Docker for this feature unless explicitly requested.
- Use `.env.local` for the real Supabase build-time Dart defines.
- Fresh installs call `calendar_changes(0)` and should automatically load Jan 02 2027 Practice Day data.
- Already-installed apps that synced past the Jan 02 row version may need this version bump in Supabase SQL Editor:

```sql
update public.calendar_entries
set
  version = nextval(pg_get_serial_sequence('public.calendar_entries', 'version')::regclass),
  updated_at = now()
where gregorian_date = date '2027-01-02'
returning
  gregorian_date,
  version,
  is_practice_day,
  practice_day_title,
  practice_day_description,
  practice_day_image_url;
```

## Verification Run

- `flutter test test\widget_test.dart`: passed
- `flutter analyze`: no issues
- `flutter test`: 101 tests passed
- `npm run test:contracts`: 8 tests passed
- `flutter build apk --release --dart-define-from-file=../../.env.local`: built successfully

## APK

- Path: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
- Size: `54,548,782` bytes
- Last built: `2026-09-06 3:28:10 PM`

## Known Notes

- `description_bo` is stored and synced, but the current Day/Today screen does not render it as a separate text widget.
- Android and iOS background sync are best-effort and controlled by OS scheduling, battery, and network conditions.
- Android release build prints a Flutter warning that `workmanager_android` applies Kotlin Gradle Plugin. The build succeeds, but a future Flutter version may require a plugin update.
