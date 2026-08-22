# Calendar Month Navigation and Cloud Dummy Data Design

Date: 2026-08-22
Status: Approved for implementation

## Goal

Improve the mobile Calendar tab so users can move between months, select any month from January through December, see the current month highlighted, and view published calendar entries synchronized from Supabase Cloud.

## Scope

- Add previous and next month controls to the Calendar tab.
- Add a compact January-December month selector.
- Highlight the current real month and the selected month.
- Render the selected month grid even when it has no events.
- Filter synchronized calendar entries by the selected month and year.
- Insert dummy published calendar rows into Supabase Cloud for the current calendar year.

## Design

The app state will keep all locally synchronized calendar rows plus a selected month cursor. The Calendar tab will derive a `CalendarMonth` for that selected month from the stored rows. Previous and next buttons change the selected month by one month. The month selector changes only the month within the selected year. The current month chip is visually distinct from ordinary months, and the selected month chip uses the strongest selection treatment.

The Supabase Cloud data will be inserted into `public.calendar_entries` as published rows. The existing `calendar_changes(after_version)` RPC will expose those rows to the app through the existing calendar sync service. The mobile app will continue using the anon key for reads; the service-role key is used only for one-time data insertion.

## Error Handling

If Cloud sync fails, the app keeps the existing local calendar data and shows the existing sync failure message. If a selected month has no entries, the calendar still shows the month grid and an empty-state message.

## Verification

- Add widget tests for previous/next month navigation.
- Add widget tests for January-December selector behavior and current month highlight.
- Run Flutter tests.
- Insert dummy rows into Supabase Cloud.
- Build a release APK with the Supabase Cloud env file.
- Install and launch the APK on the Android emulator.
