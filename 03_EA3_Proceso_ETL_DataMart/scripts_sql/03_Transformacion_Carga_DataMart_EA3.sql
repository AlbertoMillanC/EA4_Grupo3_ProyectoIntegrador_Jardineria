-- ============================================================================
-- EVIDENCIA DE APRENDIZAJE 3: ETAPA 2 Y 3 - TRANSFORMACION Y CARGA AL DATA MART
-- Curso: Bases de Datos II (PREICA2602B020061) - Docente: Mg. Carolina Marquez
-- Estudiante: Carlos Alberto Millan Castano - Grupo 3
-- Arquitectura: Modelo Estrella Puro (dm_jardineria_ea3) sin copo de nieve.
--   Dimensiones: dim_tiempo, dim_producto (con categoria integrada),
--                dim_cliente (deduplicado y paises homologados),
--                dim_empleado (con oficina integrada).
--   Hechos:      fact_ventas (granularidad detalle_pedido limpio, sin rechazados)
--                fact_pagos (tesoreria separada de ventas).
-- ============================================================================

DROP DATABASE IF EXISTS dm_jardineria_ea3;
CREATE DATABASE dm_jardineria_ea3
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dm_jardineria_ea3;

-- ----------------------------------------------------------------------------
-- 1. CREACION DE TABLAS DEL MODELO ESTRELLA (DDL)
-- ----------------------------------------------------------------------------

CREATE TABLE ctl_carga_datamart (
    id_ejecucion INT AUTO_INCREMENT PRIMARY KEY,
    proceso VARCHAR(100) NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    dim_tiempo_filas INT DEFAULT 0,
    dim_producto_filas INT DEFAULT 0,
    dim_cliente_filas INT DEFAULT 0,
    dim_empleado_filas INT DEFAULT 0,
    fact_ventas_filas INT DEFAULT 0,
    fact_pagos_filas INT DEFAULT 0,
    estado VARCHAR(30) DEFAULT 'EN_PROCESO'
);

-- 1.1. Dimension Calendario / Tiempo
CREATE TABLE dim_tiempo (
    sk_tiempo INT PRIMARY KEY,
    fecha DATE NOT NULL,
    anio SMALLINT NOT NULL,
    semestre TINYINT NOT NULL,
    trimestre TINYINT NOT NULL,
    mes TINYINT NOT NULL,
    nombre_mes VARCHAR(15) NOT NULL,
    dia TINYINT NOT NULL,
    dia_semana TINYINT NOT NULL,
    es_fin_semana TINYINT(1) NOT NULL
);

-- 1.2. Dimension Producto (integra Categoria para evitar Copo de Nieve)
CREATE TABLE dim_producto (
    sk_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_producto_nk INT NOT NULL UNIQUE,
    codigo_producto VARCHAR(15) NOT NULL,
    nombre_producto VARCHAR(70) NOT NULL,
    id_categoria INT NOT NULL,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion_categoria VARCHAR(250) NOT NULL,
    dimensiones VARCHAR(25) NOT NULL,
    proveedor VARCHAR(50) NOT NULL,
    cantidad_en_stock SMALLINT NOT NULL,
    precio_venta_catalogo DECIMAL(15,2) NOT NULL,
    precio_proveedor_catalogo DECIMAL(15,2) NOT NULL,
    margen_unitario_catalogo DECIMAL(15,2) NOT NULL
);

-- 1.3. Dimension Empleado (integra Oficina para evitar Copo de Nieve)
CREATE TABLE dim_empleado (
    sk_empleado INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado_nk INT NOT NULL UNIQUE,
    nombre_completo VARCHAR(155) NOT NULL,
    email VARCHAR(100) NOT NULL,
    extension VARCHAR(10) NOT NULL,
    puesto VARCHAR(50) NOT NULL,
    id_jefe INT NULL,
    id_oficina INT NOT NULL,
    codigo_oficina VARCHAR(10) NOT NULL,
    ciudad_oficina VARCHAR(30) NOT NULL,
    region_oficina VARCHAR(50) NOT NULL,
    pais_oficina VARCHAR(50) NOT NULL
);

-- 1.4. Dimension Cliente (deduplicada y normalizada geograficamente)
CREATE TABLE dim_cliente (
    sk_cliente INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente_nk INT NOT NULL UNIQUE,
    nombre_cliente VARCHAR(50) NOT NULL,
    contacto_completo VARCHAR(65) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    region VARCHAR(50) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    codigo_postal VARCHAR(10) NOT NULL,
    limite_credito DECIMAL(15,2) NOT NULL
);

