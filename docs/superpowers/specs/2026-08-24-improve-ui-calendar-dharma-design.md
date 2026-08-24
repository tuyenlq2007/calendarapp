# Improve UI Calendar and Dharma Design

Date: 2026-08-24
Status: Approved for implementation

## Goal

Improve navigation clarity and date behavior in the mobile app by renaming Teachings to Dharma, making Calendar reopen on the active date, adding Day/Today swipe navigation, and deriving Dharma event status from event datetimes.

## Scope

- Rename the English Teachings navigation and screen label to Dharma.
- Keep the existing Tibetan label unchanged.
- When the bottom Calendar tab is tapped, open the month that contains the active date.
- The active date is the selected day if one exists; otherwise it is the real current date.
- Use the red calendar cell to mark the active date, not the first practice entry in the month.
- On the Day/Today screen, swipe left to select the next date and swipe right to select the previous date.
- When a swiped-to date has no practice content, show the existing current empty-day state for that date.
- In Dharma online events, derive Upcoming, Ongoing, and Finished from start and end datetimes loaded on the device.
- Recalculate derived Dharma status when the screen opens and once per minute while mounted.
- Do not query Supabase every minute.
- Cancel the Dharma status timer when the screen is disposed.

## Data Model

Online Dharma events should use UTC-capable event datetimes:

- `start_datetime`
- `end_datetime`

The client will keep compatibility with existing `start_date`, `end_date`, and `status` fields during migration, but the UI status must come from datetime comparison when datetime data is available.

## Status Rules

- `now < start` means Upcoming.
- `start <= now < end` means Ongoing.
- `now >= end` means Finished.

The derived status controls both the status pill and the enabled state of the JOIN NOW button.

## Verification

- Widget tests for the Dharma label.
- Widget tests for Calendar reopening on today or a selected/swiped date.
- Widget tests for Day/Today swipe previous and next date behavior.
- Unit/widget tests for derived Dharma online event status.
- Run the mobile widget test suite and Flutter analyzer.
