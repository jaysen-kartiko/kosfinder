grant usage on schema public to authenticated;

grant select, insert on table public.profiles to authenticated;
grant select, insert, update on table public.kos to authenticated;
grant select on table public.facilities to authenticated;
grant select, insert, update, delete on table public.kos_facilities to authenticated;
grant select, insert, update, delete on table public.room_types to authenticated;
