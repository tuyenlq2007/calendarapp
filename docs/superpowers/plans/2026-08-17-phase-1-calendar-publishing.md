# Phase 1 Calendar Publishing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver a testable Flutter iOS/Android calendar app and Next.js staff dashboard that publish, synchronize, display, and remind users about authoritative bilingual Barom Kagyu calendar entries.

**Architecture:** Use a monorepo with a feature-oriented Flutter client, a Next.js administrative web app, and Supabase migrations/functions. The public app reads only published versioned records, applies changes transactionally to Drift, and schedules reminders locally; staff writes use authenticated role policies.

**Tech Stack:** Flutter/Dart, Riverpod, Drift/SQLite, Dio, flutter_local_notifications, Next.js/TypeScript, Vitest, Playwright, Supabase/PostgreSQL, pgTAP

---

## File Map

- `apps/mobile/`: Flutter consumer app; `lib/features/*` owns each user-facing feature and `lib/core/*` owns shared infrastructure.
- `apps/admin/`: Next.js staff dashboard; route groups separate authenticated publishing pages from shared server utilities.
- `supabase/migrations/`: ordered schema, policy, and public-feed SQL.
- `supabase/tests/`: database behavior and authorization tests.
- `packages/contracts/`: TypeScript schemas and generated JSON schema consumed by both clients.
- `.github/workflows/ci.yml`: repeatable mobile, web, and database checks.

### Task 1: Create the Monorepo Skeleton and CI Contract

**Files:**
- Create: `.gitignore`
- Create: `README.md`
- Create: `package.json`
- Create: `.github/workflows/ci.yml`
- Create: `apps/mobile/` with `flutter create`
- Create: `apps/admin/` with `create-next-app`

- [ ] **Step 1: Add the root workspace contract**

```json
{
  "name": "barom-kagyu-calendar",
  "private": true,
  "workspaces": ["apps/admin", "packages/contracts"],
  "scripts": {
    "test:admin": "npm --workspace apps/admin test",
    "lint:admin": "npm --workspace apps/admin run lint"
  }
}
```

- [ ] **Step 2: Scaffold both applications**

Run:

```powershell
flutter create --org org.baromkagyu --platforms android,ios apps/mobile
npx create-next-app@latest apps/admin --ts --eslint --app --src-dir --use-npm --no-tailwind --import-alias "@/*"
npm install
```

Expected: both commands exit 0; `apps/mobile/pubspec.yaml` and `apps/admin/package.json` exist.

- [ ] **Step 3: Add repository ignores**

```gitignore
.dart_tool/
.flutter-plugins*
build/
.next/
node_modules/
.env
.env.local
coverage/
.superpowers/
brainstorm-server.*.log
```

- [ ] **Step 4: Add the CI workflow**

```yaml
name: ci
on: [push, pull_request]
jobs:
  mobile:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
        working-directory: apps/mobile
      - run: flutter analyze
        working-directory: apps/mobile
      - run: flutter test
        working-directory: apps/mobile
  admin:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22, cache: npm }
      - run: npm ci
      - run: npm run lint:admin
      - run: npm run test:admin
```

- [ ] **Step 5: Verify clean scaffolds**

Run: `flutter test apps/mobile/test/widget_test.dart; npm run lint:admin`

Expected: Flutter sample test passes and Next.js lint exits 0.

- [ ] **Step 6: Commit**

```powershell
git add .gitignore README.md package.json package-lock.json .github apps
git commit -m "chore: scaffold mobile and admin applications"
```

### Task 2: Define Calendar Contracts and Database Schema

**Files:**
- Create: `packages/contracts/package.json`
- Create: `packages/contracts/src/calendar-entry.ts`
- Create: `packages/contracts/src/calendar-entry.test.ts`
- Create: `supabase/migrations/202608170001_calendar_entries.sql`
- Create: `supabase/tests/calendar_entries_test.sql`

- [ ] **Step 1: Write the failing contract test**

```ts
import { describe, expect, it } from "vitest";
import { CalendarEntrySchema } from "./calendar-entry";

describe("CalendarEntrySchema", () => {
  it("rejects a published entry missing Tibetan content", () => {
    const result = CalendarEntrySchema.safeParse({
      id: crypto.randomUUID(), gregorianDate: "2026-08-17",
      titleEn: "Practice day", titleBo: "", descriptionEn: "Text",
      descriptionBo: "ཡི་གེ", status: "published", version: 1
    });
    expect(result.success).toBe(false);
  });
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `npm --workspace packages/contracts test`

Expected: FAIL because `CalendarEntrySchema` does not exist.

- [ ] **Step 3: Implement the shared schema**

```ts
import { z } from "zod";

