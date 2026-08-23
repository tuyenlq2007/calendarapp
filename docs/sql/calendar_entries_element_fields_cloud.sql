alter table public.calendar_entries
  add column if not exists element_pair_en text not null default '',
  add column if not exists element_combination_title_en text not null default '',
  add column if not exists element_description_en text not null default '';

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

insert into public.calendar_entries (
  id,
  gregorian_date,
  tibetan_date_text,
  title_en,
  title_bo,
  description_en,
  description_bo,
  element_tibetan_line,
  element_pair_en,
  element_combination_title_en,
  element_description_en,
  status
) values (
  '10000000-0000-4000-8000-000000000725',
  date '2026-07-25',
  'Tibetan dummy month 7 day 15',
  'July Full Moon Offering',
  'July Tibetan title',
  'Dummy published offering entry for July.',
  '',
  'ས་ཆུ་འཕྲད་པ་བདེ་སྐྱིད། ས་ཆུ་སྦྱོར་བས་དགེ་བ་འཕེལ།',
  'Water - Water',
  'Auspicious Element Combination',
  'This elemental combination has the refined energy to strengthen and extend one''s life',
  'published'
)
on conflict (id) do update set
  gregorian_date = excluded.gregorian_date,
  tibetan_date_text = excluded.tibetan_date_text,
  title_en = excluded.title_en,
  title_bo = excluded.title_bo,
  description_en = excluded.description_en,
  description_bo = excluded.description_bo,
  element_tibetan_line = excluded.element_tibetan_line,
  element_pair_en = excluded.element_pair_en,
  element_combination_title_en = excluded.element_combination_title_en,
  element_description_en = excluded.element_description_en,
  status = excluded.status,
  updated_at = now()
returning
  id,
  version,
  gregorian_date,
  title_en,
  element_tibetan_line,
  element_pair_en,
  element_combination_title_en,
  element_description_en,
  status;
