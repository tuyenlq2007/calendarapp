do $$
begin
  if not exists (
    select 1
    from pg_type
    where typnamespace = 'public'::regnamespace
      and typname = 'staff_role'
  ) then
    create type public.staff_role as enum (
      'editor',
      'reviewer',
      'administrator'
    );
  end if;
end
$$;

create table public.staff_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role public.staff_role not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.staff_profiles enable row level security;

create or replace function public.has_staff_role(required_role public.staff_role)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.staff_profiles
    where user_id = auth.uid()
      and (
        role = required_role
        or role = 'administrator'
      )
  );
$$;

grant usage on type public.staff_role to authenticated;
grant select on table public.staff_profiles to authenticated;
grant execute on function public.has_staff_role(public.staff_role) to authenticated;
grant insert, update on table public.calendar_entries to authenticated;

create policy "Staff can read staff profiles"
  on public.staff_profiles
  for select
  to authenticated
  using (user_id = auth.uid() or public.has_staff_role('administrator'));

create policy "Staff can read calendar entries"
  on public.calendar_entries
  for select
  to authenticated
  using (
    public.has_staff_role('editor')
    or public.has_staff_role('reviewer')
    or public.has_staff_role('administrator')
  );

create policy "Editors can create draft calendar entries"
  on public.calendar_entries
  for insert
  to authenticated
  with check (
    public.has_staff_role('editor')
    and status = 'draft'
  );

create policy "Editors can update draft calendar entries"
  on public.calendar_entries
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
