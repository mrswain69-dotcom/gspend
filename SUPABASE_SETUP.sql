-- Holiday Split backend setup for Supabase
-- 1) In Supabase: Authentication > Providers > Anonymous Sign-Ins = ON
-- 2) Open SQL Editor, paste this whole file, and Run.
-- 3) In Project Settings > API copy Project URL and anon/public key into the app.

create extension if not exists pgcrypto;

create table if not exists public.holidays (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  join_code text not null unique,
  created_by uuid not null references auth.users(id) on delete cascade,
  state jsonb not null default '{"currency":"£","groups":[],"people":[],"expenses":[]}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.holiday_members (
  holiday_id uuid not null references public.holidays(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  role text not null default 'member' check (role in ('owner','member')),
  joined_at timestamptz not null default now(),
  primary key (holiday_id,user_id)
);

alter table public.holidays enable row level security;
alter table public.holiday_members enable row level security;

-- SECURITY DEFINER helper avoids recursive RLS checks while still testing the current auth user.
create or replace function public.is_holiday_member(p_holiday_id uuid)
returns boolean
language sql
stable
security definer
set search_path=public
as $$
  select exists (
    select 1 from public.holiday_members m
    where m.holiday_id=p_holiday_id and m.user_id=auth.uid()
  );
$$;

revoke all on function public.is_holiday_member(uuid) from public;
grant execute on function public.is_holiday_member(uuid) to authenticated;

drop policy if exists "members can view holidays" on public.holidays;
create policy "members can view holidays" on public.holidays
for select to authenticated
using (public.is_holiday_member(id));

drop policy if exists "members can update holidays" on public.holidays;
create policy "members can update holidays" on public.holidays
for update to authenticated
using (public.is_holiday_member(id))
with check (public.is_holiday_member(id));

drop policy if exists "members can see own membership" on public.holiday_members;
create policy "members can see own membership" on public.holiday_members
for select to authenticated
using (user_id=auth.uid());

create or replace function public.create_holiday(p_name text, p_display_name text)
returns table(holiday_id uuid, holiday_name text, join_code text)
language plpgsql
security definer
set search_path=public
as $$
declare
  v_uid uuid := auth.uid();
  v_id uuid;
  v_code text;
begin
  if v_uid is null then raise exception 'You must be signed in'; end if;
  if nullif(trim(p_name),'') is null then raise exception 'Holiday name required'; end if;
  if nullif(trim(p_display_name),'') is null then raise exception 'Display name required'; end if;
  loop
    v_code := upper(substr(encode(gen_random_bytes(6),'hex'),1,8));
    exit when not exists(select 1 from public.holidays h where h.join_code=v_code);
  end loop;
  insert into public.holidays(name,join_code,created_by) values(trim(p_name),v_code,v_uid) returning id into v_id;
  insert into public.holiday_members(holiday_id,user_id,display_name,role) values(v_id,v_uid,trim(p_display_name),'owner');
  return query select v_id,trim(p_name),v_code;
end $$;

create or replace function public.join_holiday(p_code text, p_display_name text)
returns table(holiday_id uuid, holiday_name text, join_code text)
language plpgsql
security definer
set search_path=public
as $$
declare
  v_uid uuid := auth.uid();
  v_h public.holidays%rowtype;
begin
  if v_uid is null then raise exception 'You must be signed in'; end if;
  if nullif(trim(p_display_name),'') is null then raise exception 'Display name required'; end if;
  select * into v_h from public.holidays h where h.join_code=upper(trim(p_code));
  if not found then raise exception 'Holiday code not found'; end if;
  insert into public.holiday_members(holiday_id,user_id,display_name,role)
  values(v_h.id,v_uid,trim(p_display_name),'member')
  on conflict(holiday_id,user_id) do update set display_name=excluded.display_name;
  return query select v_h.id,v_h.name,v_h.join_code;
end $$;

revoke all on function public.create_holiday(text,text) from public;
revoke all on function public.join_holiday(text,text) from public;
grant execute on function public.create_holiday(text,text) to authenticated;
grant execute on function public.join_holiday(text,text) to authenticated;

grant select,update on public.holidays to authenticated;
grant select on public.holiday_members to authenticated;