-- Tabla auxiliar de mapeo para consolidar duplicados de clientes (ej. ID 11 -> ID 5 Lasas S.A.)
CREATE TABLE map_cliente_dedup (
    id_cliente_origen INT PRIMARY KEY,
    id_cliente_maestro INT NOT NULL
);

-- 1.5. Tabla de Hechos Principal: Ventas (nivel atomico detalle_pedido)
CREATE TABLE fact_ventas (
    sk_venta INT AUTO_INCREMENT PRIMARY KEY,
    sk_producto INT NOT NULL,
    sk_cliente INT NOT NULL,
    sk_empleado INT NOT NULL,
    sk_tiempo_pedido INT NOT NULL,
    sk_tiempo_esperada INT NOT NULL,
    sk_tiempo_entrega INT NOT NULL,
    id_pedido_dd INT NOT NULL,
    id_detalle_origen INT NOT NULL,
    numero_linea SMALLINT NOT NULL,
    estado_pedido VARCHAR(15) NOT NULL,
    entrega_a_tiempo VARCHAR(20) NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario_historico DECIMAL(15,2) NOT NULL,
    costo_unitario_catalogo DECIMAL(15,2) NOT NULL,
    importe_venta_linea DECIMAL(15,2) NOT NULL,
    costo_estimado_linea DECIMAL(15,2) NOT NULL,
    utilidad_bruta_linea DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (sk_producto) REFERENCES dim_producto(sk_producto),
    FOREIGN KEY (sk_cliente) REFERENCES dim_cliente(sk_cliente),
    FOREIGN KEY (sk_empleado) REFERENCES dim_empleado(sk_empleado),
    FOREIGN KEY (sk_tiempo_pedido) REFERENCES dim_tiempo(sk_tiempo),
    FOREIGN KEY (sk_tiempo_esperada) REFERENCES dim_tiempo(sk_tiempo),
    FOREIGN KEY (sk_tiempo_entrega) REFERENCES dim_tiempo(sk_tiempo)
);

-- 1.6. Tabla de Hechos Complementaria: Pagos (tesoreria separada)
CREATE TABLE fact_pagos (
    sk_pago INT AUTO_INCREMENT PRIMARY KEY,
    sk_cliente INT NOT NULL,
    sk_empleado INT NOT NULL,
    sk_tiempo_pago INT NOT NULL,
    id_pago_origen INT NOT NULL,
    id_transaccion_dd VARCHAR(50) NOT NULL,
    forma_pago VARCHAR(40) NOT NULL,
    total_pagado DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (sk_cliente) REFERENCES dim_cliente(sk_cliente),
    FOREIGN KEY (sk_empleado) REFERENCES dim_empleado(sk_empleado),
    FOREIGN KEY (sk_tiempo_pago) REFERENCES dim_tiempo(sk_tiempo)
);

-- ----------------------------------------------------------------------------
-- 2. PROCESO DE TRANSFORMACION Y CARGA DESDE STAGING AL DATA MART
-- ----------------------------------------------------------------------------

INSERT INTO ctl_carga_datamart (proceso, estado)
VALUES ('ETL Transformacion y Carga Staging -> Data Mart Estrella (Grupo 3)', 'EN_PROCESO');
SET @id_ejec = LAST_INSERT_ID();

-- 2.1. Carga de dim_tiempo (registro centinela 19000101 + fechas unicas del negocio)
INSERT INTO dim_tiempo VALUES (19000101, '1900-01-01', 1900, 1, 1, 1, 'Sin Fecha', 1, 1, 0);

INSERT INTO dim_tiempo
SELECT
    CAST(DATE_FORMAT(f.fecha, '%Y%m%d') AS UNSIGNED) AS sk_tiempo,
    f.fecha,
    YEAR(f.fecha) AS anio,
    IF(MONTH(f.fecha) <= 6, 1, 2) AS semestre,
    QUARTER(f.fecha) AS trimestre,
    MONTH(f.fecha) AS mes,
    ELT(MONTH(f.fecha), 'Enero','Febrero','Marzo','Abril','Mayo','Junio',
                        'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre') AS nombre_mes,
    DAY(f.fecha) AS dia,
    DAYOFWEEK(f.fecha) AS dia_semana,
    IF(DAYOFWEEK(f.fecha) IN (1, 7), 1, 0) AS es_fin_semana
