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

create or replace function public.bump_calendar_entry_version()
returns trigger
language plpgsql
as $$
begin
  if row(
    new.gregorian_date,
    new.tibetan_date_text,
    new.title_en,
    new.title_bo,
    new.description_en,
    new.description_bo,
    new.status,
    new.published_at
  ) is distinct from row(
    old.gregorian_date,
    old.tibetan_date_text,
    old.title_en,
    old.title_bo,
    old.description_en,
    old.description_bo,
    old.status,
    old.published_at
  ) then
    new.version = nextval(pg_get_serial_sequence('public.calendar_entries', 'version')::regclass);
    new.updated_at = now();
  end if;

  return new;
end;
$$;

create trigger calendar_entries_bump_version
  before update on public.calendar_entries
  for each row
  execute function public.bump_calendar_entry_version();

alter table public.calendar_entries enable row level security;

grant select on table public.calendar_entries to anon;

create policy "Anonymous users can read published calendar entries"
  on public.calendar_entries
  for select
  to anon
  using (
    status = 'published'
    or (status = 'archived' and published_at is not null)
  );
