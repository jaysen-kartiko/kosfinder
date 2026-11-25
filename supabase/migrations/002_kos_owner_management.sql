drop policy if exists "kos_update_owner" on public.kos;

create policy "kos_update_owner"
on public.kos for update
to authenticated
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create or replace function public.save_kos(
  p_name text,
  p_address text,
  p_phone text,
  p_monthly_price numeric,
  p_description text,
  p_is_active boolean,
  p_facility_ids uuid[],
  p_kos_id uuid default null
)
returns uuid
language plpgsql
security invoker
set search_path = public, pg_temp
as $$
declare
  saved_kos_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  if p_kos_id is null then
    insert into public.kos (
      owner_id, name, address, phone, monthly_price, description, is_active
    )
    values (
      auth.uid(), p_name, p_address, p_phone, p_monthly_price, p_description,
      p_is_active
    )
    returning id into saved_kos_id;
  else
    update public.kos
    set name = p_name,
        address = p_address,
        phone = p_phone,
        monthly_price = p_monthly_price,
        description = p_description,
        is_active = p_is_active
    where id = p_kos_id
      and owner_id = auth.uid()
    returning id into saved_kos_id;

    if saved_kos_id is null then
      raise exception 'Kos not owned by current user' using errcode = '42501';
    end if;

    delete from public.kos_facilities
    where kos_id = saved_kos_id;
  end if;

  insert into public.kos_facilities (kos_id, facility_id)
  select saved_kos_id, facility_id
  from unnest(coalesce(p_facility_ids, '{}'::uuid[])) as selected_facilities(
    facility_id
  )
  on conflict (kos_id, facility_id) do nothing;

  return saved_kos_id;
end;
$$;

revoke all on function public.save_kos(
  text, text, text, numeric, text, boolean, uuid[], uuid
) from public, anon;
grant execute on function public.save_kos(
  text, text, text, numeric, text, boolean, uuid[], uuid
) to authenticated;

insert into public.facilities (name)
values ('WiFi'), ('AC'), ('Kamar Mandi Dalam'), ('Parkir')
on conflict (name) do nothing;
