do $$
begin
  if not exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'community_entry_type'
  ) then
    create type public.community_entry_type as enum (
      'news',
      'event',
      'monastery',
      'contact'
    );
  end if;
end
$$;

create table if not exists public.community_entries (
  id uuid primary key default gen_random_uuid(),
  type public.community_entry_type not null,
  title text not null default '',
  summary text not null default '',
  detail text not null default '',
  starts_at timestamptz,
  location text,
  contact text,
  display_order integer not null default 0,
  published boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint community_entries_published_requires_content check (
    not published
    or (
      btrim(title) <> ''
      and btrim(summary) <> ''
    )
  )
);

alter table public.community_entries enable row level security;

grant usage on type public.community_entry_type to anon;
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
