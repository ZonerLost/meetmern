-- Add location discovery radius support to profile tables.
-- Required by app profile location settings screen.

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'profiles'
  ) then
    alter table public.profiles
      add column if not exists discovery_radius text;
  end if;

  -- Optional compatibility: some projects use user_profiles instead of profiles.
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'user_profiles'
  ) then
    alter table public.user_profiles
      add column if not exists discovery_radius text;
  end if;
end $$;
