# Barom Kagyu Community App Design

Date: 2026-08-17
Status: Approved in conversation; awaiting review of the written specification

## Purpose

Build a public iOS and Android app for the Barom Kagyu community. The app combines an authoritative Tibetan calendar with reminders, teachings, news, events, videos, and monastery information. It launches in Tibetan and English and remains ready for additional languages.

## Product Principles

- Barom Kagyu staff remain the authority for all Tibetan calendar data and translations.
- Regular users can access all public content without an account.
- The calendar and saved teachings remain useful without internet access.
- The interface preserves a traditional Barom Kagyu identity while providing modern readability and accessibility.
- The first release establishes a reusable publishing foundation before expanding community content.

## Delivery Scope

### Phase 1: Publishing Foundation and Calendar

- Flutter app for iOS and Android
- Tibetan and English localization
- Today view
- Gregorian and staff-entered Tibetan calendar views
- Daily practices, observances, anniversaries, and auspicious days
- Category-based notifications
- Offline calendar and background synchronization
- Secure staff dashboard with drafting, review, scheduling, and publishing

### Phase 2: Teachings and Media

- Bilingual articles and categorized teachings
- YouTube-linked videos
- Bookmarks stored locally on the device
- Offline copies of eligible text and image content
- An offline library for saved content

YouTube playback requires connectivity unless the official YouTube client independently makes a video available offline. The Barom Kagyu app will not download or redistribute YouTube video files.

### Phase 3: Community

- News and community events
- Monastery information and contact details
- Announcements using the shared notification system

## User Experience

The mobile app has five primary destinations:

1. **Today:** Tibetan date, daily practice, observances, featured sacred image, and quick access to reminders.
2. **Calendar:** Month and agenda views showing Gregorian dates alongside authoritative Tibetan date text.
3. **Teachings:** Bilingual articles, categories, search, and YouTube videos.
4. **Community:** News, events, monastery details, and contact information.
5. **More:** Language, notifications, downloads, text size, about, and legal information.

All public content is available without sign-in. Preferences, bookmarks, downloads, and reminder choices remain on the current device and do not synchronize between devices.

## Visual Direction

The design is "modern traditional":

- Deep maroon navigation with restrained gold highlights
- Warm parchment surfaces and subtle Tibetan motifs
- Tibetan and English fonts selected for legibility
- Large calendar cells, clear hierarchy, and adjustable text size
- Sacred imagery used selectively rather than decoratively on every screen
- Modern cards, spacing, and labeled bottom navigation
- Light theme in the initial release; dark mode is outside the initial scope

The supplied reference image informs the color palette and identity, but the interface will not reproduce its dense layout or small text.

## Content Model

### Calendar Entry

A calendar entry contains:

- Gregorian date
- Authoritative Tibetan date text
- Optional lunar-day, element, animal, and year labels
- Tibetan and English title and description
- Entry type and categories
- Practice instructions or observance details
- Optional sacred image
- Optional recurrence rule
- Notification eligibility, priority, and default delivery time
- Draft, review, scheduled, published, corrected, or archived state
- Revision metadata and publication timestamps

No Tibetan calendar date is calculated by the app. Staff enter and verify the authoritative values in the dashboard.

### Other Published Content

Teachings, news, events, monastery profiles, and videos share common bilingual fields, publication state, categories, images, authorship, revision history, and scheduling metadata. Videos store validated YouTube URLs and display metadata; the backend does not host the video stream.

## Publishing Workflow

Staff use a separate responsive web dashboard:

- **Editors** create and translate drafts.
- **Reviewers** approve, reject, schedule, publish, correct, and archive content.
- **Administrators** have reviewer abilities and manage staff, roles, categories, and global settings.

Only published content reaches the public API. Required Tibetan and English fields are validated before publication. Image processing creates mobile-appropriate variants, and YouTube URLs are validated. Revision history allows staff to inspect and restore earlier published content.

## Architecture

### Mobile

- Flutter and Dart
- Feature-oriented modules with clear interfaces for content, storage, notifications, and networking
- Local relational database for published content and user preferences
- Background synchronization using a versioned content feed
- Platform notification adapters for iOS and Android

### Dashboard

- Next.js web application
- Authenticated server-side access to administrative operations
- Bilingual editing, preview, review queue, scheduling, media management, and audit history

### Backend

- Supabase-managed PostgreSQL, authentication, object storage, and server functions
- Public read access limited to published records and approved media
- Administrative writes enforced by role-based policies and server-side validation
- Push-notification jobs triggered only for approved, published content

The dashboard uses Supabase authentication; the consumer app does not expose account creation or sign-in.

## Data Flow and Offline Behavior

1. Staff create and review bilingual content in the dashboard.
2. Publication creates a new revision in the versioned public feed.
3. The mobile app opens immediately from its local database.
4. When online, it requests changes newer than its last successful sync.
5. The app validates and applies the change set transactionally, then records the new sync version.
6. Content removed from publication is withdrawn from normal browsing on the next successful sync.

The calendar and previously synchronized text/image content remain available offline. Users can explicitly save eligible teachings. If synchronization fails, local content stays intact and the app shows a subtle last-updated status with a retry action. A partially downloaded or invalid update is discarded rather than leaving the local database in a mixed state.

## Notifications

Users can independently enable or disable:

- Daily practices and holy days
- Calendar events
- New teachings
- News and community announcements

Calendar reminders are scheduled locally from synchronized authoritative entries. Publication announcements are sent through push notifications. Tapping a notification opens the corresponding item; if it is unavailable, the app opens the relevant section and explains that the item could not be loaded.

Notification permission is requested in context after the user chooses a category, not automatically on first launch.

## Accessibility and Localization

- Complete Tibetan and English interface localization at launch
- Content schema supports more languages without redesign
- Correct Unicode Tibetan rendering, wrapping, and search normalization
- Dynamic text sizing and screen-reader labels
- Color contrast that does not rely on gold against parchment for essential text
- Gregorian dates remain machine-readable while Tibetan dates remain authoritative staff-entered display content

## Reliability, Security, and Privacy

- Public clients can read only published data.
- Administrative operations use least-privilege role policies.
- Drafts and audit records are never returned by public endpoints.
- Failed edits do not discard dashboard drafts.
- Images are type-checked, size-limited, and processed before publication.
- Secrets remain in server-side configuration and are not bundled into the app.
- The app collects privacy-respecting crash diagnostics and no personal user profile.
- Device preferences and saved items can be removed through app settings or operating-system app-data controls.

## Testing and Acceptance

Automated tests cover:

- Calendar rendering across month boundaries and device sizes
- Tibetan and English text layout and localization fallback
- Transactional offline synchronization, withdrawal, retry, and migration
- Local reminders, permission states, time-zone changes, and notification deep links
- Dashboard role permissions and publication state transitions
- Required translation validation, revision restoration, media processing, and YouTube URL validation
- Public API isolation from drafts and administrative data

Release validation includes representative recent iPhones and Android phones, slow/offline network scenarios, app upgrades with existing local data, accessibility text scaling, and staff acceptance of the publishing workflow.

Phase 1 is accepted when staff can publish a verified bilingual calendar update, both platforms synchronize and display it correctly, users can configure reminders, and synchronized calendar content remains usable offline.

## Explicitly Out of Scope for Initial Release

- Automatic Tibetan calendar calculation
- Required or optional consumer accounts
- Cross-device bookmark or preference synchronization
- Directly hosted video streaming
- YouTube video downloading or redistribution
- Donations, chat, social networking, and live-stream production
- Dark mode

