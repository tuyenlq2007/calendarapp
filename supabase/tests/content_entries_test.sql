begin;

select plan(8);

create temporary table content_test_versions (
  name text primary key,
  id uuid not null,
  cursor_version bigint not null
);

with inserted as (
  insert into public.content_entries (
    slug,
    type,
    category,
    title_en,
    title_bo,
    summary_en,
    summary_bo,
    body_en,
    body_bo,
    youtube_url,
    offline_eligible,
    status,
    published_at
  ) values
    (
      'draft-teaching',
      'article',
      'Practice',
      'Draft teaching',
      'bo draft',
      'Draft summary',
      'bo summary',
      '',
      '',
      null,
      false,
      'draft',
      null
    ),
    (
      'published-article',
      'article',
      'Practice',
      'Published article',
      'bo article',
      'Published summary',
      'bo summary',
      'Published body',
      'bo body',
      null,
      true,
      'published',
      timestamptz '2026-08-21 00:00:00+00'
    ),
    (
      'published-video',
      'video',
      'Lineage',
      'Published video',
      'bo video',
      'Video summary',
      'bo summary',
      '',
      '',
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      false,
      'published',
      timestamptz '2026-08-21 00:00:00+00'
    ),
    (
      'archive-target',
      'article',
      'Practice',
      'Archive target',
      'bo archive',
      'Archive summary',
      'bo summary',
      'Archive body',
      'bo body',
      null,
      true,
      'published',
      timestamptz '2026-08-21 00:00:00+00'
    )
  returning id, title_en, version
)
insert into content_test_versions (name, id, cursor_version)
select title_en, id, version
from inserted
where title_en in ('Published article', 'Archive target');

select throws_ok(
  $$
    insert into public.content_entries (
      slug,
      type,
      category,
      title_en,
      title_bo,
      youtube_url,
      status
    ) values (
      'bad-video',
      'video',
      'Lineage',
      'Bad video',
      'bo bad video',
      'https://example.com/watch?v=bad',
      'published'
    )
  $$,
  '23514',
  null,
  'published videos require a YouTube URL'
);

select throws_ok(
  $$
    insert into public.content_entries (
      slug,
      type,
      category,
      title_en,
      title_bo,
      offline_eligible,
      status
    ) values (
      'empty-offline-article',
      'article',
      'Practice',
      'Empty offline article',
      'bo empty',
      true,
      'published'
    )
  $$,
  '23514',
  null,
  'offline eligible articles require bilingual body content'
);

update public.content_entries
set summary_en = 'Updated published summary'
where id = (
  select id
  from content_test_versions
  where name = 'Published article'
);

update public.content_entries
set status = 'archived'
where id = (
  select id
  from content_test_versions
  where name = 'Archive target'
);

grant select on content_test_versions to anon;

set local role anon;

select is(
  (
    select count(*)::integer
    from public.content_entries
    where status = 'draft'
  ),
  0,
  'anonymous users cannot read draft content'
);

select is(
  (
    select count(*)::integer
    from public.content_changes(0)
    where title_en = 'Published video'
  ),
  1,
  'public content feed includes published YouTube videos'
);

select is(
  (
    select count(*)::integer
    from public.content_changes(0)
    where title_en = 'Draft teaching'
  ),
  0,
  'public content feed excludes drafts'
);

select is(
  (
    select count(*)::integer
    from public.content_changes(
      (
        select cursor_version
        from content_test_versions
        where name = 'Published article'
      )
    )
    where id = (
      select id
      from content_test_versions
      where name = 'Published article'
    )
  ),
  1,
  'updated published articles reappear after an older cursor'
);

select is(
  (
    select count(*)::integer
    from public.content_changes(
      (
        select cursor_version
        from content_test_versions
        where name = 'Archive target'
      )
    )
    where id = (
      select id
      from content_test_versions
      where name = 'Archive target'
    )
      and status = 'archived'
  ),
  1,
  'archived public content reappears as a tombstone'
);

reset role;

select throws_ok(
  $$
    update public.content_entries
    set status = 'draft'
    where title_en = 'Published video'
  $$,
  '23514',
  null,
  'published content cannot leave the public feed without an archived tombstone'
);

select * from finish();

rollback;
