create or replace function public.calendar_changes(after_version bigint)
returns setof public.calendar_entries
language sql stable security invoker
as $$
  select * from public.calendar_entries
  where version > after_version and status in ('published','archived')
  order by version asc limit 500;
$$;

grant execute on function public.calendar_changes(bigint) to anon;
