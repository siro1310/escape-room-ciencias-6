# Escape Room Ciencias 6 — versión original + grado + Supabase

Esta versión parte del archivo HTML original entregado y añade únicamente:
- selector de grado 6A / 6B / 6C;
- almacenamiento del grado;
- almacenamiento de los resultados en Supabase;
- panel docente que lee los registros de Supabase.

## Vercel
Sube estos archivos al mismo repositorio:
- index.html
- docente.html
- SUPABASE.sql

## Supabase
1. Abre SQL Editor.
2. Ejecuta TODO el contenido de `SUPABASE.sql`.
3. Comprueba que exista `public.sesiones`.

## URLs
- Estudiantes: `/`
- Panel: `/docente.html`

El panel se actualiza cada 3 segundos para evitar depender de librerías externas de realtime.
