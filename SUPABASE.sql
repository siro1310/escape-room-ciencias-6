-- Supabase: estructura y permisos para Escape Room Ciencias 6
create table if not exists public.sesiones (
  id text primary key,
  nombre text not null,
  grado text check (grado in ('6A','6B','6C')),
  inicio timestamptz,
  actividad timestamptz,
  cerradura integer,
  aciertos integer,
  terminado boolean default false,
  fin timestamptz,
  nota numeric(2,1)
);

alter table public.sesiones enable row level security;

-- Permitir que la actividad pública registre/actualice su propio registro por id.
drop policy if exists "sesiones_public_insert" on public.sesiones;
create policy "sesiones_public_insert"
on public.sesiones for insert to anon
with check (grado in ('6A','6B','6C'));

drop policy if exists "sesiones_public_update" on public.sesiones;
create policy "sesiones_public_update"
on public.sesiones for update to anon
using (true)
with check (grado in ('6A','6B','6C'));

-- El panel docente de esta versión es un panel de consulta pública.
-- Si después quieres protegerlo con login, se puede añadir sin cambiar la actividad.
drop policy if exists "sesiones_public_select" on public.sesiones;
create policy "sesiones_public_select"
on public.sesiones for select to anon
using (true);

grant usage on schema public to anon;
grant select, insert, update on public.sesiones to anon;
