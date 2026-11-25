-- ============================================================================
-- PRUEBAS DE CALIDAD DE DATOS 01: DIAGNOSTICO Y PERFILAMIENTO EN ORIGEN OLTP
-- Base de datos evaluada: jardineria_ea3
-- Estudiante: Carlos Alberto Millan Castano - Grupo 3
-- ============================================================================

USE jardineria_ea3;

-- 1. Perfilamiento tecnico de esquema, tipos de datos y reglas NOT NULL
SELECT
    TABLE_NAME AS tabla,
    COLUMN_NAME AS columna,
    DATA_TYPE AS tipo_dato,
    CHARACTER_MAXIMUM_LENGTH AS longitud_max,
    IS_NULLABLE AS acepta_nulos,
    COLUMN_KEY AS llave
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria_ea3'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 2. Diagnostico cuantitativo de anomalias presentes en el origen (Antes del ETL)
SELECT 'Clientes duplicados exactos (Lasas S.A.)' AS anomalia,
       COUNT(*) - COUNT(DISTINCT CONCAT(nombre_cliente, '|', telefono, '|', ciudad)) AS hallazgos FROM cliente
UNION ALL
SELECT 'Lineas detalle_pedido duplicadas exactas (ID_detalle=317)',
       COUNT(*) - COUNT(DISTINCT CONCAT(ID_pedido, '|', ID_producto)) FROM detalle_pedido
UNION ALL
SELECT 'Cabeceras de pedido repetidas (cliente+fechas+estado)',
       COUNT(*) - COUNT(DISTINCT CONCAT(ID_cliente, '|', fecha_pedido, '|', fecha_esperada, '|', estado)) FROM pedido
UNION ALL
SELECT 'Pedidos con fechas imposibles (esperada/entrega < pedido)',
       COUNT(*) FROM pedido WHERE fecha_esperada < fecha_pedido OR fecha_entrega < fecha_pedido
UNION ALL
SELECT 'Pedidos con estado contradictorio frente a fecha_entrega',
       COUNT(*) FROM pedido WHERE (estado = 'Entregado' AND fecha_entrega IS NULL) OR (estado IN ('Pendiente', 'Rechazado') AND fecha_entrega IS NOT NULL)
UNION ALL
SELECT 'Pedidos en estado Rechazado',
       COUNT(*) FROM pedido WHERE estado = 'Rechazado'
UNION ALL
SELECT 'Lineas detalle pertenecientes a pedidos Rechazados',
       COUNT(*) FROM detalle_pedido dp JOIN pedido p ON dp.ID_pedido = p.ID_pedido WHERE p.estado = 'Rechazado'
UNION ALL
SELECT 'Lineas con precio historico distinto al catalogo actual',
       COUNT(*) FROM detalle_pedido dp JOIN producto pr ON dp.ID_producto = pr.ID_producto WHERE dp.precio_unidad <> pr.precio_venta
UNION ALL
SELECT 'Categorias sin productos asociados (Herbaceas)',
       COUNT(*) FROM Categoria_producto c LEFT JOIN producto p ON c.Id_Categoria = p.Categoria WHERE p.ID_producto IS NULL
UNION ALL
SELECT 'Paises en oficinas/clientes sin homologar al espanol',
       (SELECT COUNT(*) FROM oficina WHERE pais IN ('EEUU', 'Inglaterra'))
       + (SELECT COUNT(*) FROM cliente WHERE pais IN ('USA', 'Spain', 'France', 'United Kingdom'))
UNION ALL
SELECT 'Textos corruptos o residual UTF-8 (2 para todo / 1Aa / DECA / Francois)',
       (SELECT COUNT(*) FROM Categoria_producto WHERE descripcion_texto LIKE '2 para todo%')
       + (SELECT COUNT(*) FROM producto WHERE nombre LIKE '%1Âª%' OR nombre LIKE '%DECÃ%')
       + (SELECT COUNT(*) FROM cliente WHERE nombre_contacto LIKE '%FraÃ§ois%');
