-- ============================================================================
-- EVIDENCIA DE APRENDIZAJE 3: ETAPA 4 - CONSULTAS ANALITICAS EN EL DATA MART
-- Curso: Bases de Datos II (PREICA2602B020061) - Docente: Mg. Carolina Marquez
-- Estudiante: Carlos Alberto Millan Castano - Grupo 3
-- ============================================================================

USE dm_jardineria_ea3;

-- 1. VERIFICACION DE CONTEOS DEL MODELO ESTRELLA
SELECT 'dim_tiempo' AS tabla_datamart, COUNT(*) AS total_registros FROM dim_tiempo UNION ALL
SELECT 'dim_producto', COUNT(*) FROM dim_producto UNION ALL
SELECT 'dim_cliente (deduplicado)', COUNT(*) FROM dim_cliente UNION ALL
SELECT 'dim_empleado (con oficina)', COUNT(*) FROM dim_empleado UNION ALL
SELECT 'fact_ventas (ventas efectivas)', COUNT(*) FROM fact_ventas UNION ALL
SELECT 'fact_pagos (recaudo)', COUNT(*) FROM fact_pagos;

-- 2. PRODUCTO MAS VENDIDO EN UNIDADES FISICAS (TOP 10)
SELECT
    p.codigo_producto,
    p.nombre_producto,
    p.nombre_categoria,
    SUM(fv.cantidad) AS total_unidades_vendidas,
    COUNT(DISTINCT fv.id_pedido_dd) AS num_pedidos,
    SUM(fv.importe_venta_linea) AS ingresos_totales,
    SUM(fv.utilidad_bruta_linea) AS utilidad_bruta
FROM fact_ventas fv
JOIN dim_producto p ON fv.sk_producto = p.sk_producto
GROUP BY p.codigo_producto, p.nombre_producto, p.nombre_categoria
ORDER BY total_unidades_vendidas DESC
LIMIT 10;

-- 3. PRODUCTO LIDER EN INGRESOS Y RENTABILIDAD (TOP 10)
SELECT
    p.codigo_producto,
    p.nombre_producto,
    p.nombre_categoria,
    SUM(fv.cantidad) AS total_unidades_vendidas,
    SUM(fv.importe_venta_linea) AS ingresos_totales,
    SUM(fv.costo_estimado_linea) AS costo_total,
    SUM(fv.utilidad_bruta_linea) AS utilidad_bruta
FROM fact_ventas fv
JOIN dim_producto p ON fv.sk_producto = p.sk_producto
GROUP BY p.codigo_producto, p.nombre_producto, p.nombre_categoria
ORDER BY ingresos_totales DESC
LIMIT 10;

-- 4. VENTAS Y RENTABILIDAD POR CATEGORIA DE PRODUCTO
SELECT
    p.nombre_categoria,
    COUNT(DISTINCT p.sk_producto) AS productos_vendidos,
    SUM(fv.cantidad) AS unidades_vendidas,
    SUM(fv.importe_venta_linea) AS ingresos_totales,
    SUM(fv.utilidad_bruta_linea) AS utilidad_bruta,
    ROUND(SUM(fv.utilidad_bruta_linea) / SUM(fv.importe_venta_linea) * 100, 2) AS margen_pct
FROM fact_ventas fv
JOIN dim_producto p ON fv.sk_producto = p.sk_producto
GROUP BY p.nombre_categoria
ORDER BY ingresos_totales DESC;

-- 5. EVOLUCION ANUAL DE VENTAS, UNIDADES Y PEDIDOS (DIM_TIEMPO)
SELECT
    t.anio,
    COUNT(DISTINCT fv.id_pedido_dd) AS pedidos_efectivos,
    SUM(fv.cantidad) AS unidades_vendidas,
    SUM(fv.importe_venta_linea) AS ingresos_totales,
    SUM(fv.utilidad_bruta_linea) AS utilidad_bruta
FROM fact_ventas fv
JOIN dim_tiempo t ON fv.sk_tiempo_pedido = t.sk_tiempo
GROUP BY t.anio
ORDER BY t.anio;

-- 6. VENTAS POR PAIS ESTANDARIZADO Y TOP CLIENTES (CON LASAS S.A. CONSOLIDADO)
SELECT
    c.pais,
    COUNT(DISTINCT c.sk_cliente) AS clientes_activos,
    COUNT(DISTINCT fv.id_pedido_dd) AS total_pedidos,
    SUM(fv.importe_venta_linea) AS ingresos_totales,
    SUM(fv.utilidad_bruta_linea) AS utilidad_bruta
FROM fact_ventas fv
JOIN dim_cliente c ON fv.sk_cliente = c.sk_cliente
GROUP BY c.pais
ORDER BY ingresos_totales DESC;
