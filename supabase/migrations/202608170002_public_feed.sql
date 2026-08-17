create index calendar_entries_public_feed_version_idx
  on public.calendar_entries (version)
  where status = 'published'
    or (status = 'archived' and published_at is not null);

create or replace function public.calendar_changes(after_version bigint)
returns setof public.calendar_entries
language sql stable security invoker
as $$
  select * from public.calendar_entries
  where version > after_version
    and (
      status = 'published'
      or (status = 'archived' and published_at is not null)
    )
  order by version asc limit 500;
$$;

grant execute on function public.calendar_changes(bigint) to anon;
