# Evidencia de Aprendizaje 3: Proceso ETL y Carga en el Data Mart Final (Grupo 3)

Implementación completa del flujo en 3 capas sobre MySQL 8.4 a partir de `CreacionJardineria.sql`:
1. **Origen OLTP (`jardineria_ea3`):** 8 tablas, 816 filas.
2. **Staging (`staging_jardineria_ea3`):** Extracción cruda idempotente con `TRUNCATE TABLE`, `fecha_carga` y marcas de anomalías.
3. **Data Mart Estrella (`dm_jardineria_ea3`):** 4 dimensiones conformadas sin copo de nieve (`dim_tiempo`, `dim_producto`, `dim_cliente` deduplicado, `dim_empleado` con oficina integrada) y 2 tablas de hechos (`fact_ventas` con 253 ventas efectivas y `fact_pagos` con 26 recaudos).
4. **Analítica de negocio (`04_Consultas_Analiticas_Negocio_EA3.sql`):** Producto más vendido en unidades (`AR-009` Thymus Vulgaris, 961 uds) y en ingresos (`OR-247` Trachycarpus Fortunei, $72,408.00).
