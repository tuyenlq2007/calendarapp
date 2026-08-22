# Barom Kagyu Calendar

Monorepo for the Barom Kagyu mobile calendar and staff administration dashboard.

## Repository layout

- `apps/mobile`: Flutter application for Android and iOS.
- `apps/admin`: Next.js App Router administration application.
- `packages/contracts`: shared TypeScript application contracts.

## Prerequisites

- Flutter stable with the Android and iOS toolchains required by your target platform.
  On this workstation the verified Flutter executable is `C:\Users\ADMIN\.puro\envs\stable\flutter\bin\flutter.bat`.
- Node.js 22 and npm.
- Supabase project URL and anon/publishable key.

Calendar content is staff-authored and verified by Barom Kagyu staff: dates, lunar days, practices, anniversaries, and translations are entered through the publishing workflow rather than calculated by the app.

Install and verify the projects from the repository root:

```sh
npm ci
npm run lint:admin
npm run test:admin
cd apps/mobile
flutter pub get
flutter analyze
flutter test
```

Build the admin dashboard with `npm --workspace apps/admin run build`.

## Supabase Cloud

Copy `.env.example` to `.env.local` and set:

```env
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY
```

Run the mobile app against Supabase Cloud:

```powershell
cd apps/mobile
flutter run --dart-define-from-file=../../.env.local
```

Copy `apps/admin/.env.example` to `apps/admin/.env.local` and set:

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY
```

Run the admin dashboard:

```powershell
npm --workspace apps/admin run dev
```
