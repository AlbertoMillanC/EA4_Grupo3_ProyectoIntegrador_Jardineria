-- ============================================================================
-- PRUEBAS DE CALIDAD DE DATOS 03: SUITE DE 22 ASERCIONES SOBRE EL DATA MART
-- Base de datos evaluada: dm_jardineria_ea3 (Modelo Estrella)
-- Estandar de referencia: ISO/IEC 25012 & DAMA-DMBOK (6 dimensiones)
-- Regla de evaluacion: cada prueba retorna 'PASS' o 'FAIL' (0 errores esperados)
-- ============================================================================

USE dm_jardineria_ea3;

-- DIMENSION 1: COMPLETITUD (4 pruebas)
SELECT 'DQ-01' AS id_prueba, 'Completitud' AS dimension, 'dim_producto sin nulos en llaves/nombre/categoria/precio' AS descripcion,
       COUNT(*) AS fallos, IF(COUNT(*) = 0, 'PASS', 'FAIL') AS resultado
FROM dim_producto
WHERE id_producto_nk IS NULL OR codigo_producto IS NULL OR nombre_producto IS NULL OR nombre_categoria IS NULL OR precio_venta_catalogo IS NULL
UNION ALL
SELECT 'DQ-02', 'Completitud', 'dim_cliente sin nulos en nombre/ciudad/pais/telefono',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM dim_cliente
WHERE id_cliente_nk IS NULL OR nombre_cliente IS NULL OR ciudad IS NULL OR pais IS NULL OR telefono IS NULL
UNION ALL
SELECT 'DQ-03', 'Completitud', 'dim_empleado sin nulos en nombre/email/oficina',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM dim_empleado
WHERE id_empleado_nk IS NULL OR nombre_completo IS NULL OR email IS NULL OR ciudad_oficina IS NULL OR pais_oficina IS NULL
UNION ALL
SELECT 'DQ-04', 'Completitud', 'fact_ventas sin nulos en llaves subrogadas ni metricas',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas
WHERE sk_producto IS NULL OR sk_cliente IS NULL OR sk_empleado IS NULL OR sk_tiempo_pedido IS NULL
   OR cantidad IS NULL OR precio_unitario_historico IS NULL OR importe_venta_linea IS NULL

-- DIMENSION 2: UNICIDAD (4 pruebas)
UNION ALL
SELECT 'DQ-05', 'Unicidad', '0 codigos de producto duplicados en dim_producto',
       (SELECT COUNT(*) FROM (SELECT codigo_producto FROM dim_producto GROUP BY codigo_producto HAVING COUNT(*) > 1) t),
       IF((SELECT COUNT(*) FROM (SELECT codigo_producto FROM dim_producto GROUP BY codigo_producto HAVING COUNT(*) > 1) t) = 0, 'PASS', 'FAIL')
UNION ALL
SELECT 'DQ-06', 'Unicidad', '0 clientes duplicados por (nombre, telefono, ciudad) en dim_cliente (Lasas S.A. unificado)',
       (SELECT COUNT(*) FROM (SELECT nombre_cliente, telefono, ciudad FROM dim_cliente GROUP BY nombre_cliente, telefono, ciudad HAVING COUNT(*) > 1) t),
       IF((SELECT COUNT(*) FROM (SELECT nombre_cliente, telefono, ciudad FROM dim_cliente GROUP BY nombre_cliente, telefono, ciudad HAVING COUNT(*) > 1) t) = 0, 'PASS', 'FAIL')
UNION ALL
SELECT 'DQ-07', 'Unicidad', '0 lineas duplicadas por (id_pedido_dd, sk_producto) en fact_ventas (ID 317 depurado)',
       (SELECT COUNT(*) FROM (SELECT id_pedido_dd, sk_producto FROM fact_ventas GROUP BY id_pedido_dd, sk_producto HAVING COUNT(*) > 1) t),
       IF((SELECT COUNT(*) FROM (SELECT id_pedido_dd, sk_producto FROM fact_ventas GROUP BY id_pedido_dd, sk_producto HAVING COUNT(*) > 1) t) = 0, 'PASS', 'FAIL')
