# Escape Room — versión Supabase + Excel

Incluye conexión a Supabase, panel en vivo, sesiones por grupo y descarga de resultados en Excel (.xlsx).

La hoja **Resumen** ahora incluye también el detalle de todos los estudiantes y sus resultados. La hoja **Resultados** conserva el listado completo.


## Cambio solicitado: grado del estudiante
La actividad solicita el grado (6A, 6B o 6C) y lo guarda en la tabla `sesiones`. Ejecuta nuevamente `SUPABASE_MIGRATION.sql` en Supabase para crear la columna `grado`. El panel docente muestra estudiante, grado y nota final.
