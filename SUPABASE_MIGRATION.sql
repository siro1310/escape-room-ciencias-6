-- Ejecutar UNA VEZ en Supabase > SQL Editor.
-- Actualiza la tabla sesiones creada anteriormente para que el Escape Room
-- pueda separar Grupo 1, Grupo 2, Grupo 3... y sincronizar el grupo activo.

alter table public.sesiones
  add column if not exists session_id text,
  add column if not exists tipo text not null default 'estudiante',
  add column if not exists grado text;

create index if not exists sesiones_session_id_idx
  on public.sesiones(session_id);

create index if not exists sesiones_tipo_idx
  on public.sesiones(tipo);

-- El tiempo real ya se habilitó en el SQL anterior. Esta línea es segura
-- aunque la tabla ya esté publicada.
alter table public.sesiones replica identity full;

-- Crea la sesión inicial si todavía no existe.
insert into public.sesiones
  (id, tipo, nombre, inicio, actividad, cerradura, aciertos, terminado, fin, nota, session_id, grupo)
values
  ('__control__', 'control', '__CONTROL__', now(), now(), 0, 0, false, null, null, 'g1-inicial', 1)
on conflict (id) do nothing;


-- Permite al panel docente borrar los registros de prueba al usar
-- "Limpiar trabajo". El botón pide doble confirmación antes de hacerlo.
drop policy if exists "Permitir eliminar sesiones" on public.sesiones;

create policy "Permitir eliminar sesiones"
on public.sesiones
for delete
to anon, authenticated
using (tipo = 'estudiante');
