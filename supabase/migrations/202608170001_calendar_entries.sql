do $$
begin
  if not exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'publication_status'
  ) then
    create type public.publication_status as enum (
      'draft',
      'review',
      'scheduled',
      'published',
      'archived'
    );
  end if;
end
$$;

create table public.calendar_entries (
  id uuid primary key default gen_random_uuid(),
  gregorian_date date not null,
  tibetan_date_text text not null default '',
  title_en text not null default '',
  title_bo text not null default '',
  description_en text not null default '',
  description_bo text not null default '',
  status public.publication_status not null default 'draft',
  version bigint generated always as identity,
  published_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint calendar_entries_published_requires_tibetan_content check (
    status <> 'published'
    or (
      btrim(tibetan_date_text) <> ''
      and btrim(title_en) <> ''
      and btrim(title_bo) <> ''
    )
  )
);

alter table public.calendar_entries enable row level security;

grant select on table public.calendar_entries to anon;

create policy "Anonymous users can read published calendar entries"
  on public.calendar_entries
  for select
  to anon
  using (status = 'published');