export const CalendarEntrySchema = z.object({
  id: z.string().uuid(),
  gregorianDate: z.string().date(),
  tibetanDateText: z.string().min(1),
  titleEn: z.string().min(1), titleBo: z.string().min(1),
  descriptionEn: z.string(), descriptionBo: z.string(),
  status: z.enum(["draft", "review", "scheduled", "published", "archived"]),
  version: z.number().int().positive()
});
export type CalendarEntry = z.infer<typeof CalendarEntrySchema>;
```

- [ ] **Step 4: Add the migration with publication validation**

```sql
create type public.publication_status as enum
  ('draft','review','scheduled','published','archived');
create table public.calendar_entries (
  id uuid primary key default gen_random_uuid(),
  gregorian_date date not null,
  tibetan_date_text text not null default '',
  title_en text not null default '', title_bo text not null default '',
  description_en text not null default '', description_bo text not null default '',
  status public.publication_status not null default 'draft',
  version bigint generated always as identity,
  published_at timestamptz,
  updated_at timestamptz not null default now(),
  check (status <> 'published' or
    (tibetan_date_text <> '' and title_en <> '' and title_bo <> ''))
);
alter table public.calendar_entries enable row level security;
create policy "public reads published calendar"
on public.calendar_entries for select to anon
using (status = 'published');
```

- [ ] **Step 5: Add and run a pgTAP policy test**

```sql
begin;
select plan(1);
set local role anon;
select results_eq(
  $$select count(*) from public.calendar_entries where status <> 'published'$$,
  array[0::bigint], 'anonymous users cannot read drafts'
);
select * from finish();
rollback;
```

Run: `npm --workspace packages/contracts test; supabase db reset; supabase test db`

Expected: contract test and one pgTAP assertion pass.

- [ ] **Step 6: Commit**

```powershell
git add packages supabase
git commit -m "feat: define authoritative calendar entry contract"
```

### Task 3: Implement Versioned Public Synchronization

**Files:**
- Create: `supabase/migrations/202608170002_public_feed.sql`
- Create: `apps/mobile/lib/features/calendar/data/calendar_database.dart`
- Create: `apps/mobile/lib/features/calendar/data/calendar_sync_service.dart`
- Create: `apps/mobile/test/features/calendar/data/calendar_sync_service_test.dart`

- [ ] **Step 1: Write the failing transactional sync test**

```dart
test('failed page does not advance sync version', () async {
  final store = FakeCalendarStore(version: 4, failOnEntry: 'bad');
  final service = CalendarSyncService(FakeFeed(version: 5), store);
  await expectLater(service.sync(), throwsA(isA<FormatException>()));
  expect(await store.currentVersion(), 4);
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/features/calendar/data/calendar_sync_service_test.dart`

Expected: FAIL because sync classes are undefined.

- [ ] **Step 3: Add the public feed function**

```sql
create or replace function public.calendar_changes(after_version bigint)
returns setof public.calendar_entries
language sql stable security invoker
as $$
  select * from public.calendar_entries
  where version > after_version and status in ('published','archived')
  order by version asc limit 500;
$$;
grant execute on function public.calendar_changes(bigint) to anon;
```

- [ ] **Step 4: Implement the transaction boundary**

```dart
class CalendarSyncService {
  CalendarSyncService(this.feed, this.store);
  final CalendarFeed feed;
  final CalendarStore store;

  Future<void> sync() async {
    final page = await feed.changesAfter(await store.currentVersion());
    await store.transaction(() async {
      for (final entry in page.entries) {
        entry.validate();
        await store.upsertOrWithdraw(entry);
      }
      await store.setCurrentVersion(page.version);
    });
  }
}
```

- [ ] **Step 5: Run sync tests**

Run: `flutter test test/features/calendar/data/calendar_sync_service_test.dart`

Expected: transactional failure and successful update tests pass.

- [ ] **Step 6: Commit**

```powershell
git add supabase apps/mobile/lib/features/calendar apps/mobile/test/features/calendar
git commit -m "feat: synchronize versioned calendar content offline"
```

### Task 4: Build Today and Calendar Screens

**Files:**
- Create: `apps/mobile/lib/app.dart`
- Create: `apps/mobile/lib/features/today/presentation/today_screen.dart`
- Create: `apps/mobile/lib/features/calendar/presentation/calendar_screen.dart`
- Create: `apps/mobile/lib/features/calendar/presentation/calendar_day_cell.dart`
- Create: `apps/mobile/test/features/today/today_screen_test.dart`
- Create: `apps/mobile/test/features/calendar/calendar_screen_test.dart`

- [ ] **Step 1: Write the failing bilingual Today test**

```dart
testWidgets('shows Gregorian, Tibetan, and practice text', (tester) async {
  await tester.pumpWidget(testApp(entry: fixtureEntry));
  expect(find.text('17'), findsOneWidget);
  expect(find.text('ཚེས་ ༤'), findsOneWidget);
  expect(find.text('Guru Rinpoche day'), findsOneWidget);
});
```

- [ ] **Step 2: Verify it fails**

Run: `flutter test test/features/today/today_screen_test.dart`

Expected: FAIL because `TodayScreen` does not exist.

- [ ] **Step 3: Implement the focused Today layout**

```dart
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.entry});
  final CalendarEntry entry;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Today')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('${entry.gregorianDate.day}', style: Theme.of(context).textTheme.displayLarge),
      Text(entry.tibetanDateText, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      Text(entry.localizedTitle(Localizations.localeOf(context))),
      Text(entry.localizedDescription(Localizations.localeOf(context))),
    ]));
}
```

- [ ] **Step 4: Implement and test a seven-column month grid**

```dart
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({super.key, required this.day, required this.tibetanText});
  final int day; final String tibetanText;
  @override Widget build(BuildContext context) => Semantics(
    label: 'Day $day, $tibetanText',
    child: Column(children: [Text('$day'), Text(tibetanText, maxLines: 1)]));
}
```

Run: `flutter test test/features/today test/features/calendar`

Expected: Today and calendar widget tests pass at normal and 200% text scale.

- [ ] **Step 5: Commit**

```powershell
git add apps/mobile/lib apps/mobile/test
git commit -m "feat: add bilingual today and calendar views"
```

### Task 5: Add Localization and Modern Traditional Theme

**Files:**
- Modify: `apps/mobile/pubspec.yaml`
- Create: `apps/mobile/lib/l10n/app_en.arb`
- Create: `apps/mobile/lib/l10n/app_bo.arb`
- Create: `apps/mobile/lib/core/theme/app_theme.dart`
- Create: `apps/mobile/test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Write the failing contrast/theme test**

