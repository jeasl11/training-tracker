-- Run this once in Supabase -> SQL Editor (New query -> paste -> Run).
-- Creates a per-user JSON store for the tracker, locked down with RLS so each
-- account can only read/write its own row.

create table if not exists public.tracker_state (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.tracker_state enable row level security;

drop policy if exists "tracker_state own select" on public.tracker_state;
drop policy if exists "tracker_state own insert" on public.tracker_state;
drop policy if exists "tracker_state own update" on public.tracker_state;

create policy "tracker_state own select" on public.tracker_state
  for select using (auth.uid() = user_id);

create policy "tracker_state own insert" on public.tracker_state
  for insert with check (auth.uid() = user_id);

create policy "tracker_state own update" on public.tracker_state
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
