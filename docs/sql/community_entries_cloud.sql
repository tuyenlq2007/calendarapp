create table if not exists public.community_entries (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  title text not null default '',
  summary text not null default '',
  detail text not null default '',
  starts_at timestamptz,
  location text,
  contact text,
  display_order integer not null default 0,
  published boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint community_entries_type_check check (
    type in ('news', 'event', 'monastery', 'contact')
  ),
  constraint community_entries_published_requires_content check (
    not published
    or (
      btrim(title) <> ''
      and btrim(summary) <> ''
    )
  )
);

alter table public.community_entries enable row level security;

grant select on table public.community_entries to anon;

drop policy if exists "Anonymous users can read published community entries"
  on public.community_entries;

create policy "Anonymous users can read published community entries"
  on public.community_entries
  for select
  to anon
  using (published = true);

drop index if exists public.community_entries_published_order_idx;

create index community_entries_published_order_idx
  on public.community_entries (display_order, starts_at)
  where published = true;

insert into public.community_entries (
  id,
  type,
  title,
  summary,
  detail,
  starts_at,
  location,
  contact,
  display_order,
  published
) values
  (
    '30000000-0000-4000-8000-000000000001',
    'news',
    'Losar community gathering',
    'New year prayers, offerings, and shared dedication.',
    'Everyone is welcome to join the community practice.',
    null,
    null,
    null,
    1,
    true
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    'event',
    'Weekly meditation practice',
    'Sundays at 9:00 AM with prayers and quiet sitting.',
    '',
    timestamptz '2026-09-06 09:00:00+00',
    'Main shrine room',
    null,
    2,
    true
  ),
  (
    '30000000-0000-4000-8000-000000000003',
    'monastery',
    'Barom Kagyu monastery',
    'Lineage practice center for teachings, prayers, and retreats.',
    '',
    null,
    'Barom Kagyu Dharma Center',
    null,
    3,
    true
  ),
  (
    '30000000-0000-4000-8000-000000000004',
    'contact',
    'Contact',
    'contact@baromkagyu.org',
    '',
    null,
    null,
    'contact@baromkagyu.org',
    4,
    true
  )
on conflict (id) do update set
  type = excluded.type,
  title = excluded.title,
  summary = excluded.summary,
  detail = excluded.detail,
  starts_at = excluded.starts_at,
  location = excluded.location,
  contact = excluded.contact,
  display_order = excluded.display_order,
  published = excluded.published,
  updated_at = now();
