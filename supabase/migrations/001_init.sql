create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'member',
  created_at timestamptz not null default now()
);

create table if not exists public.kos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete restrict,
  name text not null,
  address text not null check (char_length(address) <= 256),
  phone text not null check (phone ~ '^08[0-9]{6,10}$'),
  monthly_price numeric(12, 2) not null check (monthly_price >= 0),
  description text not null check (char_length(description) <= 1024),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.facilities (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

create table if not exists public.kos_facilities (
  kos_id uuid not null references public.kos(id) on delete cascade,
  facility_id uuid not null references public.facilities(id) on delete restrict,
  primary key (kos_id, facility_id)
);

create table if not exists public.room_types (
  id uuid primary key default gen_random_uuid(),
  kos_id uuid not null references public.kos(id) on delete cascade,
  name text not null,
  monthly_price numeric(12, 2) not null check (monthly_price >= 0),
  status text not null check (status in ('available', 'full')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace trigger kos_set_updated_at
before update on public.kos
for each row execute function public.set_updated_at();

create or replace trigger room_types_set_updated_at
before update on public.room_types
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.kos enable row level security;
alter table public.facilities enable row level security;
alter table public.kos_facilities enable row level security;
alter table public.room_types enable row level security;

create policy "profiles_select_own"
on public.profiles for select
to authenticated
using (id = auth.uid());

create policy "profiles_insert_own"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

create policy "kos_select_authenticated"
on public.kos for select
to authenticated
using (is_active = true or owner_id = auth.uid());

create policy "kos_insert_owner"
on public.kos for insert
to authenticated
with check (owner_id = auth.uid());

create policy "kos_update_owner"
on public.kos for update
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "facilities_select_authenticated"
on public.facilities for select
to authenticated
using (true);

create policy "kos_facilities_select_authenticated"
on public.kos_facilities for select
to authenticated
using (
  exists (
    select 1
    from public.kos
    where kos.id = kos_facilities.kos_id
      and (kos.is_active = true or kos.owner_id = auth.uid())
  )
);

create policy "kos_facilities_insert_owner"
on public.kos_facilities for insert
to authenticated
with check (
  exists (
    select 1
    from public.kos
    where kos.id = kos_facilities.kos_id
      and kos.owner_id = auth.uid()
  )
);

create policy "kos_facilities_update_owner"
on public.kos_facilities for update
to authenticated
using (
  exists (
    select 1
    from public.kos
    where kos.id = kos_facilities.kos_id
      and kos.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.kos
    where kos.id = kos_facilities.kos_id
      and kos.owner_id = auth.uid()
  )
);

create policy "kos_facilities_delete_owner"
on public.kos_facilities for delete
to authenticated
using (
  exists (
    select 1
    from public.kos
    where kos.id = kos_facilities.kos_id
      and kos.owner_id = auth.uid()
  )
);

create policy "room_types_select_authenticated"
on public.room_types for select
to authenticated
using (
  exists (
    select 1
    from public.kos
    where kos.id = room_types.kos_id
      and (kos.is_active = true or kos.owner_id = auth.uid())
  )
);

create policy "room_types_insert_owner"
on public.room_types for insert
to authenticated
with check (
  exists (
    select 1
    from public.kos
    where kos.id = room_types.kos_id
      and kos.owner_id = auth.uid()
  )
);

create policy "room_types_update_owner"
on public.room_types for update
to authenticated
using (
  exists (
    select 1
    from public.kos
    where kos.id = room_types.kos_id
      and kos.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.kos
    where kos.id = room_types.kos_id
      and kos.owner_id = auth.uid()
  )
);

create policy "room_types_delete_owner"
on public.room_types for delete
to authenticated
using (
  exists (
    select 1
    from public.kos
    where kos.id = room_types.kos_id
      and kos.owner_id = auth.uid()
  )
);
