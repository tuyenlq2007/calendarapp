alter table public.online_teachings
  add column if not exists image_url text not null default '';

update public.online_teachings
set image_url = 'https://azfsdtbmxzqomwsepjfx.supabase.co/storage/v1/object/public/images/Tara.JPG',
    updated_at = now()
where title = 'Green Tara Practice';
