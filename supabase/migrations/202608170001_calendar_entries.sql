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

create or replace function public.prepare_calendar_entry_change()
returns trigger
language plpgsql
as $$
declare
  old_is_public boolean := false;
  new_is_public boolean := false;
  public_fields_changed boolean := false;
begin
  if new.status = 'published' and new.published_at is null then
    new.published_at = now();
  end if;

  new_is_public := new.status = 'published'
    or (new.status = 'archived' and new.published_at is not null);

  if tg_op = 'INSERT' then
    if new_is_public then
      -- Serialize public feed versions so cursor order follows commit order.
      perform pg_advisory_xact_lock(20260817, 1);
      new.version = nextval(pg_get_serial_sequence('public.calendar_entries', 'version')::regclass);
    end if;

    return new;
  end if;

  old_is_public := old.status = 'published'
    or (old.status = 'archived' and old.published_at is not null);

  if old_is_public and not new_is_public then
    raise exception 'published calendar entries must be archived before leaving the public feed'
      using errcode = '23514';
  end if;

  public_fields_changed := row(
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
  );

  if public_fields_changed and (old_is_public or new_is_public) then
    -- Serialize public feed versions so cursor order follows commit order.
    perform pg_advisory_xact_lock(20260817, 1);
    new.version = nextval(pg_get_serial_sequence('public.calendar_entries', 'version')::regclass);
    new.updated_at = now();
  end if;

  return new;
end;
$$;

create trigger calendar_entries_prepare_insert
  before insert on public.calendar_entries
  for each row
  execute function public.prepare_calendar_entry_change();

create trigger calendar_entries_prepare_update
  before update on public.calendar_entries
  for each row
  execute function public.prepare_calendar_entry_change();

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