```dart
test('essential parchment text uses high-contrast maroon', () {
  expect(AppTheme.light.colorScheme.onSurface, const Color(0xFF3A1717));
  expect(AppTheme.light.colorScheme.primary, const Color(0xFF8B0E2F));
});
```

- [ ] **Step 2: Verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`

Expected: FAIL because `AppTheme` is undefined.

- [ ] **Step 3: Add theme and translations**

```dart
abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFF4D6),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B0E2F),
      surface: const Color(0xFFFFF4D6),
      onSurface: const Color(0xFF3A1717)),
  );
}
```

```json
{"@@locale":"en","today":"Today","calendar":"Calendar","lastUpdated":"Last updated: {date}"}
```

```json
{"@@locale":"bo","today":"དེ་རིང་།","calendar":"ལོ་ཐོ།","lastUpdated":"ཐ་མའི་གསར་སྒྱུར། {date}"}
```

- [ ] **Step 4: Generate localization and run checks**

Run: `flutter gen-l10n; flutter analyze; flutter test`

Expected: generation succeeds, analyzer is clean, and all tests pass.

- [ ] **Step 5: Commit**

```powershell
git add apps/mobile
git commit -m "feat: add Tibetan localization and Barom Kagyu theme"
```

### Task 6: Add Local Reminder Categories

**Files:**
- Create: `apps/mobile/lib/features/reminders/domain/reminder_category.dart`
- Create: `apps/mobile/lib/features/reminders/data/reminder_scheduler.dart`
- Create: `apps/mobile/lib/features/settings/presentation/notification_settings_screen.dart`
- Create: `apps/mobile/test/features/reminders/reminder_scheduler_test.dart`

- [ ] **Step 1: Write the failing scheduling test**

```dart
test('holy-day preference schedules only holy-day entries', () async {
  final notifications = FakeNotifications();
  final scheduler = ReminderScheduler(notifications);
  await scheduler.rebuild(entries, {ReminderCategory.holyDays});
  expect(notifications.scheduled.map((n) => n.entryId), ['holy-1']);
});
```

- [ ] **Step 2: Verify it fails**

Run: `flutter test test/features/reminders/reminder_scheduler_test.dart`

Expected: FAIL because `ReminderScheduler` is undefined.

- [ ] **Step 3: Implement deterministic category filtering**

```dart
enum ReminderCategory { dailyPractice, holyDays, calendarEvents, teachings, news }

