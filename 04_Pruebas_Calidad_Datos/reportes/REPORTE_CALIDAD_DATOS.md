# Reporte Oficial de Pruebas de Verificación de Calidad de Datos (EA4 — Grupo 3)

- **Fecha de ejecución:** 2026-11-25 00:09:13
- **Motor verificado:** MySQL 8.4 (`jardineria_ea3` → `staging_jardineria_ea3` → `dm_jardineria_ea3`)
- **Resultado global:** **22/22 pruebas aprobadas (100 % PASS, 0 FAIL)**

## 1. Anomalías Detectadas en el Origen (`jardineria_ea3`)

| Anomalía detectada en el origen | Cantidad encontrada | Tratamiento aplicado en Staging + ETL |
| :--- | ---: | :--- |
| Clientes duplicados exactos (Lasas S.A.) | 1 | Marcado en `stg_cliente` (`OBSERVADO_DUPLICADO`) y unificado vía `map_cliente_dedup` (36 → 35). |
| Lineas detalle_pedido duplicadas exactas (ID_detalle=317) | 1 | Marcado en `stg_detalle_pedido` y excluido al cargar `fact_ventas`. |
| Cabeceras de pedido repetidas (cliente+fechas+estado) | 19 | Marcadas en `stg_pedido` (`OBSERVADO_DUPLICADO`) conservando trazabilidad por `ID_pedido`. |
| Pedidos con fechas imposibles (esperada/entrega < pedido) | 4 | Marcados en `stg_pedido` (`OBSERVADO_FECHAS`) y remitidos a fecha centinela `19000101`. |
| Pedidos con estado contradictorio frente a fecha_entrega | 19 | Marcados en `stg_pedido` (`OBSERVADO_ESTADO`) e identificados en `entrega_a_tiempo`. |
| Pedidos en estado Rechazado | 24 | Aislados del cómputo de ventas efectivas en `fact_ventas`. |
| Lineas detalle pertenecientes a pedidos Rechazados | 64 | Marcadas `EXCLUIR_VENTA_RECHAZADO` en Staging y excluidas (318 − 64 − 1 = 253). |
| Lineas con precio historico distinto al catalogo actual | 41 | Preservado `precio_unidad` histórico en `fact_ventas.precio_unitario_historico`. |
| Categorias sin productos asociados (Herbaceas) | 1 | Marcada `OBSERVADO_SIN_PRODUCTOS` en `stg_categoria_producto`. |
| Paises en oficinas/clientes sin homologar al espanol | 37 | Homologados al español (`España`, `Estados Unidos`, `Francia`, `Reino Unido`) en `dim_cliente` y `dim_empleado`. |
| Textos corruptos o residual UTF-8 (2 para todo / 1Aa / DECA / Francois) | 4 | Restaurados en `dim_producto` y `dim_cliente` durante la transformación. |

## 2. Resultados de la Suite de 22 Pruebas Automatizadas (`dm_jardineria_ea3` + `staging_jardineria_ea3`)

| ID | Dimensión ISO/IEC 25012 | Prueba de Verificación | Fallos | Estado |
| :--- | :--- | :--- | ---: | :---: |
| DQ-01 | Completitud | dim_producto sin nulos en llaves/nombre/categoria/precio | 0 | **PASS** |
| DQ-02 | Completitud | dim_cliente sin nulos en nombre/ciudad/pais/telefono | 0 | **PASS** |
| DQ-03 | Completitud | dim_empleado sin nulos en nombre/email/oficina | 0 | **PASS** |
| DQ-04 | Completitud | fact_ventas sin nulos en llaves subrogadas ni metricas | 0 | **PASS** |
| DQ-05 | Unicidad | 0 codigos de producto duplicados en dim_producto | 0 | **PASS** |
| DQ-06 | Unicidad | 0 clientes duplicados por (nombre, telefono, ciudad) en dim_cliente (Lasas S.A. unificado) | 0 | **PASS** |
| DQ-07 | Unicidad | 0 lineas duplicadas por (id_pedido_dd, sk_producto) en fact_ventas (ID 317 depurado) | 0 | **PASS** |
| DQ-08 | Unicidad | 0 fechas duplicadas en dim_tiempo | 0 | **PASS** |
| DQ-09 | Integridad Referencial | 0 sk_producto o sk_cliente huerfanos en fact_ventas | 0 | **PASS** |
| DQ-10 | Integridad Referencial | 0 sk_empleado huerfanos en fact_ventas | 0 | **PASS** |
| DQ-11 | Integridad Referencial | 0 llaves de tiempo huerfanas en fact_ventas (pedido/esperada/entrega) | 0 | **PASS** |
| DQ-12 | Integridad Referencial | 0 llaves huerfanas en fact_pagos (cliente, empleado, tiempo) | 0 | **PASS** |
| DQ-13 | Exactitud y Consistencia | 0 ventas en estado Rechazado dentro de fact_ventas | 0 | **PASS** |
| DQ-14 | Exactitud y Consistencia | 0 descuadres entre importe_venta_linea y cantidad * precio_unitario_historico | 0 | **PASS** |
| DQ-15 | Exactitud y Consistencia | 0 descuadres en utilidad_bruta_linea = importe_venta_linea - costo_estimado_linea | 0 | **PASS** |
| DQ-16 | Exactitud y Consistencia | 0 cantidades o precios unitarios historicos <= 0 en fact_ventas | 0 | **PASS** |
| DQ-17 | Exactitud y Consistencia | 0 fechas de entrega efectivas anteriores a fecha_pedido (excluyendo centinela 19000101) | 0 | **PASS** |
| DQ-18 | Validez y Estandarizacion | 0 paises sin homologar al espanol en dim_cliente y dim_empleado | 0 | **PASS** |
| DQ-19 | Validez y Estandarizacion | 0 espacios laterales sin limpiar en nombre_producto y nombre_cliente | 0 | **PASS** |
| DQ-20 | Validez y Estandarizacion | 0 textos corruptos o mojibake UTF-8 residual en dimensiones | 0 | **PASS** |
| DQ-21 | Conciliacion e Idempotencia | staging_jardineria_ea3 mantiene exactamente 816 filas totales tras recarga TRUNCATE | 0 | **PASS** |
| DQ-22 | Conciliacion e Idempotencia | Conciliacion exacta fact_ventas = 253 (318 - 64 rechazadas - 1 duplicada) y fact_pagos = 26 | 0 | **PASS** |
