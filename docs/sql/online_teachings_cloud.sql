create table if not exists public.online_teachings (
  id uuid primary key default gen_random_uuid(),
  title text not null default '',
  practice text not null default '',
  start_datetime timestamptz not null,
  end_datetime timestamptz not null,
  join_url text not null default '',
  display_order integer not null default 0,
  published boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint online_teachings_valid_datetime_range check (
    end_datetime >= start_datetime
  ),
  constraint online_teachings_published_requires_content check (
    not published
    or (
      btrim(title) <> ''
      and btrim(practice) <> ''
      and btrim(join_url) <> ''
    )
  )
);

alter table public.online_teachings
  add column if not exists start_datetime timestamptz;

alter table public.online_teachings
  add column if not exists end_datetime timestamptz;

do $$
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'online_teachings'
      and column_name = 'start_date'
  ) then
    execute $migration$
      update public.online_teachings
      set start_datetime = start_date::timestamptz
      where start_datetime is null
    $migration$;
  end if;

  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'online_teachings'
      and column_name = 'end_date'
  ) then
    execute $migration$
      update public.online_teachings
      set end_datetime = end_date::timestamptz + interval '1 day' - interval '1 millisecond'
      where end_datetime is null
    $migration$;
  end if;
end $$;

alter table public.online_teachings
  alter column start_datetime set not null;

alter table public.online_teachings
  alter column end_datetime set not null;

alter table public.online_teachings
  drop constraint if exists online_teachings_status_check,
  drop constraint if exists online_teachings_valid_date_range,
  drop constraint if exists online_teachings_valid_datetime_range,
  add constraint online_teachings_valid_datetime_range check (
    end_datetime >= start_datetime
  );

alter table public.online_teachings
  drop column if exists status,
  drop column if exists start_date,
  drop column if exists end_date;

alter table public.online_teachings enable row level security;

grant select on table public.online_teachings to anon;

drop policy if exists "Anonymous users can read published online teachings"
  on public.online_teachings;

create policy "Anonymous users can read published online teachings"
  on public.online_teachings
  for select
  to anon
  using (published = true);

drop index if exists public.online_teachings_published_order_idx;

create index online_teachings_published_order_idx
  on public.online_teachings (display_order, start_datetime)
  where published = true;

insert into public.online_teachings (
  id,
  title,
  practice,
  start_datetime,
  end_datetime,
  join_url,
  display_order,
  published
) values
  (
    '20000000-0000-4000-8000-000000000001',
    'Prayer for the Long Life of His Holiness',
    'Recite the Sutra of Boundless Life and Wisdom',
    timestamptz '2026-07-06 00:00:00+00',
    timestamptz '2026-12-31 23:59:59+00',
    'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
    1,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    'Medicine Buddha Practice',
    'Daily Medicine Buddha mantra recitation and dedication',
    timestamptz '2026-09-01 00:00:00+00',
    timestamptz '2026-09-30 23:59:59+00',
    'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
    2,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    'Guru Rinpoche Tsok Practice',
    'Monthly Guru Rinpoche prayers, tsok, and aspiration practice',
    timestamptz '2026-06-10 00:00:00+00',
    timestamptz '2026-08-10 23:59:59+00',
    'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
    3,
    true
  )
on conflict (id) do update set
  title = excluded.title,
  practice = excluded.practice,
  start_datetime = excluded.start_datetime,
  end_datetime = excluded.end_datetime,
  join_url = excluded.join_url,
  display_order = excluded.display_order,
  published = excluded.published,
  updated_at = now();
