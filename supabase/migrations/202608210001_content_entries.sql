do $$
begin
  if not exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'content_type'
  ) then
    create type public.content_type as enum ('article', 'video');
  end if;
end
$$;

create table public.content_entries (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  type public.content_type not null,
  category text not null default '',
  title_en text not null default '',
  title_bo text not null default '',
  summary_en text not null default '',
  summary_bo text not null default '',
  body_en text not null default '',
  body_bo text not null default '',
  youtube_url text,
  image_url text,
  offline_eligible boolean not null default false,
  status public.publication_status not null default 'draft',
  version bigint generated always as identity,
  published_at timestamptz,
  updated_at timestamptz not null default now(),
  constraint content_entries_published_requires_bilingual_titles check (
    status <> 'published'
    or (
      btrim(slug) <> ''
      and btrim(category) <> ''
      and btrim(title_en) <> ''
      and btrim(title_bo) <> ''
    )
  ),
  constraint content_entries_videos_require_youtube_url check (
    status <> 'published'
    or type <> 'video'
    or youtube_url ~ '^https://(www\.)?(youtube\.com|youtu\.be)/'
  ),
  constraint content_entries_offline_articles_require_body check (
    status <> 'published'
    or type <> 'article'
    or not offline_eligible
    or (
      btrim(body_en) <> ''
      and btrim(body_bo) <> ''
    )
  )
);

create or replace function public.prepare_content_entry_change()
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
      perform pg_advisory_xact_lock(20260821, 1);
      new.version = nextval(pg_get_serial_sequence('public.content_entries', 'version')::regclass);
    end if;

    return new;
  end if;

  old_is_public := old.status = 'published'
    or (old.status = 'archived' and old.published_at is not null);

  if old_is_public and not new_is_public then
    raise exception 'published content entries must be archived before leaving the public feed'
      using errcode = '23514';
  end if;

  public_fields_changed := row(
    new.slug,
    new.type,
    new.category,
    new.title_en,
    new.title_bo,
    new.summary_en,
    new.summary_bo,
    new.body_en,
    new.body_bo,
    new.youtube_url,
    new.image_url,
    new.offline_eligible,
    new.status,
    new.published_at
  ) is distinct from row(
    old.slug,
    old.type,
    old.category,
    old.title_en,
    old.title_bo,
    old.summary_en,
    old.summary_bo,
    old.body_en,
    old.body_bo,
    old.youtube_url,
    old.image_url,
    old.offline_eligible,
    old.status,
    old.published_at
  );

  if public_fields_changed and (old_is_public or new_is_public) then
    perform pg_advisory_xact_lock(20260821, 1);
    new.version = nextval(pg_get_serial_sequence('public.content_entries', 'version')::regclass);
    new.updated_at = now();
  end if;

  return new;
end;
$$;

create trigger content_entries_prepare_insert
  before insert on public.content_entries
  for each row
  execute function public.prepare_content_entry_change();

create trigger content_entries_prepare_update
  before update on public.content_entries
  for each row
  execute function public.prepare_content_entry_change();

alter table public.content_entries enable row level security;

grant usage on type public.content_type to authenticated;
grant select on table public.content_entries to anon;
grant select, insert, update on table public.content_entries to authenticated;

create policy "Anonymous users can read published content entries"
  on public.content_entries
  for select
  to anon
  using (
    status = 'published'
    or (status = 'archived' and published_at is not null)
  );

create policy "Staff can read content entries"
  on public.content_entries
  for select
  to authenticated
  using (
    public.has_staff_role('editor')
    or public.has_staff_role('reviewer')
    or public.has_staff_role('administrator')
  );

create policy "Editors can create draft content entries"
  on public.content_entries
  for insert
  to authenticated
  with check (
    public.has_staff_role('editor')
    and status = 'draft'
  );

create policy "Editors can update draft content entries"
  on public.content_entries
  for update
  to authenticated
  using (
    public.has_staff_role('editor')
    and status = 'draft'
  )
  with check (
    public.has_staff_role('editor')
    and status in ('draft', 'review')
  );

create policy "Reviewers can publish reviewed content entries"
  on public.content_entries
  for update
  to authenticated
  using (
    public.has_staff_role('reviewer')
    and status in ('review', 'scheduled')
  )
  with check (
    public.has_staff_role('reviewer')
    and status in ('review', 'scheduled', 'published')
  );

create policy "Administrators can manage content entries"
  on public.content_entries
  for update
  to authenticated
  using (public.has_staff_role('administrator'))
  with check (public.has_staff_role('administrator'));

create index content_entries_public_feed_version_idx
  on public.content_entries (version)
  where status = 'published'
    or (status = 'archived' and published_at is not null);

create or replace function public.content_changes(after_version bigint)
returns setof public.content_entries
language sql stable security invoker
as $$
  select * from public.content_entries
  where version > after_version
    and (
      status = 'published'
      or (status = 'archived' and published_at is not null)
    )
  order by version asc limit 500;
$$;

grant execute on function public.content_changes(bigint) to anon;
