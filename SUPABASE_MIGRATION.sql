-- Ejecutar UNA VEZ en Supabase > SQL Editor.
-- Actualiza la tabla sesiones creada anteriormente para que el Escape Room
-- pueda separar Grupo 1, Grupo 2, Grupo 3... y sincronizar el grupo activo.

alter table public.sesiones
  add column if not exists session_id text,
  add column if not exists tipo text not null default 'estudiante';

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


-- La eliminación de resultados queda reservada al docente autenticado.
-- El botón "Limpiar trabajo" pide doble confirmación antes de borrar.
drop policy if exists "Permitir eliminar sesiones" on public.sesiones;
create policy "Permitir eliminar sesiones"
on public.sesiones
for delete
to authenticated
using (true);