FROM (
    SELECT fecha_pedido AS fecha FROM staging_jardineria_ea3.stg_pedido WHERE fecha_pedido IS NOT NULL
    UNION
    SELECT fecha_esperada FROM staging_jardineria_ea3.stg_pedido WHERE fecha_esperada IS NOT NULL
    UNION
    SELECT fecha_entrega FROM staging_jardineria_ea3.stg_pedido WHERE fecha_entrega IS NOT NULL
    UNION
    SELECT fecha_pago FROM staging_jardineria_ea3.stg_pago WHERE fecha_pago IS NOT NULL
) f
ORDER BY f.fecha;

-- 2.2. Carga de dim_producto (limpieza de espacios, desnormalizacion de categoria y margen)
INSERT INTO dim_producto (
    id_producto_nk, codigo_producto, nombre_producto, id_categoria,
    nombre_categoria, descripcion_categoria, dimensiones, proveedor,
    cantidad_en_stock, precio_venta_catalogo, precio_proveedor_catalogo, margen_unitario_catalogo
)
SELECT
    p.ID_producto,
    TRIM(p.CodigoProducto),
    REGEXP_REPLACE(REPLACE(REPLACE(TRIM(p.nombre), '1Âª', '1ª'), 'DECÃ“', 'DECÓ'), ' +', ' ') AS nombre_producto,
    p.Categoria AS id_categoria,
    CASE c.Desc_Categoria
        WHEN 'Herbaceas' THEN 'Herbáceas'
        WHEN 'Aromaticas' THEN 'Aromáticas'
        ELSE TRIM(c.Desc_Categoria)
    END AS nombre_categoria,
    CASE
        WHEN c.descripcion_texto LIKE '2 %' THEN REPLACE(c.descripcion_texto, '2 ', 'Herramientas ')
        ELSE COALESCE(NULLIF(TRIM(c.descripcion_texto), ''), 'Sin descripción')
    END AS descripcion_categoria,
    COALESCE(NULLIF(TRIM(p.dimensiones), ''), 'No especificado') AS dimensiones,
    COALESCE(NULLIF(TRIM(p.proveedor), ''), 'Sin proveedor') AS proveedor,
    p.cantidad_en_stock,
    p.precio_venta,
    COALESCE(p.precio_proveedor, 0.00),
    p.precio_venta - COALESCE(p.precio_proveedor, 0.00) AS margen_unitario_catalogo
FROM staging_jardineria_ea3.stg_producto p
JOIN staging_jardineria_ea3.stg_categoria_producto c ON p.Categoria = c.Id_Categoria
ORDER BY p.ID_producto;

-- 2.3. Carga de dim_empleado (concatenacion de nombres, oficina integrada y homologacion de pais)
INSERT INTO dim_empleado (
    id_empleado_nk, nombre_completo, email, extension, puesto, id_jefe,
    id_oficina, codigo_oficina, ciudad_oficina, region_oficina, pais_oficina
)
VALUES (-1, 'Sin Representante Asignado', 'sin_asignar@jardineria.com', '0000', 'No Aplica', NULL,
        0, 'N/A', 'Sin Oficina', 'Sin Región', 'No Especificado');

INSERT INTO dim_empleado (
    id_empleado_nk, nombre_completo, email, extension, puesto, id_jefe,
    id_oficina, codigo_oficina, ciudad_oficina, region_oficina, pais_oficina
)
SELECT
    e.ID_empleado,
    TRIM(CONCAT_WS(' ', TRIM(e.nombre), TRIM(e.apellido1), NULLIF(TRIM(e.apellido2), ''))) AS nombre_completo,
    LOWER(TRIM(e.email)) AS email,
    TRIM(e.extension) AS extension,
    COALESCE(NULLIF(TRIM(e.puesto), ''), 'Sin cargo') AS puesto,
    e.ID_jefe,
    o.ID_oficina,
    TRIM(o.Descripcion) AS codigo_oficina,
    TRIM(o.ciudad) AS ciudad_oficina,
    COALESCE(NULLIF(TRIM(o.region), ''), TRIM(o.ciudad)) AS region_oficina,
    CASE TRIM(o.pais)
        WHEN 'EEUU' THEN 'Estados Unidos'
        WHEN 'USA' THEN 'Estados Unidos'
        WHEN 'Inglaterra' THEN 'Reino Unido'
        WHEN 'United Kingdom' THEN 'Reino Unido'
        WHEN 'Spain' THEN 'España'
        WHEN 'France' THEN 'Francia'
        ELSE TRIM(o.pais)
    END AS pais_oficina
