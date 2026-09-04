alter table public.calendar_entries
  add column if not exists day_number_text text not null default '',
  add column if not exists day_element_animal_en text not null default '';

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
    new.element_pair_en,
    new.element_combination_title_en,
    new.element_description_en,
    new.day_number_text,
    new.day_element_animal_en,
    new.month_number_text,
    new.month_element_animal_en,
    new.year_number_text,
    new.year_element_animal_en,
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
    old.element_pair_en,
    old.element_combination_title_en,
    old.element_description_en,
    old.day_number_text,
    old.day_element_animal_en,
    old.month_number_text,
    old.month_element_animal_en,
    old.year_number_text,
    old.year_element_animal_en,
    old.status,
    old.published_at
  );

  if public_fields_changed and (old_is_public or new_is_public) then
    perform pg_advisory_xact_lock(20260817, 1);
    new.version = nextval(pg_get_serial_sequence('public.calendar_entries', 'version')::regclass);
    new.updated_at = now();
  end if;

  return new;
end;
$$;
