-- Ejecutar una sola vez en el proyecto Supabase existente.
alter table public.sesiones add column if not exists grado text;
alter table public.sesiones add column if not exists tipo text;
create index if not exists sesiones_tipo_idx on public.sesiones(tipo);
create index if not exists sesiones_inicio_idx on public.sesiones(inicio);
alter table public.sesiones enable row level security;
drop policy if exists "sesiones_estudiante_select" on public.sesiones;
drop policy if exists "sesiones_estudiante_insert" on public.sesiones;
drop policy if exists "sesiones_estudiante_update" on public.sesiones;
create policy "sesiones_estudiante_select" on public.sesiones for select to anon, authenticated using (tipo='estudiante');
create policy "sesiones_estudiante_insert" on public.sesiones for insert to anon, authenticated with check (tipo='estudiante');
create policy "sesiones_estudiante_update" on public.sesiones for update to anon, authenticated using (tipo='estudiante') with check (tipo='estudiante');
