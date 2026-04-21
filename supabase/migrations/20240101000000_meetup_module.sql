-- ============================================================
-- Meetup Module Migration
-- ============================================================

-- 1) meetups
create table if not exists public.meetups (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references auth.users(id) on delete cascade,
  type            text not null,
  address         text not null,
  meetup_date     text not null,
  meetup_time     text not null,
  is_repeat       boolean not null default false,
  profile_pic_url text,
  host_name       text,
  status          text not null default 'open'
                    check (status in ('open','cancelled','completed','closed')),
  created_at      timestamptz default now(),
  updated_at      timestamptz default now()
);

alter table public.meetups enable row level security;

create policy "Anyone authenticated can view meetups"
  on public.meetups for select
  using (auth.role() = 'authenticated');

create policy "Owner can insert their meetup"
  on public.meetups for insert
  with check (auth.uid() = user_id);

create policy "Owner can update their meetup"
  on public.meetups for update
  using (auth.uid() = user_id);

create policy "Owner can delete their meetup"
  on public.meetups for delete
  using (auth.uid() = user_id);

-- 2) meetup_requests
create table if not exists public.meetup_requests (
  id               uuid primary key default gen_random_uuid(),
  meetup_id        uuid not null references public.meetups(id) on delete cascade,
  meetup_owner_id  uuid not null references auth.users(id),
  requester_id     uuid not null references auth.users(id),
  chat_id          uuid,  -- back-filled after chat creation
  status           text not null default 'pending'
                     check (status in ('pending','accepted','rejected','cancelled')),
  created_at       timestamptz default now(),
  updated_at       timestamptz default now(),
  unique (meetup_id, requester_id)
);

alter table public.meetup_requests enable row level security;

create policy "Participants can view their requests"
  on public.meetup_requests for select
  using (auth.uid() = requester_id or auth.uid() = meetup_owner_id);

create policy "Requester can insert"
  on public.meetup_requests for insert
  with check (auth.uid() = requester_id and auth.uid() != meetup_owner_id);

create policy "Participants can update status"
  on public.meetup_requests for update
  using (auth.uid() = requester_id or auth.uid() = meetup_owner_id);

-- 3) chats
create table if not exists public.chats (
  id                  uuid primary key default gen_random_uuid(),
  meetup_id           uuid references public.meetups(id) on delete set null,
  meetup_request_id   uuid unique references public.meetup_requests(id) on delete set null,
  user_one            uuid not null references auth.users(id),
  user_two            uuid not null references auth.users(id),
  chat_type           text not null default 'meetup'
                        check (chat_type in ('direct','meetup')),
  status              text not null default 'pending'
                        check (status in ('pending','accepted','rejected','closed')),
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

alter table public.chats enable row level security;

create policy "Participants can view their chats"
  on public.chats for select
  using (auth.uid() = user_one or auth.uid() = user_two);

create policy "Requester can create chat"
  on public.chats for insert
  with check (auth.uid() = user_one or auth.uid() = user_two);

create policy "Participants can update chat"
  on public.chats for update
  using (auth.uid() = user_one or auth.uid() = user_two);

-- 4) messages
create table if not exists public.messages (
  id                  uuid primary key default gen_random_uuid(),
  chat_id             uuid not null references public.chats(id) on delete cascade,
  sender_id           uuid not null references auth.users(id),
  message_type        text not null default 'text'
                        check (message_type in ('text','meetup_request','system')),
  text                text,
  request_status      text check (request_status in ('pending','accepted','rejected')),
  meetup_id           uuid references public.meetups(id) on delete set null,
  meetup_request_id   uuid references public.meetup_requests(id) on delete set null,
  created_at          timestamptz default now()
);

alter table public.messages enable row level security;

create policy "Chat participants can view messages"
  on public.messages for select
  using (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (c.user_one = auth.uid() or c.user_two = auth.uid())
    )
  );

create policy "Chat participants can insert messages"
  on public.messages for insert
  with check (
    auth.uid() = sender_id and
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (c.user_one = auth.uid() or c.user_two = auth.uid())
    )
  );

create policy "Sender can update their message request_status"
  on public.messages for update
  using (
    exists (
      select 1 from public.chats c
      where c.id = messages.chat_id
        and (c.user_one = auth.uid() or c.user_two = auth.uid())
    )
  );

-- Back-fill chat_id FK on meetup_requests after chats table exists
alter table public.meetup_requests
  add constraint fk_meetup_requests_chat
  foreign key (chat_id) references public.chats(id) on delete set null
  not valid;

-- Trigger: keep meetups.updated_at fresh
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger meetups_updated_at
  before update on public.meetups
  for each row execute function public.set_updated_at();

create trigger meetup_requests_updated_at
  before update on public.meetup_requests
  for each row execute function public.set_updated_at();

create trigger chats_updated_at
  before update on public.chats
  for each row execute function public.set_updated_at();
