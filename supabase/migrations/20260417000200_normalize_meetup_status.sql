-- Normalize meetup status values and enforce allowed statuses:
-- open, closed, cancelled, completed

do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'public'
      and table_name = 'meetups'
  ) then
    -- Normalize existing data so the check can be applied safely.
    update public.meetups
    set status = case lower(coalesce(status, ''))
      when 'active' then 'open'
      when 'open' then 'open'
      when 'closed' then 'closed'
      when 'cancelled' then 'cancelled'
      when 'completed' then 'completed'
      else 'open'
    end;

    -- Ensure future inserts default to open.
    alter table public.meetups
      alter column status set default 'open';

    -- Recreate status constraint with the allowed values only.
    alter table public.meetups
      drop constraint if exists meetups_status_check;

    alter table public.meetups
      add constraint meetups_status_check
      check (status in ('open', 'closed', 'cancelled', 'completed'));
  end if;
end $$;