UNION ALL
SELECT 'DQ-08', 'Unicidad', '0 fechas duplicadas en dim_tiempo',
       (SELECT COUNT(*) FROM (SELECT fecha FROM dim_tiempo GROUP BY fecha HAVING COUNT(*) > 1) t),
       IF((SELECT COUNT(*) FROM (SELECT fecha FROM dim_tiempo GROUP BY fecha HAVING COUNT(*) > 1) t) = 0, 'PASS', 'FAIL')

-- DIMENSION 3: INTEGRIDAD REFERENCIAL (4 pruebas)
UNION ALL
SELECT 'DQ-09', 'Integridad Referencial', '0 sk_producto o sk_cliente huerfanos en fact_ventas',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas fv
LEFT JOIN dim_producto dp ON fv.sk_producto = dp.sk_producto
LEFT JOIN dim_cliente dc ON fv.sk_cliente = dc.sk_cliente
WHERE dp.sk_producto IS NULL OR dc.sk_cliente IS NULL
UNION ALL
SELECT 'DQ-10', 'Integridad Referencial', '0 sk_empleado huerfanos en fact_ventas',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas fv
LEFT JOIN dim_empleado de ON fv.sk_empleado = de.sk_empleado
WHERE de.sk_empleado IS NULL
UNION ALL
SELECT 'DQ-11', 'Integridad Referencial', '0 llaves de tiempo huerfanas en fact_ventas (pedido/esperada/entrega)',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas fv
LEFT JOIN dim_tiempo t1 ON fv.sk_tiempo_pedido = t1.sk_tiempo
LEFT JOIN dim_tiempo t2 ON fv.sk_tiempo_esperada = t2.sk_tiempo
LEFT JOIN dim_tiempo t3 ON fv.sk_tiempo_entrega = t3.sk_tiempo
WHERE t1.sk_tiempo IS NULL OR t2.sk_tiempo IS NULL OR t3.sk_tiempo IS NULL
UNION ALL
SELECT 'DQ-12', 'Integridad Referencial', '0 llaves huerfanas en fact_pagos (cliente, empleado, tiempo)',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_pagos fp
LEFT JOIN dim_cliente dc ON fp.sk_cliente = dc.sk_cliente
LEFT JOIN dim_empleado de ON fp.sk_empleado = de.sk_empleado
LEFT JOIN dim_tiempo dt ON fp.sk_tiempo_pago = dt.sk_tiempo
WHERE dc.sk_cliente IS NULL OR de.sk_empleado IS NULL OR dt.sk_tiempo IS NULL

-- DIMENSION 4: EXACTITUD Y CONSISTENCIA DE NEGOCIO (5 pruebas)
UNION ALL
SELECT 'DQ-13', 'Exactitud y Consistencia', '0 ventas en estado Rechazado dentro de fact_ventas',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas WHERE estado_pedido = 'Rechazado'
UNION ALL
SELECT 'DQ-14', 'Exactitud y Consistencia', '0 descuadres entre importe_venta_linea y cantidad * precio_unitario_historico',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas WHERE ABS(importe_venta_linea - ROUND(cantidad * precio_unitario_historico, 2)) > 0.01
UNION ALL
SELECT 'DQ-15', 'Exactitud y Consistencia', '0 descuadres en utilidad_bruta_linea = importe_venta_linea - costo_estimado_linea',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas WHERE ABS(utilidad_bruta_linea - (importe_venta_linea - costo_estimado_linea)) > 0.01
UNION ALL
SELECT 'DQ-16', 'Exactitud y Consistencia', '0 cantidades o precios unitarios historicos <= 0 en fact_ventas',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas WHERE cantidad <= 0 OR precio_unitario_historico <= 0
UNION ALL
SELECT 'DQ-17', 'Exactitud y Consistencia', '0 fechas de entrega efectivas anteriores a fecha_pedido (excluyendo centinela 19000101)',
       COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM fact_ventas WHERE sk_tiempo_entrega <> 19000101 AND sk_tiempo_entrega < sk_tiempo_pedido

