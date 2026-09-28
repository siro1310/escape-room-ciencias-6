-- SEGURIDAD DEL ESCAPE ROOM
-- Ejecutar una vez en Supabase > SQL Editor.
-- Después de esto, el panel y sus acciones requieren una cuenta autenticada.

alter table public.sesiones enable row level security;
alter table public.sesiones replica identity full;

-- Elimina las políticas abiertas creadas en versiones anteriores.
drop policy if exists "Permitir insertar sesiones" on public.sesiones;
drop policy if exists "Permitir actualizar sesiones" on public.sesiones;
drop policy if exists "Permitir consultar sesiones" on public.sesiones;
drop policy if exists "Permitir eliminar sesiones" on public.sesiones;

-- Los estudiantes anónimos SOLO pueden consultar la fila de control
-- para saber en qué grupo está activa la actividad.
create policy "Publico puede ver solo el control"
on public.sesiones
for select
to anon
using (tipo = 'control');

-- El docente autenticado puede consultar todos los resultados.
create policy "Docente autenticado puede consultar"
on public.sesiones
for select
to authenticated
using (true);

-- Un estudiante puede registrar únicamente filas de tipo estudiante.
create policy "Estudiantes pueden registrar resultados"
on public.sesiones
for insert
to anon
with check (tipo = 'estudiante');

-- Permite actualizar resultados de estudiantes desde el juego.
-- La interfaz no expone datos de otros estudiantes; el panel está protegido
-- y las acciones administrativas requieren autenticación.
create policy "Estudiantes pueden actualizar resultados"
on public.sesiones
for update
to anon
using (tipo = 'estudiante')
with check (tipo = 'estudiante');

-- El docente autenticado puede actualizar el control y administrar sesiones.
create policy "Docente autenticado puede actualizar"
on public.sesiones
for update
to authenticated
using (true)
with check (true);

-- Solo el docente autenticado puede borrar resultados.
create policy "Docente autenticado puede eliminar"
on public.sesiones
for delete
to authenticated
using (true);

-- Asegura que exista el control inicial.
insert into public.sesiones
  (id, tipo, nombre, inicio, actividad, cerradura, aciertos, terminado, fin, nota, session_id, grupo)
values
  ('__control__', 'control', '__CONTROL__', now(), now(), 0, 0, false, null, null, 'g1-inicial', 1)
on conflict (id) do nothing;

-- Realtime ya debe incluir esta tabla; si no, la agrega.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname='supabase_realtime'
      and schemaname='public'
      and tablename='sesiones'
  ) then
    alter publication supabase_realtime add table public.sesiones;
  end if;
end $$;
