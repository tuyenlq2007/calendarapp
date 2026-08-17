begin;

select plan(3);

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
    'bo date draft',
    'Draft practice day',
    'bo draft',
    'Internal draft',
    'bo description draft',
    'draft'
  ),
  (
    date '2026-08-18',
    'bo date review',
    'Review practice day',
    'bo review',
    'Internal review',
    'bo description review',
    'review'
  ),
  (
    date '2026-08-19',
    'bo date scheduled',
    'Scheduled practice day',
    'bo scheduled',
    'Internal scheduled',
    'bo description scheduled',
    'scheduled'
  ),
  (
    date '2026-08-20',
    'bo date published',
    'Published practice day',
    'bo published',
    'Published entry',
    'bo description published',
    'published'
  ),
  (
    date '2026-08-21',
    'bo date archived',
    'Archived practice day',
    'bo archived',
    'Archived entry',
    'bo description archived',
    'archived'
  );

set local role anon;

select is(
  (
    select count(*)::integer
    from public.calendar_entries
    where status in ('draft','review','scheduled')
  ),
  0,
  'anonymous users cannot read draft, review, or scheduled calendar entries'
);

select isnt(
  (
    select count(*)::integer
    from public.calendar_changes(0)
    where status = 'archived'
  ),
  0,
  'anonymous users can read archived tombstones from the public feed'
);

select is(
  (
    select count(*)::integer
    from public.calendar_changes(0)
    where status in ('draft','review','scheduled')
  ),
  0,
  'anonymous users cannot read draft, review, or scheduled rows from the public feed'
);

reset role;

select * from finish();

rollback;
