alter table public.community_entries
  add column if not exists website_url text,
  add column if not exists address text,
  add column if not exists phone text,
  add column if not exists email text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'community_entries_website_url_http_check'
      and conrelid = 'public.community_entries'::regclass
  ) then
    alter table public.community_entries
      add constraint community_entries_website_url_http_check
      check (
        website_url is null
        or btrim(website_url) = ''
        or website_url ~ '^https?://'
      );
  end if;

  if not exists (
    select 1
    from pg_constraint
    where conname = 'community_entries_email_basic_check'
      and conrelid = 'public.community_entries'::regclass
  ) then
    alter table public.community_entries
      add constraint community_entries_email_basic_check
      check (
        email is null
        or btrim(email) = ''
        or email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'
      );
  end if;
end
$$;
