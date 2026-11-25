# Pruebas de Verificación de Calidad de Datos (EA4 — Grupo 3)

Esta carpeta reúne la suite completa de verificación de calidad de datos aplicada sobre las tres capas del proyecto (`jardineria_ea3` → `staging_jardineria_ea3` → `dm_jardineria_ea3`), siguiendo las seis dimensiones estándar de calidad (**ISO/IEC 25012** y **DAMA-DMBOK**):

1. **Completitud** (`DQ-01` a `DQ-04`): 0 valores nulos indebidos en llaves y atributos críticos.
2. **Unicidad** (`DQ-05` a `DQ-08`): 0 productos, clientes (`Lasas S.A.` unificado), líneas de venta (`ID_detalle=317` depurado) o fechas duplicadas.
3. **Integridad Referencial** (`DQ-09` a `DQ-12`): 0 llaves foráneas huérfanas en `fact_ventas` y `fact_pagos`.
4. **Exactitud y Consistencia de Negocio** (`DQ-13` a `DQ-17`): 0 ventas rechazadas, 0 descuadres aritméticos en importes/utilidades, 0 cantidades/precios negativos y 0 fechas imposibles sin controlar.
5. **Validez y Estandarización** (`DQ-18` a `DQ-20`): países homologados al español, 0 espacios laterales y 0 textos corruptos (`2 para todo...`, `1Âª`, `DECÃ`, `FraÃ§ois`).
6. **Conciliación E2E e Idempotencia** (`DQ-21` a `DQ-22`): `staging_jardineria_ea3` mantiene 816 filas exactas tras re-ejecución con `TRUNCATE`, `fact_ventas = 253` y `fact_pagos = 26`.

## Ejecución

* **Desde Python (ejecuta idempotencia + 22 aserciones + genera CSV y reporte Markdown):**
  ```bash
  python run_data_quality_tests.py
  ```
* **Directamente en MySQL Workbench / CLI:** ejecutar en orden los archivos dentro de `scripts_sql/`.
