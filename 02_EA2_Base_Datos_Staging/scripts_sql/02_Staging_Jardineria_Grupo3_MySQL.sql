-- ============================================================================
-- EVIDENCIA DE APRENDIZAJE 2 (CORREGIDA): BASE DE DATOS STAGING EN CRUDO
-- Curso: Bases de Datos II (PREICA2602B020061) - Docente: Mg. Carolina Marquez
-- Estudiante: Carlos Alberto Millan Castano - Grupo 3
-- Motor: MySQL 8.4 (MySQL Workbench)
-- Nota: Sin transformaciones ni atributos derivados (eso corresponde a EA3).
--       Copia fiel del origen + fecha_carga + marcas de calidad + TRUNCATE.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS staging_jardineria_g3
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE staging_jardineria_g3;

-- ----------------------------------------------------------------------------
-- 1. DEFINICION DE TABLAS STAGING (DDL)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ctl_ejecucion_etl (
    id_lote_etl INT AUTO_INCREMENT PRIMARY KEY,
    nombre_proceso VARCHAR(100) NOT NULL,
    sistema_origen VARCHAR(50) NOT NULL DEFAULT 'jardineria',
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    registros_extraidos INT NOT NULL DEFAULT 0,
    registros_validos INT NOT NULL DEFAULT 0,
    registros_observados INT NOT NULL DEFAULT 0,
    estado_ejecucion VARCHAR(30) NOT NULL DEFAULT 'EN_PROGRESO'
);

