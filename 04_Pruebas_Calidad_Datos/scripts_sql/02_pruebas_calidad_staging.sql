-- ============================================================================
-- PRUEBAS DE CALIDAD DE DATOS 02: VERIFICACION EN CAPA DE STAGING
-- Base de datos evaluada: staging_jardineria_ea3
-- Objetivo: Confirmar 0% perdida de filas, metadatos y ausencia de transformacion
-- ============================================================================

USE staging_jardineria_ea3;

-- 1. Conciliacion fila a fila Origen vs Staging (debe ser 0 en diferencia)
SELECT 'stg_oficina' AS entidad,
       (SELECT COUNT(*) FROM jardineria_ea3.oficina) AS filas_origen,
       COUNT(*) AS filas_staging,
       COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.oficina) AS diferencia
FROM stg_oficina
UNION ALL
SELECT 'stg_empleado', (SELECT COUNT(*) FROM jardineria_ea3.empleado), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.empleado) FROM stg_empleado
UNION ALL
SELECT 'stg_categoria_producto', (SELECT COUNT(*) FROM jardineria_ea3.Categoria_producto), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.Categoria_producto) FROM stg_categoria_producto
UNION ALL
SELECT 'stg_cliente', (SELECT COUNT(*) FROM jardineria_ea3.cliente), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.cliente) FROM stg_cliente
UNION ALL
SELECT 'stg_pedido', (SELECT COUNT(*) FROM jardineria_ea3.pedido), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.pedido) FROM stg_pedido
UNION ALL
SELECT 'stg_producto', (SELECT COUNT(*) FROM jardineria_ea3.producto), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.producto) FROM stg_producto
UNION ALL
SELECT 'stg_detalle_pedido', (SELECT COUNT(*) FROM jardineria_ea3.detalle_pedido), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.detalle_pedido) FROM stg_detalle_pedido
UNION ALL
SELECT 'stg_pago', (SELECT COUNT(*) FROM jardineria_ea3.pago), COUNT(*), COUNT(*) - (SELECT COUNT(*) FROM jardineria_ea3.pago) FROM stg_pago;

-- 2. Verificacion de completitud de fecha_carga y etiquetas estado_calidad
SELECT 'fecha_carga nula en tablas staging' AS verificacion,
       (SELECT COUNT(*) FROM stg_oficina WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_empleado WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_categoria_producto WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_cliente WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_pedido WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_producto WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_detalle_pedido WHERE fecha_carga IS NULL)
       + (SELECT COUNT(*) FROM stg_pago WHERE fecha_carga IS NULL) AS errores;

-- 3. Resumen de marcas de calidad registradas en Staging (sin alterar valores crudos)
SELECT 'stg_cliente' AS tabla, estado_calidad, COUNT(*) AS cantidad FROM stg_cliente GROUP BY estado_calidad
UNION ALL
SELECT 'stg_pedido', estado_calidad, COUNT(*) FROM stg_pedido GROUP BY estado_calidad
UNION ALL
SELECT 'stg_detalle_pedido', estado_calidad, COUNT(*) FROM stg_detalle_pedido GROUP BY estado_calidad
UNION ALL
SELECT 'stg_categoria_producto', estado_calidad, COUNT(*) FROM stg_categoria_producto GROUP BY estado_calidad;

-- 4. Ultimo lote de ejecucion ETL en Staging
SELECT * FROM ctl_ejecucion_staging ORDER BY id_lote DESC LIMIT 5;
