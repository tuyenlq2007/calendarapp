alter table public.calendar_entries
  add column if not exists element_tibetan_line text not null default '';

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
    new.element_tibetan_line,
    new.status,
    new.published_at
  ) is distinct from row(
    old.gregorian_date,
    old.tibetan_date_text,
    old.title_en,
    old.title_bo,
    old.description_en,
    old.description_bo,
    old.element_tibetan_line,
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