class ReminderScheduler {
  ReminderScheduler(this.notifications);
  final NotificationsPort notifications;
  Future<void> rebuild(List<CalendarEntry> entries, Set<ReminderCategory> enabled) async {
    await notifications.cancelCalendarNotifications();
    for (final entry in entries.where((e) => enabled.contains(e.reminderCategory))) {
      await notifications.schedule(entry.toNotification());
    }
  }
}
```

- [ ] **Step 4: Test permission denial and time-zone rebuilding**

Run: `flutter test test/features/reminders`

Expected: filtering, denial-without-error, and time-zone rebuild tests pass.

- [ ] **Step 5: Commit**

```powershell
git add apps/mobile/lib/features/reminders apps/mobile/lib/features/settings apps/mobile/test/features/reminders
git commit -m "feat: add configurable local calendar reminders"
```

### Task 7: Build Staff Authentication and Role Policies

**Files:**
- Create: `supabase/migrations/202608170003_staff_roles.sql`
- Create: `supabase/tests/staff_roles_test.sql`
- Create: `apps/admin/src/lib/supabase/server.ts`
- Create: `apps/admin/src/middleware.ts`
- Create: `apps/admin/src/app/login/page.tsx`

- [ ] **Step 1: Write failing database permission assertions**

```sql
begin;
select plan(2);
select throws_ok(
  $$set local role authenticated; insert into public.calendar_entries
    (gregorian_date, title_en) values ('2026-08-17','Draft')$$,
  '42501', null, 'unassigned staff cannot create drafts');
select ok(public.has_staff_role('editor'), 'editor role is recognized');
select * from finish();
rollback;
```

- [ ] **Step 2: Verify the policy test fails**

Run: `supabase db reset; supabase test db`

Expected: FAIL because `has_staff_role` is undefined.

- [ ] **Step 3: Add staff roles and least-privilege policies**

```sql
create type public.staff_role as enum ('editor','reviewer','administrator');
create table public.staff_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role public.staff_role not null
);
create function public.has_staff_role(required_role public.staff_role)
returns boolean language sql stable security definer set search_path = public
as $$ select exists(select 1 from staff_profiles where user_id = auth.uid()
  and role = required_role) $$;
create policy "editors create drafts" on public.calendar_entries
for insert to authenticated with check (
  public.has_staff_role('editor') and status = 'draft');
