create extension if not exists postgis with schema extensions;
create schema if not exists private;

create table public.profiles (
    user_id         uuid primary key references auth.users(id) on delete cascade,
    display_name    text not null,
    avatar_url      text
);

create table public.groups (
    group_id        uuid primary key default get_random_uuid(),
    created_by      uuid not null references public.profiles(user_id) on delete set null,
    created_at      timestamptz not null default now(),
    group_name      text not null,
    group_img_url   text
);

create table public.group_members (
    group_id        uuid references public.group(group_id) on delete cascade,
    user_id         uuid references public.profiles(user_id) on delete cascade,
    role            text not null default 'member' check (role in ('owner', 'member')),
    joined_at       timestamptz not null default now(),
    sharing_enabled boolean not null default false,
    consent_at      timestamptz,
    primary key (group_id, user_id)
);
create index on public.group_members (user_id);

create table public.trips (
    trip_id         uuid primary key default get_random_uuid(),
    group_id        uuid references public.group(group_id) on delete cascade,
    trip_name       text not null,
    start_date      date,
    end_date        date
);
create index on public.trips (group_id);

create table public.invites (
    invite_id       uuid primary key default get_random_uuid(),
    group_id        uuid not null references public.group(group_id) on delete cascade, 
    code            text not null unique,
    expires_at      timestamptz not null
);
create index on public.invites (group_id);

alter table public.profiles         enable row level security;
alter table public.groups           enable row level security;
alter table public.group_members    enable row level security;
alter table public.trips            enable row level security;
alter table public.invites          enable row level security;