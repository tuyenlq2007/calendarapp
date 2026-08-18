begin;

select plan(10);

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
),
(
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000002',
  'authenticated',
  'authenticated',
  'reviewer@example.test',
  '',
  now(),
  '{}'::jsonb,
  '{}'::jsonb,
  now(),
  now()
),
(
  '00000000-0000-0000-0000-000000000000',
  '00000000-0000-0000-0000-000000000003',
  'authenticated',
  'authenticated',
  'administrator@example.test',
  '',
  now(),
  '{}'::jsonb,
  '{}'::jsonb,
  now(),
  now()
);

insert into public.staff_profiles (user_id, role)
values
  ('00000000-0000-0000-0000-000000000001', 'editor'),
  ('00000000-0000-0000-0000-000000000002', 'reviewer'),
  ('00000000-0000-0000-0000-000000000003', 'administrator');

insert into public.calendar_entries (
  gregorian_date,
  tibetan_date_text,
  title_en,
  title_bo,
  status
) values (
  date '2026-08-19',
  'bo date reviewed',
  'Reviewed entry',
  'bo reviewed',
  'review'
);

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-0000-0000-000000000001',
  true
);

select ok(public.has_staff_role('editor'), 'editor role is recognized');
select ok(not public.has_staff_role('reviewer'), 'editor role does not imply reviewer');

set local role authenticated;

select is(
  (
    select count(*)::integer
    from public.calendar_entries
    where title_en = 'Reviewed entry'
  ),
  1,
  'assigned staff can read protected calendar entries'
);

select lives_ok(
  $$
    insert into public.calendar_entries (gregorian_date, title_en, status)
    values (date '2026-08-18', 'Editor draft', 'draft')
  $$,
  'editors can create draft entries'
);

select lives_ok(
  $$
    update public.calendar_entries
    set status = 'published'
    where title_en = 'Reviewed entry'
  $$,
  'editor publish attempt is policy-filtered without crashing'
);

reset role;

select is(
  (
    select status::text
    from public.calendar_entries
    where title_en = 'Reviewed entry'
  ),
  'review',
  'editors cannot publish reviewed entries'
);

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-0000-0000-000000000002',
  true
);

set local role authenticated;

select lives_ok(
  $$
    update public.calendar_entries
    set status = 'published',
      description_en = 'Reviewer approved',
      description_bo = 'bo reviewer approved'
    where title_en = 'Reviewed entry'
  $$,
  'reviewers can publish reviewed entries'
);

reset role;

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-0000-0000-000000000003',
  true
);

set local role authenticated;

select lives_ok(
  $$
    update public.calendar_entries
    set status = 'archived'
    where title_en = 'Reviewed entry'
  $$,
  'administrators can manage published entries'
);

reset role;

select set_config(
  'request.jwt.claim.sub',
  '00000000-0000-0000-0000-000000000099',
  true
);

set local role authenticated;

select is(
  (
    select count(*)::integer
    from public.calendar_entries
    where title_en = 'Reviewed entry'
  ),
  0,
  'unassigned authenticated users cannot read protected calendar entries'
);

reset role;

select * from finish();

rollback;
