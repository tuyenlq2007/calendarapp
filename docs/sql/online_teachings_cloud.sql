create table if not exists public.online_teachings (
  id uuid primary key default gen_random_uuid(),
  title text not null default '',
  practice text not null default '',
  start_date date not null,
  end_date date not null,
  status text not null default 'upcoming',
  join_url text not null default '',
  display_order integer not null default 0,
  published boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint online_teachings_status_check check (
    status in ('upcoming', 'ongoing', 'finished')
  ),
  constraint online_teachings_valid_date_range check (end_date >= start_date),
  constraint online_teachings_published_requires_content check (
    not published
    or (
      btrim(title) <> ''
      and btrim(practice) <> ''
      and btrim(join_url) <> ''
    )
  )
);

alter table public.online_teachings enable row level security;

grant select on table public.online_teachings to anon;

drop policy if exists "Anonymous users can read published online teachings"
  on public.online_teachings;

create policy "Anonymous users can read published online teachings"
  on public.online_teachings
  for select
  to anon
  using (published = true);

create index if not exists online_teachings_published_order_idx
  on public.online_teachings (display_order, start_date)
  where published = true;

insert into public.online_teachings (
  id,
  title,
  practice,
  start_date,
  end_date,
  status,
  join_url,
  display_order,
  published
) values
  (
    '20000000-0000-4000-8000-000000000001',
    'Prayer for the Long Life of His Holiness',
    'Recite the Sutra of Boundless Life and Wisdom',
    date '2026-07-06',
    date '2026-12-31',
    'ongoing',
    'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
    1,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    'Medicine Buddha Practice',
    'Daily Medicine Buddha mantra recitation and dedication',
    date '2026-09-01',
    date '2026-09-30',
    'upcoming',
    'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
    2,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    'Guru Rinpoche Tsok Practice',
    'Monthly Guru Rinpoche prayers, tsok, and aspiration practice',
    date '2026-06-10',
    date '2026-08-10',
    'finished',
    'https://us02web.zoom.us/j/9461447283?pwd=ck01U3B1ZERFd1R1d0FNOERGNzJoQT09',
    3,
    true
  )
on conflict (id) do update set
  title = excluded.title,
  practice = excluded.practice,
  start_date = excluded.start_date,
  end_date = excluded.end_date,
  status = excluded.status,
  join_url = excluded.join_url,
  display_order = excluded.display_order,
  published = excluded.published,
  updated_at = now();
