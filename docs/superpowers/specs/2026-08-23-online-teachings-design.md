# Online Teachings Design

## Goal

Replace the Teachings tab’s primary experience with cloud-backed online teaching/practice cards matching the approved mockup in `docs/mockups/online-teachings-design.html`.

## Data Model

Create a new cloud table named `online_teachings`. This data is separate from `content_entries` because it represents live sessions and Zoom links, not articles or videos for offline reading.

Fields:
- `id uuid`
- `title text`
- `practice text`
- `start_date date`
- `end_date date`
- `status text`, constrained to `upcoming`, `ongoing`, or `finished`
- `join_url text`
- `display_order integer`
- `published boolean`
- `updated_at timestamptz`

Anonymous mobile clients can read only `published = true` rows.

## Mobile UI

The Teachings tab shows a scrollable list of online teaching cards. Each card includes title, practice label and text, date range, status pill, and a `JOIN NOW` button. The button is active only for `ongoing`; `upcoming` and `finished` are visually disabled.

If there are no cloud online teachings yet, the app may continue showing the existing teaching content fallback.

## Cloud SQL

The implementation must include a SQL file/query the user can run in Supabase Cloud. No local Supabase dependency is required for applying the change.
