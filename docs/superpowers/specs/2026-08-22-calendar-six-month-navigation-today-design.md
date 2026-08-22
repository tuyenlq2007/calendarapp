# Calendar Six-Month Navigation and Today Design

Date: 2026-08-22
Status: Approved for implementation

## Goal

Update the Calendar tab so month selection shows only a focused six-month range around the active month, while the Calendar header Today action opens the Today tab with the actual current day.

## Scope

- Replace the twelve-month selector with six visible month chips.
- Keep previous and next icon buttons for month movement.
- Highlight the selected month and separately indicate the real current month when visible.
- Make the Calendar header Today label tappable.
- When Calendar Today is tapped, switch to the Today tab and show the current day entry if it exists in synced data.
- If the current day has no synced entry, show a current-day empty state instead of an old sample day.

## Verification

- Widget test for six visible month chips.
- Widget test for previous/next month movement with the six-month selector.
- Widget test for Calendar Today opening the Today tab with the current day.
- Run Flutter widget tests, network feed tests, analyzer, then rebuild and install the APK.