```

- [ ] **Step 4: Protect dashboard routes server-side**

```ts
export async function middleware(request: NextRequest) {
  const response = NextResponse.next({ request });
  const supabase = createServerClient(url, anonKey, cookieOptions(request, response));
  const { data } = await supabase.auth.getUser();
  if (!data.user && !request.nextUrl.pathname.startsWith("/login"))
    return NextResponse.redirect(new URL("/login", request.url));
  return response;
}
export const config = { matcher: ["/calendar/:path*", "/staff/:path*"] };
```

- [ ] **Step 5: Run database and web checks**

Run: `supabase test db; npm --workspace apps/admin test; npm run lint:admin`

Expected: role assertions, web tests, and lint pass.

- [ ] **Step 6: Commit**

```powershell
git add supabase apps/admin
git commit -m "feat: secure staff dashboard with publishing roles"
```

### Task 8: Build the Bilingual Calendar Publishing Workflow

**Files:**
- Create: `apps/admin/src/app/calendar/page.tsx`
- Create: `apps/admin/src/app/calendar/new/page.tsx`
- Create: `apps/admin/src/features/calendar/calendar-form.tsx`
- Create: `apps/admin/src/features/calendar/calendar-actions.ts`
- Create: `apps/admin/src/features/calendar/calendar-actions.test.ts`

- [ ] **Step 1: Write the failing publication validation test**

```ts
it("does not publish an entry without both titles", async () => {
  const result = await publishEntry(db, {
    id: "9a4136e0-7254-4ee3-943c-6f552e087452", titleEn: "Practice", titleBo: ""
  });
  expect(result).toEqual({ ok: false, field: "titleBo", message: "Tibetan title is required" });
});
```

- [ ] **Step 2: Verify it fails**

Run: `npm --workspace apps/admin test -- calendar-actions.test.ts`

Expected: FAIL because `publishEntry` is undefined.

- [ ] **Step 3: Implement the server action boundary**

```ts
export async function publishEntry(db: CalendarRepository, input: PublishInput) {
  if (!input.titleEn.trim()) return { ok: false as const, field: "titleEn", message: "English title is required" };
  if (!input.titleBo.trim()) return { ok: false as const, field: "titleBo", message: "Tibetan title is required" };
  if (!input.tibetanDateText.trim()) return { ok: false as const, field: "tibetanDateText", message: "Tibetan date is required" };
  await db.transition(input.id, "published");
  return { ok: true as const };
}
```

- [ ] **Step 4: Build the bilingual form with explicit workflow actions**

```tsx
export function CalendarForm({ entry }: { entry: CalendarDraft }) {
  return <form action={saveCalendarDraft}>
    <input type="hidden" name="id" value={entry.id} />
    <label>Gregorian date<input name="gregorianDate" type="date" required /></label>
    <label>Tibetan date<input name="tibetanDateText" required lang="bo" /></label>
    <label>English title<input name="titleEn" required lang="en" /></label>
    <label>Tibetan title<input name="titleBo" required lang="bo" /></label>
    <button name="intent" value="draft">Save draft</button>
    <button name="intent" value="review">Submit for review</button>
  </form>;
}
```

- [ ] **Step 5: Run unit and browser workflow tests**

Run: `npm --workspace apps/admin test; npm --workspace apps/admin run test:e2e`

Expected: validation test passes; editor can save a draft; reviewer can publish it; editor cannot publish.

- [ ] **Step 6: Commit**

```powershell
git add apps/admin
git commit -m "feat: add bilingual calendar publishing workflow"
```

### Task 9: Connect End-to-End Sync, Status, and Recovery

**Files:**
- Create: `apps/mobile/lib/core/network/supabase_calendar_feed.dart`
- Create: `apps/mobile/lib/features/settings/presentation/sync_status_tile.dart`
- Create: `apps/mobile/integration_test/published_calendar_sync_test.dart`
- Modify: `apps/mobile/lib/app.dart`

- [ ] **Step 1: Write the failing integration test**

```dart
testWidgets('published entry syncs and remains after network failure', (tester) async {
  await seedPublishedEntry(title: 'Guru Rinpoche day');
  await app.sync();
  expect(await app.store.findTitle('Guru Rinpoche day'), isNotNull);
  app.feed.goOffline();
  await expectLater(app.sync(), throwsA(isA<NetworkException>()));
  expect(await app.store.findTitle('Guru Rinpoche day'), isNotNull);
});
```

- [ ] **Step 2: Verify it fails**

Run: `flutter test integration_test/published_calendar_sync_test.dart`

Expected: FAIL because the Supabase feed adapter is not wired.

- [ ] **Step 3: Implement the feed adapter and non-destructive failure state**

```dart
class SupabaseCalendarFeed implements CalendarFeed {
  SupabaseCalendarFeed(this.client);
  final SupabaseClient client;
  @override Future<CalendarPage> changesAfter(int version) async {
    final rows = await client.rpc('calendar_changes', params: {'after_version': version}) as List;
    return CalendarPage.fromJsonRows(rows.cast<Map<String, Object?>>());
  }
}
```

```dart
class SyncStatusTile extends StatelessWidget {
  const SyncStatusTile({super.key, required this.lastUpdated, required this.onRetry});
  final DateTime? lastUpdated; final VoidCallback onRetry;
  @override Widget build(BuildContext context) => ListTile(
    title: Text(lastUpdated == null ? 'Not updated yet' : 'Last updated: $lastUpdated'),
    trailing: TextButton(onPressed: onRetry, child: const Text('Retry')));
}
```

- [ ] **Step 4: Run the complete Phase 1 suite**

Run:

```powershell
supabase db reset
supabase test db
npm run lint:admin
npm run test:admin
flutter analyze apps/mobile
flutter test apps/mobile
```

Expected: all database, dashboard, analyzer, unit, widget, and integration checks pass.

- [ ] **Step 5: Perform device acceptance checks**

Run: `flutter run --dart-define-from-file=.env.local`

Expected: on one iOS simulator/device and one Android emulator/device, a reviewer-published bilingual entry appears after sync, remains offline, schedules an enabled reminder, supports 200% text, and never exposes a draft.

- [ ] **Step 6: Commit**

```powershell
git add apps/mobile supabase apps/admin
git commit -m "feat: complete phase one calendar publishing slice"
```

## Phase 1 Completion Gate

Before starting Phase 2, demonstrate this exact path in a staging environment: an editor creates a Tibetan/English entry, a reviewer publishes it, anonymous iOS and Android clients synchronize it, both retain it offline, enabled reminder categories schedule it, and an archived entry disappears on the next successful synchronization. Record the tested app builds, database migration version, and any defects in the release notes.

