begin;

select plan(1);

insert into public.calendar_entries (
  gregorian_date,
  tibetan_date_text,
  title_en,
  title_bo,
  description_en,
  description_bo,
  status
) values
  (
    date '2026-08-17',
    'བོད་ཟླ་༧ ཚེས་༥',
    'Draft practice day',
    'སྒྲུབ་པའི་ཉིན།',
    'Internal draft',
    'ནང་ཁུལ་ཟིན་བྲིས།',
    'draft'
  ),
  (
    date '2026-08-18',
    'བོད་ཟླ་༧ ཚེས་༦',
    'Published practice day',
    'སྒྲུབ་པའི་ཉིན་སྤེལ་ཟིན།',
    'Published entry',
    'སྤེལ་ཟིན་པ།',
    'published'
  );

set local role anon;

select is(
  (
    select count(*)::integer
    from public.calendar_entries
    where status <> 'published'
  ),
  0,
  'anonymous users cannot read non-published calendar entries'
);

reset role;

select * from finish();

rollback;
