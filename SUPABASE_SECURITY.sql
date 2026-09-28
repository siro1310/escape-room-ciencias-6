-- SEGURIDAD Y REGISTRO DEL ESCAPE ROOM
-- Ejecutar una vez en Supabase > SQL Editor.

alter table public.sesiones enable row level security;
alter table public.sesiones replica identity full;

drop policy if exists "Permitir insertar sesiones" on public.sesiones;
drop policy if exists "Permitir actualizar sesiones" on public.sesiones;
drop policy if exists "Permitir consultar sesiones" on public.sesiones;
drop policy if exists "Permitir eliminar sesiones" on public.sesiones;
drop policy if exists "Publico puede ver solo el control" on public.sesiones;
drop policy if exists "Docente autenticado puede consultar" on public.sesiones;
drop policy if exists "Estudiantes pueden registrar resultados" on public.sesiones;
drop policy if exists "Estudiantes pueden actualizar resultados" on public.sesiones;
drop policy if exists "Docente autenticado puede actualizar" on public.sesiones;
drop policy if exists "Docente autenticado puede eliminar" on public.sesiones;

create policy "Publico puede ver solo el control"
on public.sesiones for select to anon using (tipo='control');

create policy "Docente autenticado puede consultar"
on public.sesiones for select to authenticated using (true);

create policy "Docente autenticado puede actualizar"
on public.sesiones for update to authenticated using (true) with check (true);

create policy "Docente autenticado puede eliminar"
on public.sesiones for delete to authenticated using (true);

-- Registro de estudiantes mediante función SECURITY DEFINER.
-- El navegador ya no depende de INSERT/UPDATE anónimos directos.
create or replace function public.registrar_estudiante(
  p_id text,
  p_nombre text,
  p_inicio timestamptz,
  p_actividad timestamptz,
  p_cerradura integer,
  p_aciertos integer,
  p_terminado boolean,
  p_fin timestamptz,
  p_nota numeric,
  p_session_id text,
  p_grupo integer
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if coalesce(trim(p_nombre),'')='' then
    raise exception 'El nombre es obligatorio';
  end if;
  if coalesce(trim(p_session_id),'')='' then
    raise exception 'La sesión es obligatoria';
  end if;

  insert into public.sesiones
    (id,nombre,inicio,actividad,cerradura,aciertos,terminado,fin,nota,session_id,grupo,tipo)
  values
    (p_id,trim(p_nombre),p_inicio,p_actividad,p_cerradura,p_aciertos,p_terminado,p_fin,p_nota,p_session_id,p_grupo,'estudiante')
  on conflict (id) do update set
    nombre=excluded.nombre,
    inicio=excluded.inicio,
    actividad=excluded.actividad,
    cerradura=excluded.cerradura,
    aciertos=excluded.aciertos,
    terminado=excluded.terminado,
    fin=excluded.fin,
    nota=excluded.nota,
    session_id=excluded.session_id,
    grupo=excluded.grupo,
    tipo='estudiante';
end;
$$;

revoke all on function public.registrar_estudiante(text,text,timestamptz,timestamptz,integer,integer,boolean,timestamptz,numeric,text,integer) from public;
grant execute on function public.registrar_estudiante(text,text,timestamptz,timestamptz,integer,integer,boolean,timestamptz,numeric,text,integer) to anon, authenticated;

insert into public.sesiones
  (id,tipo,nombre,inicio,actividad,cerradura,aciertos,terminado,fin,nota,session_id,grupo)
values
  ('__control__','control','__CONTROL__',now(),now(),0,0,false,null,null,'g1-inicial',1)
on conflict (id) do nothing;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname='supabase_realtime' and schemaname='public' and tablename='sesiones'
  ) then
    alter publication supabase_realtime add table public.sesiones;
  end if;
end $$;