CREATE TABLE IF NOT EXISTS stg_oficina (
    ID_oficina INT NOT NULL,
    Descripcion VARCHAR(10) NOT NULL,
    ciudad VARCHAR(30) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL,
    codigo_postal VARCHAR(10) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    linea_direccion1 VARCHAR(50) NOT NULL,
    linea_direccion2 VARCHAR(50) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_empleado (
    ID_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50) NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ID_oficina INT NOT NULL,
    ID_jefe INT NULL,
    puesto VARCHAR(50) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_categoria_producto (
    Id_Categoria INT NOT NULL,
    Desc_Categoria VARCHAR(50) NOT NULL,
    descripcion_texto TEXT NULL,
    descripcion_html TEXT NULL,
    imagen VARCHAR(256) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_producto (
    ID_producto VARCHAR(15) NOT NULL,
    nombre VARCHAR(70) NOT NULL,
    Categoria INT NOT NULL,
    dimensiones VARCHAR(25) NULL,
    proveedor VARCHAR(50) NULL,
    descripcion TEXT NULL,
    cantidad_en_stock SMALLINT NOT NULL,
    precio_venta DECIMAL(15,2) NOT NULL,
    precio_proveedor DECIMAL(15,2) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_cliente (
    ID_cliente INT NOT NULL,
    nombre_cliente VARCHAR(50) NOT NULL,
    nombre_contacto VARCHAR(30) NULL,
    apellido_contacto VARCHAR(30) NULL,
    telefono VARCHAR(15) NOT NULL,
    fax VARCHAR(15) NOT NULL,
    linea_direccion1 VARCHAR(50) NOT NULL,
    linea_direccion2 VARCHAR(50) NULL,
    ciudad VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL,
    pais VARCHAR(50) NULL,
    codigo_postal VARCHAR(10) NULL,
    ID_empleado_rep_ventas INT NULL,
    limite_credito DECIMAL(15,2) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_pedido (
    ID_pedido INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    fecha_esperada DATE NOT NULL,
    fecha_entrega DATE NULL,
    estado VARCHAR(15) NOT NULL,
    comentarios TEXT NULL,
    ID_cliente INT NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_detalle_pedido (
    ID_pedido INT NOT NULL,
    ID_producto VARCHAR(15) NOT NULL,
    cantidad INT NOT NULL,
    precio_unidad DECIMAL(15,2) NOT NULL,
    numero_linea SMALLINT NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_pago (
    ID_cliente INT NOT NULL,
    forma_pago VARCHAR(40) NOT NULL,
    id_transaccion VARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(35) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_auditoria_calidad (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabla_origen VARCHAR(50) NOT NULL,
    clave_registro VARCHAR(100) NOT NULL,
    tipo_anomalia VARCHAR(50) NOT NULL,
    descripcion_anomalia VARCHAR(250) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 2. CARGA CON TRUNCATE (RE-EJECUTABLE SIN DUPLICAR) + MARCAS DE CALIDAD
-- ----------------------------------------------------------------------------

INSERT INTO ctl_ejecucion_etl (nombre_proceso, sistema_origen, estado_ejecucion)
VALUES ('Carga Staging Crudo (Grupo 3)', 'jardineria', 'EN_PROGRESO');
SET @id_lote = LAST_INSERT_ID();

-- 2.1. stg_oficina (copia tal cual)
TRUNCATE TABLE stg_oficina;
INSERT INTO stg_oficina (
    ID_oficina, Descripcion, ciudad, pais, region, codigo_postal,
    telefono, linea_direccion1, linea_direccion2, fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    o.ID_oficina, o.Descripcion, o.ciudad, o.pais, o.region, o.codigo_postal,
    o.telefono, o.linea_direccion1, o.linea_direccion2, NOW(),
    'VALIDO', NULL
FROM jardineria.oficina o;

-- 2.2. stg_empleado (copia tal cual + marca de FK)
TRUNCATE TABLE stg_empleado;
INSERT INTO stg_empleado (
    ID_empleado, nombre, apellido1, apellido2, extension, email,
    ID_oficina, ID_jefe, puesto, fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    e.ID_empleado, e.nombre, e.apellido1, e.apellido2, e.extension, e.email,
    e.ID_oficina, e.ID_jefe, e.puesto, NOW(),
    CASE WHEN o.ID_oficina IS NULL THEN 'HUERFANO_FK' ELSE 'VALIDO' END,
    CASE WHEN o.ID_oficina IS NULL THEN 'ID_oficina no existe en oficina' ELSE NULL END
FROM jardineria.empleado e
LEFT JOIN jardineria.oficina o ON e.ID_oficina = o.ID_oficina;

-- 2.3. stg_categoria_producto (copia tal cual + marca si no tiene productos)
TRUNCATE TABLE stg_categoria_producto;
INSERT INTO stg_categoria_producto (
    Id_Categoria, Desc_Categoria, descripcion_texto, descripcion_html, imagen,
    fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    c.Id_Categoria, c.Desc_Categoria, c.descripcion_texto, c.descripcion_html, c.imagen, NOW(),
    CASE WHEN COUNT(p.ID_producto) = 0 THEN 'OBSERVADO' ELSE 'VALIDO' END,
    CASE WHEN COUNT(p.ID_producto) = 0 THEN 'Categoria sin productos asociados' ELSE NULL END
FROM jardineria.Categoria_producto c
LEFT JOIN jardineria.producto p ON c.Id_Categoria = p.Categoria
GROUP BY c.Id_Categoria, c.Desc_Categoria, c.descripcion_texto, c.descripcion_html, c.imagen;

-- 2.4. stg_producto (copia tal cual + marca de FK)
TRUNCATE TABLE stg_producto;
INSERT INTO stg_producto (
    ID_producto, nombre, Categoria, dimensiones, proveedor, descripcion,
    cantidad_en_stock, precio_venta, precio_proveedor, fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    p.ID_producto, p.nombre, p.Categoria, p.dimensiones, p.proveedor, p.descripcion,
    p.cantidad_en_stock, p.precio_venta, p.precio_proveedor, NOW(),
    CASE WHEN c.Id_Categoria IS NULL THEN 'HUERFANO_FK' ELSE 'VALIDO' END,
    CASE WHEN c.Id_Categoria IS NULL THEN 'Categoria no existe en Categoria_producto' ELSE NULL END
FROM jardineria.producto p
LEFT JOIN jardineria.Categoria_producto c ON p.Categoria = c.Id_Categoria;

-- 2.5. stg_cliente (copia tal cual + marca de duplicado Lasas S.A.)
TRUNCATE TABLE stg_cliente;
INSERT INTO stg_cliente (
    ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, fax,
    linea_direccion1, linea_direccion2, ciudad, region, pais, codigo_postal,
    ID_empleado_rep_ventas, limite_credito, fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    cl.ID_cliente, cl.nombre_cliente, cl.nombre_contacto, cl.apellido_contacto, cl.telefono, cl.fax,
    cl.linea_direccion1, cl.linea_direccion2, cl.ciudad, cl.region, cl.pais, cl.codigo_postal,
    cl.ID_empleado_rep_ventas, cl.limite_credito, NOW(),
    CASE WHEN cl.rn > 1 THEN 'OBSERVADO_DUPLICADO' ELSE 'VALIDO' END,
    CASE WHEN cl.rn > 1 THEN 'Cliente duplicado (mismo nombre, telefono y ciudad)' ELSE NULL END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY nombre_cliente, telefono, ciudad ORDER BY ID_cliente) AS rn
    FROM jardineria.cliente
) cl;

-- 2.6. stg_pedido (copia tal cual + marcas de huerfano, fechas, estado y duplicado)
TRUNCATE TABLE stg_pedido;
INSERT INTO stg_pedido (
    ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, ID_cliente,
    fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    pd.ID_pedido, pd.fecha_pedido, pd.fecha_esperada, pd.fecha_entrega, pd.estado, pd.comentarios, pd.ID_cliente,
    NOW(),
    CASE
        WHEN c.ID_cliente IS NULL THEN 'HUERFANO_FK'
        WHEN pd.fecha_esperada < pd.fecha_pedido OR pd.fecha_entrega < pd.fecha_pedido THEN 'OBSERVADO_FECHAS'
        WHEN (pd.estado = 'Entregado' AND pd.fecha_entrega IS NULL)
          OR (pd.estado IN ('Pendiente', 'Rechazado') AND pd.fecha_entrega IS NOT NULL) THEN 'OBSERVADO_ESTADO'
        WHEN pd.rn > 1 THEN 'OBSERVADO_DUPLICADO'
        ELSE 'VALIDO'
    END,
    CASE
        WHEN c.ID_cliente IS NULL THEN CONCAT('ID_cliente=', pd.ID_cliente, ' no existe en cliente')
        WHEN pd.fecha_esperada < pd.fecha_pedido OR pd.fecha_entrega < pd.fecha_pedido THEN 'fecha_esperada o fecha_entrega menor a fecha_pedido'
        WHEN pd.estado = 'Entregado' AND pd.fecha_entrega IS NULL THEN 'Estado Entregado con fecha_entrega NULL'
        WHEN pd.estado IN ('Pendiente', 'Rechazado') AND pd.fecha_entrega IS NOT NULL THEN CONCAT('Estado ', pd.estado, ' con fecha_entrega diligenciada')
        WHEN pd.rn > 1 THEN 'Pedido duplicado (mismo cliente, fechas y estado)'
        ELSE NULL
    END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ID_cliente, fecha_pedido, fecha_esperada, estado ORDER BY ID_pedido) AS rn
    FROM jardineria.pedido
) pd
LEFT JOIN jardineria.cliente c ON pd.ID_cliente = c.ID_cliente;

-- 2.7. stg_detalle_pedido (copia tal cual + marca de huerfano / rechazado)
TRUNCATE TABLE stg_detalle_pedido;
INSERT INTO stg_detalle_pedido (
    ID_pedido, ID_producto, cantidad, precio_unidad, numero_linea,
    fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    dp.ID_pedido, dp.ID_producto, dp.cantidad, dp.precio_unidad, dp.numero_linea,
    NOW(),
    CASE
        WHEN p.ID_pedido IS NULL THEN 'HUERFANO_FK'
        WHEN pr.ID_producto IS NULL THEN 'HUERFANO_FK'
        WHEN p.estado = 'Rechazado' THEN 'EXCLUIR_VENTA_RECHAZADO'
        ELSE 'VALIDO'
    END,
    CASE
        WHEN p.ID_pedido IS NULL THEN CONCAT('ID_pedido=', dp.ID_pedido, ' no existe en pedido')
        WHEN pr.ID_producto IS NULL THEN CONCAT('ID_producto=', dp.ID_producto, ' no existe en producto')
        WHEN p.estado = 'Rechazado' THEN 'Detalle pertenece a pedido en estado Rechazado'
        ELSE NULL
    END
FROM jardineria.detalle_pedido dp
LEFT JOIN jardineria.pedido p ON dp.ID_pedido = p.ID_pedido
LEFT JOIN jardineria.producto pr ON dp.ID_producto = pr.ID_producto;

-- 2.8. stg_pago (copia tal cual + marca de huerfano cliente 38)
TRUNCATE TABLE stg_pago;
INSERT INTO stg_pago (
    ID_cliente, forma_pago, id_transaccion, fecha_pago, total,
    fecha_carga, estado_calidad, observacion_calidad
)
SELECT
    pg.ID_cliente, pg.forma_pago, pg.id_transaccion, pg.fecha_pago, pg.total,
    NOW(),
    CASE WHEN c.ID_cliente IS NULL THEN 'HUERFANO_FK' ELSE 'VALIDO' END,
    CASE WHEN c.ID_cliente IS NULL THEN CONCAT('ID_cliente=', pg.ID_cliente, ' no existe en cliente') ELSE NULL END
FROM jardineria.pago pg
LEFT JOIN jardineria.cliente c ON pg.ID_cliente = c.ID_cliente;

-- 2.9. Auditoria consolidada (con TRUNCATE previo)
TRUNCATE TABLE stg_auditoria_calidad;
INSERT INTO stg_auditoria_calidad (tabla_origen, clave_registro, tipo_anomalia, descripcion_anomalia)
SELECT 'Categoria_producto', CAST(Id_Categoria AS CHAR), estado_calidad, observacion_calidad FROM stg_categoria_producto WHERE estado_calidad <> 'VALIDO'
UNION ALL
SELECT 'cliente', CAST(ID_cliente AS CHAR), estado_calidad, observacion_calidad FROM stg_cliente WHERE estado_calidad <> 'VALIDO'
UNION ALL
SELECT 'pedido', CAST(ID_pedido AS CHAR), estado_calidad, observacion_calidad FROM stg_pedido WHERE estado_calidad <> 'VALIDO'
UNION ALL
SELECT 'detalle_pedido', CONCAT(ID_pedido, '-', ID_producto), estado_calidad, observacion_calidad FROM stg_detalle_pedido WHERE estado_calidad <> 'VALIDO'
UNION ALL
SELECT 'pago', CONCAT(ID_cliente, '-', id_transaccion), estado_calidad, observacion_calidad FROM stg_pago WHERE estado_calidad <> 'VALIDO';

-- Actualizar cierre del lote ETL
UPDATE ctl_ejecucion_etl
SET fecha_fin = NOW(),
    registros_extraidos = (
        (SELECT COUNT(*) FROM stg_oficina) + (SELECT COUNT(*) FROM stg_empleado) +
        (SELECT COUNT(*) FROM stg_categoria_producto) + (SELECT COUNT(*) FROM stg_producto) +
        (SELECT COUNT(*) FROM stg_cliente) + (SELECT COUNT(*) FROM stg_pedido) +
        (SELECT COUNT(*) FROM stg_detalle_pedido) + (SELECT COUNT(*) FROM stg_pago)
    ),
    registros_observados = (SELECT COUNT(*) FROM stg_auditoria_calidad),
    registros_validos = (
        (SELECT COUNT(*) FROM stg_oficina) + (SELECT COUNT(*) FROM stg_empleado) +
        (SELECT COUNT(*) FROM stg_categoria_producto) + (SELECT COUNT(*) FROM stg_producto) +
        (SELECT COUNT(*) FROM stg_cliente) + (SELECT COUNT(*) FROM stg_pedido) +
        (SELECT COUNT(*) FROM stg_detalle_pedido) + (SELECT COUNT(*) FROM stg_pago)
    ) - (SELECT COUNT(*) FROM stg_auditoria_calidad),
    estado_ejecucion = 'COMPLETADO_EXITOSO'
WHERE id_lote_etl = @id_lote;

-- ----------------------------------------------------------------------------
-- 3. VALIDACION FINAL DE CONTEOS (ORIGEN VS STAGING)
-- ----------------------------------------------------------------------------
SELECT '1. oficina -> stg_oficina' AS entidad, (SELECT COUNT(*) FROM jardineria.oficina) AS origen, (SELECT COUNT(*) FROM stg_oficina) AS staging UNION ALL
SELECT '2. empleado -> stg_empleado', (SELECT COUNT(*) FROM jardineria.empleado), (SELECT COUNT(*) FROM stg_empleado) UNION ALL
SELECT '3. Categoria_producto -> stg_categoria_producto', (SELECT COUNT(*) FROM jardineria.Categoria_producto), (SELECT COUNT(*) FROM stg_categoria_producto) UNION ALL
SELECT '4. producto -> stg_producto', (SELECT COUNT(*) FROM jardineria.producto), (SELECT COUNT(*) FROM stg_producto) UNION ALL
SELECT '5. cliente -> stg_cliente', (SELECT COUNT(*) FROM jardineria.cliente), (SELECT COUNT(*) FROM stg_cliente) UNION ALL
SELECT '6. pedido -> stg_pedido', (SELECT COUNT(*) FROM jardineria.pedido), (SELECT COUNT(*) FROM stg_pedido) UNION ALL
SELECT '7. detalle_pedido -> stg_detalle_pedido', (SELECT COUNT(*) FROM jardineria.detalle_pedido), (SELECT COUNT(*) FROM stg_detalle_pedido) UNION ALL
SELECT '8. pago -> stg_pago', (SELECT COUNT(*) FROM jardineria.pago), (SELECT COUNT(*) FROM stg_pago);

SELECT tabla_origen, tipo_anomalia, COUNT(*) AS cantidad FROM stg_auditoria_calidad GROUP BY tabla_origen, tipo_anomalia;
SELECT * FROM ctl_ejecucion_etl;