FROM staging_jardineria_ea3.stg_empleado e
JOIN staging_jardineria_ea3.stg_oficina o ON e.ID_oficina = o.ID_oficina
ORDER BY e.ID_empleado;

-- 2.4. Mapeo de deduplicacion y carga de dim_cliente (36 -> 35 clientes unicos; Lasas S.A. unificado)
INSERT INTO map_cliente_dedup (id_cliente_origen, id_cliente_maestro)
SELECT
    c.ID_cliente,
    MIN(c.ID_cliente) OVER (PARTITION BY TRIM(c.nombre_cliente), TRIM(c.telefono), TRIM(c.ciudad)) AS id_cliente_maestro
FROM staging_jardineria_ea3.stg_cliente c;

INSERT INTO dim_cliente (
    id_cliente_nk, nombre_cliente, contacto_completo, telefono,
    ciudad, region, pais, codigo_postal, limite_credito
)
SELECT
    c.ID_cliente,
    TRIM(c.nombre_cliente) AS nombre_cliente,
    COALESCE(NULLIF(TRIM(CONCAT_WS(' ', REPLACE(NULLIF(TRIM(c.nombre_contacto), ''), 'FraÃ§ois', 'François'), NULLIF(TRIM(c.apellido_contacto), ''))), ''), 'Sin contacto') AS contacto_completo,
    TRIM(c.telefono) AS telefono,
    TRIM(c.ciudad) AS ciudad,
    COALESCE(NULLIF(TRIM(c.region), ''), TRIM(c.ciudad)) AS region,
    CASE TRIM(c.pais)
        WHEN 'USA' THEN 'Estados Unidos'
        WHEN 'EEUU' THEN 'Estados Unidos'
        WHEN 'Spain' THEN 'España'
        WHEN 'France' THEN 'Francia'
        WHEN 'United Kingdom' THEN 'Reino Unido'
        WHEN 'Inglaterra' THEN 'Reino Unido'
        ELSE COALESCE(NULLIF(TRIM(c.pais), ''), 'Sin País')
    END AS pais,
    COALESCE(NULLIF(TRIM(c.codigo_postal), ''), '00000') AS codigo_postal,
    COALESCE(c.limite_credito, 0.00) AS limite_credito
FROM staging_jardineria_ea3.stg_cliente c
JOIN map_cliente_dedup m ON c.ID_cliente = m.id_cliente_origen AND m.id_cliente_origen = m.id_cliente_maestro
ORDER BY c.ID_cliente;

-- 2.5. Carga de fact_ventas (excluye Rechazados y duplicado exacto en detalle_pedido; preserva precio historico)
INSERT INTO fact_ventas (
    sk_producto, sk_cliente, sk_empleado,
    sk_tiempo_pedido, sk_tiempo_esperada, sk_tiempo_entrega,
    id_pedido_dd, id_detalle_origen, numero_linea, estado_pedido, entrega_a_tiempo,
    cantidad, precio_unitario_historico, costo_unitario_catalogo,
    importe_venta_linea, costo_estimado_linea, utilidad_bruta_linea
)
SELECT
    dp_dim.sk_producto,
    dc.sk_cliente,
    COALESCE(de.sk_empleado, (SELECT sk_empleado FROM dim_empleado WHERE id_empleado_nk = -1)) AS sk_empleado,
    CAST(DATE_FORMAT(pe.fecha_pedido, '%Y%m%d') AS UNSIGNED) AS sk_tiempo_pedido,
    CASE
        WHEN pe.fecha_esperada IS NOT NULL AND pe.fecha_esperada >= pe.fecha_pedido
        THEN CAST(DATE_FORMAT(pe.fecha_esperada, '%Y%m%d') AS UNSIGNED)
        ELSE 19000101
    END AS sk_tiempo_esperada,
    CASE
        WHEN pe.fecha_entrega IS NOT NULL AND pe.fecha_entrega >= pe.fecha_pedido
        THEN CAST(DATE_FORMAT(pe.fecha_entrega, '%Y%m%d') AS UNSIGNED)
        ELSE 19000101
    END AS sk_tiempo_entrega,
    pe.ID_pedido AS id_pedido_dd,
    dp.ID_detalle_pedido AS id_detalle_origen,
    dp.numero_linea,
    TRIM(pe.estado) AS estado_pedido,
    CASE
        WHEN pe.fecha_entrega IS NULL THEN 'Sin Entregar'
        WHEN pe.fecha_entrega < pe.fecha_pedido OR pe.fecha_esperada < pe.fecha_pedido THEN 'Fecha Inconsistente'
        WHEN pe.fecha_entrega <= pe.fecha_esperada THEN 'A Tiempo'
        ELSE 'Con Retraso'
    END AS entrega_a_tiempo,
    dp.cantidad,
    dp.precio_unidad AS precio_unitario_historico,
    dp_dim.precio_proveedor_catalogo AS costo_unitario_catalogo,
    ROUND(dp.cantidad * dp.precio_unidad, 2) AS importe_venta_linea,
    ROUND(dp.cantidad * dp_dim.precio_proveedor_catalogo, 2) AS costo_estimado_linea,
    ROUND((dp.cantidad * dp.precio_unidad) - (dp.cantidad * dp_dim.precio_proveedor_catalogo), 2) AS utilidad_bruta_linea
