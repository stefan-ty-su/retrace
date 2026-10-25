create table public.routes (
    route_id        uuid primary key default get_random_uuid(),
    user_id         uuid not null references public.profiles(user_id) on delete cascade,
    trip_id         uuid not null references public.trips(trip_id) on delete cascade,
    started_at      timestamptz not null,
    ended_at        timestamptz,
    path            extensions.geometry(LineString, 4326)
);
create index on public.routes (user_id);
create index on public.routes (group_id);
create index on public.routes (trip_id);

create table public.location_points (
    loc_id          uuid primary key, -- phone generated for idempotency
    route_id        uuid not null references public.routes(route_id) on delete cascade,
    recorded_at     timestamptz not null,
    received_at     timestamptz not null default now(),
    geom            extensions.geometry(Point, 4326) not null,
    accuracy_m      real,
    speed           real,
    heading         real
);
create index on public.location_points (route_id);

create index location_points_route_time_idx on public.location_points (route_id, recorded_at);
create index location_points_geom_idx on public.location_points using gist (geom);

alter table public.routes           enable row level security;
alter table public.location_points  enable row level security;