-- DIMENSION 5: VALIDEZ Y ESTANDARIZACION (3 pruebas)
UNION ALL
SELECT 'DQ-18', 'Validez y Estandarizacion', '0 paises sin homologar al espanol en dim_cliente y dim_empleado',
       (SELECT COUNT(*) FROM dim_cliente WHERE pais IN ('USA','EEUU','Spain','France','United Kingdom','Inglaterra'))
       + (SELECT COUNT(*) FROM dim_empleado WHERE pais_oficina IN ('USA','EEUU','Spain','France','United Kingdom','Inglaterra')),
       IF(((SELECT COUNT(*) FROM dim_cliente WHERE pais IN ('USA','EEUU','Spain','France','United Kingdom','Inglaterra'))
         + (SELECT COUNT(*) FROM dim_empleado WHERE pais_oficina IN ('USA','EEUU','Spain','France','United Kingdom','Inglaterra'))) = 0, 'PASS', 'FAIL')
UNION ALL
SELECT 'DQ-19', 'Validez y Estandarizacion', '0 espacios laterales sin limpiar en nombre_producto y nombre_cliente',
       (SELECT COUNT(*) FROM dim_producto WHERE nombre_producto <> TRIM(nombre_producto))
       + (SELECT COUNT(*) FROM dim_cliente WHERE nombre_cliente <> TRIM(nombre_cliente)),
       IF(((SELECT COUNT(*) FROM dim_producto WHERE nombre_producto <> TRIM(nombre_producto))
         + (SELECT COUNT(*) FROM dim_cliente WHERE nombre_cliente <> TRIM(nombre_cliente))) = 0, 'PASS', 'FAIL')
UNION ALL
SELECT 'DQ-20', 'Validez y Estandarizacion', '0 textos corruptos o mojibake UTF-8 residual en dimensiones',
       (SELECT COUNT(*) FROM dim_producto WHERE descripcion_categoria LIKE '2 para todo%' OR nombre_producto LIKE '%1Âª%' OR nombre_producto LIKE '%DECÃ%')
       + (SELECT COUNT(*) FROM dim_cliente WHERE contacto_completo LIKE '%FraÃ§ois%'),
       IF(((SELECT COUNT(*) FROM dim_producto WHERE descripcion_categoria LIKE '2 para todo%' OR nombre_producto LIKE '%1Âª%' OR nombre_producto LIKE '%DECÃ%')
         + (SELECT COUNT(*) FROM dim_cliente WHERE contacto_completo LIKE '%FraÃ§ois%')) = 0, 'PASS', 'FAIL')

-- DIMENSION 6: CONCILIACION E2E E IDEMPOTENCIA (2 pruebas)
UNION ALL
SELECT 'DQ-21', 'Conciliacion e Idempotencia', 'staging_jardineria_ea3 mantiene exactamente 816 filas totales tras recarga TRUNCATE',
       ABS(816 - (
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_oficina) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_empleado) +
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_categoria_producto) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_cliente) +
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_pedido) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_producto) +
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_detalle_pedido) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_pago)
       )),
       IF((
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_oficina) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_empleado) +
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_categoria_producto) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_cliente) +
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_pedido) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_producto) +
           (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_detalle_pedido) + (SELECT COUNT(*) FROM staging_jardineria_ea3.stg_pago)
       ) = 816, 'PASS', 'FAIL')
UNION ALL
SELECT 'DQ-22', 'Conciliacion e Idempotencia', 'Conciliacion exacta fact_ventas = 253 (318 - 64 rechazadas - 1 duplicada) y fact_pagos = 26',
       ABS(253 - (SELECT COUNT(*) FROM fact_ventas)) + ABS(26 - (SELECT COUNT(*) FROM fact_pagos)),
       IF((SELECT COUNT(*) FROM fact_ventas) = 253 AND (SELECT COUNT(*) FROM fact_pagos) = 26, 'PASS', 'FAIL');
