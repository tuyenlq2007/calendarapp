begin;

select plan(4);

set local role authenticated;

select throws_ok(
  $$
    insert into public.calendar_entries (gregorian_date, title_en)
    values (date '2026-08-17', 'Draft')
  $$,
  '42501',
  null,
  'unassigned staff cannot create drafts'
);

reset role;

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000001',
  'authenticated',
  'authenticated',
  'editor@example.test',
  '',
  now(),
  '{}'::jsonb,
  '{}'::jsonb,
  now(),
  now()
);

insert into public.staff_profiles (user_id, role)
values ('00000000-0000-0000-0000-000000000001', 'editor');

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-0000-0000-000000000001',
  true
);

select ok(public.has_staff_role('editor'), 'editor role is recognized');
select ok(not public.has_staff_role('reviewer'), 'editor role does not imply reviewer');

set local role authenticated;

select lives_ok(
  $$
    insert into public.calendar_entries (gregorian_date, title_en, status)
    values (date '2026-08-18', 'Editor draft', 'draft')
  $$,
  'editors can create draft entries'
);

reset role;

select * from finish();

rollback;
