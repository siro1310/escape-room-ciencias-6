# Escape Room Ciencias 6 — versión original + grado

Esta versión conserva la aplicación original y agrega únicamente el campo **Grado** para estudiantes: 6A, 6B y 6C.

## Supabase
Ejecuta una vez `SUPABASE_MIGRATION.sql` en Supabase > SQL Editor.

La sentencia correcta para la nueva columna es:

```sql
alter table public.sesiones add column if not exists grado text;
```

No reemplaza ni requiere modificar `docente.html`.
