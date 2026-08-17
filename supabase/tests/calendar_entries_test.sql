begin;

select plan(10);

create temporary table calendar_test_versions (
  name text primary key,
  id uuid not null,
  cursor_version bigint not null
);

with inserted as (
  insert into public.calendar_entries (
    gregorian_date,
    tibetan_date_text,
    title_en,
    title_bo,
    description_en,
    description_bo,
    status,
    published_at
  ) values
    (
      date '2026-08-17',
      'bo date draft',
      'Draft practice day',
      'bo draft',
      'Internal draft',
      'bo description draft',
      'draft',
      null
    ),
    (
      date '2026-08-18',
      'bo date review',
      'Review practice day',
      'bo review',
      'Internal review',
      'bo description review',
      'review',
      null
    ),
    (
      date '2026-08-19',
      'bo date scheduled',
      'Scheduled practice day',
      'bo scheduled',
      'Internal scheduled',
      'bo description scheduled',
      'scheduled',
      null
    ),
    (
      date '2026-08-20',
      'bo date published',
      'Published practice day',
      'bo published',
      'Published entry',
      'bo description published',
      'published',
      timestamptz '2026-08-20 00:00:00+00'
    ),
    (
      date '2026-08-21',
      'bo date archived private',
      'Private archived practice day',
      'bo private archived',
      'Private archived entry',
      'bo description private archived',
      'archived',
      null
    ),
    (
      date '2026-08-22',
      'bo date archived public',
      'Public archived practice day',
      'bo public archived',
      'Public archived entry',
      'bo description public archived',
      'archived',
      timestamptz '2026-08-22 00:00:00+00'
    ),
    (
      date '2026-08-23',
      'bo date update target',
      'Published update target',
      'bo update target',
      'Published update target entry',
      'bo description update target',
      'published',
      timestamptz '2026-08-23 00:00:00+00'
    ),
    (
      date '2026-08-24',
      'bo date archive target',
      'Published archive target',
      'bo archive target',
      'Published archive target entry',
      'bo description archive target',
      'published',
      timestamptz '2026-08-24 00:00:00+00'
    ),
    (
      date '2026-08-25',
      'bo date no-op target',
      'Published no-op target',
      'bo no-op target',
      'Published no-op target entry',
      'bo description no-op target',
      'published',
      timestamptz '2026-08-25 00:00:00+00'
    ),
    (
      date '2026-08-26',
      'bo date unrelated target',
      'Published unrelated target',
      'bo unrelated target',
      'Published unrelated target entry',
      'bo description unrelated target',
      'published',
      timestamptz '2026-08-26 00:00:00+00'
    )
  returning id, title_en, version
)
insert into calendar_test_versions (name, id, cursor_version)
select title_en, id, version
from inserted
where title_en in (
  'Published update target',
  'Published archive target',
  'Published no-op target',
  'Published unrelated target'
);

update public.calendar_entries
set description_en = 'Updated published target entry'
where id = (
  select id
  from calendar_test_versions
  where name = 'Published update target'
);

update public.calendar_entries
set status = 'archived'
where id = (
  select id
  from calendar_test_versions
  where name = 'Published archive target'
);

update public.calendar_entries
set title_en = title_en
where id = (
  select id
  from calendar_test_versions
  where name = 'Published no-op target'
);

update public.calendar_entries
set updated_at = updated_at + interval '1 second'
where id = (
  select id
  from calendar_test_versions
  where name = 'Published unrelated target'
);

select is(
  (
    select version
    from public.calendar_entries
    where id = (
      select id
      from calendar_test_versions
      where name = 'Published no-op target'
    )
  ),
  (
    select cursor_version
    from calendar_test_versions
    where name = 'Published no-op target'
  ),
  'no-op public field updates do not advance calendar entry version'
);

select is(
  (
    select version
    from public.calendar_entries
    where id = (
      select id
      from calendar_test_versions
      where name = 'Published unrelated target'
    )
  ),
  (
    select cursor_version
    from calendar_test_versions
    where name = 'Published unrelated target'
  ),
  'unrelated updates do not advance calendar entry version'
);

grant select on calendar_test_versions to anon;

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

select is(
  (
    select count(*)::integer
    from public.calendar_entries
    where title_en = 'Private archived practice day'
  ),
  0,
  'anonymous users cannot read archived rows that were never published'
);

select is(
  (
    select count(*)::integer
    from public.calendar_entries
    where title_en = 'Public archived practice day'
  ),
  1,
  'anonymous users can read archived tombstones that were previously public'
);

select is(
  (
    select count(*)::integer
    from public.calendar_changes(0)
    where title_en = 'Public archived practice day'
  ),
  1,
  'public feed includes previously public archived tombstones'
);

select is(
  (
    select count(*)::integer
    from public.calendar_changes(0)
    where title_en = 'Private archived practice day'
  ),
  0,
  'public feed excludes archived rows that were never published'
);

select is(
  (
    select count(*)::integer
    from public.calendar_changes(0)
    where status in ('draft','review','scheduled')
  ),
  0,
  'public feed excludes draft, review, and scheduled rows'
);

select is(
  (
    select count(*)::integer
    from public.calendar_changes(
      (
        select cursor_version
        from calendar_test_versions
        where name = 'Published update target'
      )
    )
    where id = (
      select id
      from calendar_test_versions
      where name = 'Published update target'
    )
  ),
  1,
  'updated public rows reappear in the feed after an older cursor'
);

select is(
  (
    select count(*)::integer
    from public.calendar_changes(
      (
        select cursor_version
        from calendar_test_versions
        where name = 'Published archive target'
      )
    )
    where id = (
      select id
      from calendar_test_versions
      where name = 'Published archive target'
    )
      and status = 'archived'
  ),
  1,
  'archived public rows reappear as tombstones after an older cursor'
);

reset role;

select * from finish();

rollback;