FROM staging_jardineria_ea3.stg_detalle_pedido dp
JOIN staging_jardineria_ea3.stg_pedido pe ON dp.ID_pedido = pe.ID_pedido
JOIN map_cliente_dedup mc ON pe.ID_cliente = mc.id_cliente_origen
JOIN dim_cliente dc ON mc.id_cliente_maestro = dc.id_cliente_nk
JOIN staging_jardineria_ea3.stg_cliente sc_orig ON mc.id_cliente_maestro = sc_orig.ID_cliente
LEFT JOIN dim_empleado de ON sc_orig.ID_empleado_rep_ventas = de.id_empleado_nk
JOIN dim_producto dp_dim ON dp.ID_producto = dp_dim.id_producto_nk
WHERE dp.estado_calidad NOT IN ('OBSERVADO_DUPLICADO', 'EXCLUIR_VENTA_RECHAZADO');

-- 2.6. Carga de fact_pagos (tesoreria)
INSERT INTO fact_pagos (
    sk_cliente, sk_empleado, sk_tiempo_pago,
    id_pago_origen, id_transaccion_dd, forma_pago, total_pagado
)
SELECT
    dc.sk_cliente,
    COALESCE(de.sk_empleado, (SELECT sk_empleado FROM dim_empleado WHERE id_empleado_nk = -1)) AS sk_empleado,
    CAST(DATE_FORMAT(pg.fecha_pago, '%Y%m%d') AS UNSIGNED) AS sk_tiempo_pago,
    pg.ID_pago,
    TRIM(pg.id_transaccion),
    TRIM(pg.forma_pago),
    pg.total
FROM staging_jardineria_ea3.stg_pago pg
JOIN map_cliente_dedup mc ON pg.ID_cliente = mc.id_cliente_origen
JOIN dim_cliente dc ON mc.id_cliente_maestro = dc.id_cliente_nk
JOIN staging_jardineria_ea3.stg_cliente sc_orig ON mc.id_cliente_maestro = sc_orig.ID_cliente
LEFT JOIN dim_empleado de ON sc_orig.ID_empleado_rep_ventas = de.id_empleado_nk;

-- Actualizar bitacora de carga del Data Mart
UPDATE ctl_carga_datamart
SET fecha_fin = NOW(),
    dim_tiempo_filas = (SELECT COUNT(*) FROM dim_tiempo),
    dim_producto_filas = (SELECT COUNT(*) FROM dim_producto),
    dim_cliente_filas = (SELECT COUNT(*) FROM dim_cliente),
    dim_empleado_filas = (SELECT COUNT(*) FROM dim_empleado),
    fact_ventas_filas = (SELECT COUNT(*) FROM fact_ventas),
    fact_pagos_filas = (SELECT COUNT(*) FROM fact_pagos),
    estado = 'COMPLETADO_EXITOSO'
WHERE id_ejecucion = @id_ejec;

-- 3. VERIFICACION DE CARGA EN EL DATA MART FINAL
SELECT * FROM ctl_carga_datamart;
