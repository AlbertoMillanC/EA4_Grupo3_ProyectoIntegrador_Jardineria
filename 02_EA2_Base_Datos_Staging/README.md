# Evidencia de Aprendizaje 2: Base de Datos de Staging (Grupo 3)

Incluye la versión corregida atendiendo la retroalimentación docente:
- **Perfilamiento 1 a 1 (`01_Perfilamiento_1a1_Jardineria.sql`):** Revisión de las 63 columnas en las 8 tablas mediante `INFORMATION_SCHEMA.COLUMNS`, conteos de nulos, valores únicos y longitudes.
- **Staging Crudo Idempotente (`02_Staging_Jardineria_Grupo3_MySQL.sql` y `SQLServer.sql`):** Copia fiel de los 816 registros sin transformaciones prematuras, con `TRUNCATE TABLE`, `fecha_carga` y banderas de calidad (`estado_calidad`, `observacion_calidad`).
- **Respaldos (`backups_bk/`):** Backups en MySQL, SQL Server y PostgreSQL.
