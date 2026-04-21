-- Make meetup owner names resolvable via meetups.user_id -> profiles.id
-- 1) Ensure authenticated users can SELECT profiles rows.
-- 2) Backfill missing profile rows for meetup owners.

alter table if exists public.profiles enable row level security;

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'profiles'
  ) then
    if not exists (
      select 1
      from pg_policies
      where schemaname = 'public'
        and tablename = 'profiles'
        and policyname = 'Authenticated can read profiles'
    ) then
      create policy "Authenticated can read profiles"
        on public.profiles
        for select
        to authenticated
        using (true);
    end if;
  end if;
end $$;

insert into public.profiles (id, name, photo_url)
select distinct
  m.user_id,
  coalesce(
    nullif(u.raw_user_meta_data ->> 'name', ''),
    nullif(split_part(coalesce(u.email, ''), '@', 1), ''),
    'User'
  ) as name,
  nullif(m.profile_pic_url, '') as photo_url
from public.meetups m
left join public.profiles p
  on p.id = m.user_id
left join auth.users u
  on u.id = m.user_id
where p.id is null
on conflict (id) do nothing;
