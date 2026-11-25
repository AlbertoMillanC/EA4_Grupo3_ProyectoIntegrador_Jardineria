-- ============================================================================
-- EVIDENCIA DE APRENDIZAJE 3: ETAPA 1 - EXTRACCION A BASE DE DATOS STAGING
-- Curso: Bases de Datos II (PREICA2602B020061) - Docente: Mg. Carolina Marquez
-- Estudiante: Carlos Alberto Millan Castano - Grupo 3
-- Principio aplicado: Staging copia los datos tal cual del origen con TRUNCATE,
--                     agrega fecha_carga y marca las anomalias sin transformar.
-- ============================================================================

CREATE DATABASE IF NOT EXISTS staging_jardineria_ea3
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE staging_jardineria_ea3;

-- 1. ESTRUCTURA DE TABLAS EN STAGING (ESPEJO DEL ORIGEN + METADATOS DE CONTROL)
CREATE TABLE IF NOT EXISTS ctl_ejecucion_staging (
    id_lote INT AUTO_INCREMENT PRIMARY KEY,
    proceso VARCHAR(100) NOT NULL,
    base_origen VARCHAR(50) NOT NULL DEFAULT 'jardineria_ea3',
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    filas_extraidas INT NOT NULL DEFAULT 0,
    filas_validas INT NOT NULL DEFAULT 0,
    filas_observadas INT NOT NULL DEFAULT 0,
    estado VARCHAR(30) NOT NULL DEFAULT 'EN_PROCESO'
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
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
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
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_categoria_producto (
    Id_Categoria INT NOT NULL,
    Desc_Categoria VARCHAR(50) NOT NULL,
    descripcion_texto TEXT NULL,
    descripcion_html TEXT NULL,
    imagen VARCHAR(256) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
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
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
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
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_producto (
    ID_producto INT NOT NULL,
    CodigoProducto VARCHAR(15) NOT NULL,
    nombre VARCHAR(70) NOT NULL,
    Categoria INT NOT NULL,
    dimensiones VARCHAR(25) NULL,
    proveedor VARCHAR(50) NULL,
    descripcion TEXT NULL,
    cantidad_en_stock SMALLINT NOT NULL,
    precio_venta DECIMAL(15,2) NOT NULL,
    precio_proveedor DECIMAL(15,2) NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_detalle_pedido (
    ID_detalle_pedido INT NOT NULL,
    ID_pedido INT NOT NULL,
    ID_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unidad DECIMAL(15,2) NOT NULL,
    numero_linea SMALLINT NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

CREATE TABLE IF NOT EXISTS stg_pago (
    ID_pago INT NOT NULL,
    ID_cliente INT NOT NULL,
    forma_pago VARCHAR(40) NOT NULL,
    id_transaccion VARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_calidad VARCHAR(40) NOT NULL DEFAULT 'VALIDO',
    observacion_calidad VARCHAR(250) NULL
);

-- 2. EXTRACCION CON TRUNCATE (IDEMPOTENTE, SIN DUPLICAR EN RECARGAS)
INSERT INTO ctl_ejecucion_staging (proceso, base_origen, estado)
VALUES ('Extraccion Cruda Origen -> Staging (EA3 Grupo 3)', 'jardineria_ea3', 'EN_PROCESO');
SET @lote_stg = LAST_INSERT_ID();

TRUNCATE TABLE stg_oficina;
INSERT INTO stg_oficina
SELECT ID_oficina, Descripcion, ciudad, pais, region, codigo_postal, telefono,
       linea_direccion1, linea_direccion2, NOW(),
       CASE WHEN pais IN ('EEUU','Inglaterra') OR linea_direccion2 = '' THEN 'OBSERVADO_FORMATO' ELSE 'VALIDO' END,
       CASE WHEN pais IN ('EEUU','Inglaterra') OR linea_direccion2 = '' THEN 'Pais no estandarizado o cadena vacia para limpiar en Transformacion' ELSE NULL END
FROM jardineria_ea3.oficina;

TRUNCATE TABLE stg_empleado;
INSERT INTO stg_empleado
SELECT ID_empleado, nombre, apellido1, apellido2, extension, email, ID_oficina, ID_jefe, puesto, NOW(),
       CASE WHEN apellido2 = '' THEN 'OBSERVADO_FORMATO' ELSE 'VALIDO' END,
       CASE WHEN apellido2 = '' THEN 'apellido2 con cadena vacia en lugar de NULL' ELSE NULL END
FROM jardineria_ea3.empleado;

TRUNCATE TABLE stg_categoria_producto;
INSERT INTO stg_categoria_producto
SELECT c.Id_Categoria, c.Desc_Categoria, c.descripcion_texto, c.descripcion_html, c.imagen, NOW(),
       CASE
           WHEN COUNT(p.ID_producto) = 0 THEN 'OBSERVADO_SIN_PRODUCTOS'
           WHEN c.descripcion_texto LIKE '2 %' THEN 'OBSERVADO_TEXTO_CORRUPTO'
           ELSE 'VALIDO'
       END,
       CASE
           WHEN COUNT(p.ID_producto) = 0 THEN 'Categoria sin productos asociados en catalogo'
           WHEN c.descripcion_texto LIKE '2 %' THEN 'Texto reemplazado accidentalmente (2 para todo tipo de accion)'
           ELSE NULL
       END
FROM jardineria_ea3.Categoria_producto c
LEFT JOIN jardineria_ea3.producto p ON c.Id_Categoria = p.Categoria
GROUP BY c.Id_Categoria, c.Desc_Categoria, c.descripcion_texto, c.descripcion_html, c.imagen;

TRUNCATE TABLE stg_cliente;
INSERT INTO stg_cliente
SELECT ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto, telefono, fax,
       linea_direccion1, linea_direccion2, ciudad, region, pais, codigo_postal,
       ID_empleado_rep_ventas, limite_credito, NOW(),
       CASE
           WHEN rn > 1 THEN 'OBSERVADO_DUPLICADO'
           WHEN pais IN ('USA','Spain','France','United Kingdom') OR region IS NULL THEN 'OBSERVADO_FORMATO'
           ELSE 'VALIDO'
       END,
       CASE
           WHEN rn > 1 THEN 'Cliente duplicado exacto (Lasas S.A.)'
           WHEN pais IN ('USA','Spain','France','United Kingdom') OR region IS NULL THEN 'Pais en ingles o region nula por estandarizar en EA3'
           ELSE NULL
       END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY nombre_cliente, telefono, ciudad ORDER BY ID_cliente) AS rn
    FROM jardineria_ea3.cliente
) cl;

TRUNCATE TABLE stg_pedido;
INSERT INTO stg_pedido
SELECT ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado, comentarios, ID_cliente, NOW(),
       CASE
           WHEN fecha_esperada < fecha_pedido OR fecha_entrega < fecha_pedido THEN 'OBSERVADO_FECHAS'
           WHEN (estado = 'Entregado' AND fecha_entrega IS NULL)
             OR (estado IN ('Pendiente','Rechazado') AND fecha_entrega IS NOT NULL) THEN 'OBSERVADO_ESTADO'
           WHEN rn > 1 THEN 'OBSERVADO_DUPLICADO'
           ELSE 'VALIDO'
       END,
       CASE
           WHEN fecha_esperada < fecha_pedido OR fecha_entrega < fecha_pedido THEN 'Fecha esperada/entrega anterior a fecha_pedido'
           WHEN estado = 'Entregado' AND fecha_entrega IS NULL THEN 'Entregado sin fecha_entrega'
           WHEN estado IN ('Pendiente','Rechazado') AND fecha_entrega IS NOT NULL THEN CONCAT('Estado ', estado, ' con fecha_entrega no nula')
           WHEN rn > 1 THEN 'Cabecera de pedido repetida (mismo cliente, fechas y estado)'
           ELSE NULL
       END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ID_cliente, fecha_pedido, fecha_esperada, estado ORDER BY ID_pedido) AS rn
    FROM jardineria_ea3.pedido
) pd;

TRUNCATE TABLE stg_producto;
INSERT INTO stg_producto
SELECT ID_producto, CodigoProducto, nombre, Categoria, dimensiones, proveedor, descripcion,
       cantidad_en_stock, precio_venta, precio_proveedor, NOW(),
       CASE WHEN nombre <> TRIM(nombre) OR dimensiones = '' OR descripcion = '' THEN 'OBSERVADO_FORMATO' ELSE 'VALIDO' END,
       CASE WHEN nombre <> TRIM(nombre) OR dimensiones = '' OR descripcion = '' THEN 'Espacios laterales o cadenas vacias por normalizar en EA3' ELSE NULL END
FROM jardineria_ea3.producto;

TRUNCATE TABLE stg_detalle_pedido;
INSERT INTO stg_detalle_pedido
SELECT dp.ID_detalle_pedido, dp.ID_pedido, dp.ID_producto, dp.cantidad, dp.precio_unidad, dp.numero_linea, NOW(),
       CASE
           WHEN dp.rn > 1 THEN 'OBSERVADO_DUPLICADO'
           WHEN p.estado = 'Rechazado' THEN 'EXCLUIR_VENTA_RECHAZADO'
           WHEN dp.precio_unidad <> pr.precio_venta THEN 'OBSERVADO_PRECIO_HISTORICO'
           ELSE 'VALIDO'
       END,
       CASE
           WHEN dp.rn > 1 THEN 'Linea de detalle duplicada exacta para mismo pedido y producto'
           WHEN p.estado = 'Rechazado' THEN 'Linea asociada a pedido Rechazado (excluir de ventas efectivas)'
           WHEN dp.precio_unidad <> pr.precio_venta THEN 'Precio historico difiere del precio actual de catalogo (conservar historico)'
           ELSE NULL
       END
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ID_pedido, ID_producto ORDER BY ID_detalle_pedido) AS rn
    FROM jardineria_ea3.detalle_pedido
) dp
LEFT JOIN jardineria_ea3.pedido p ON dp.ID_pedido = p.ID_pedido
LEFT JOIN jardineria_ea3.producto pr ON dp.ID_producto = pr.ID_producto;

TRUNCATE TABLE stg_pago;
INSERT INTO stg_pago
SELECT ID_pago, ID_cliente, forma_pago, id_transaccion, fecha_pago, total, NOW(),
       'VALIDO', NULL
FROM jardineria_ea3.pago;

UPDATE ctl_ejecucion_staging
SET fecha_fin = NOW(),
    filas_extraidas = (
        (SELECT COUNT(*) FROM stg_oficina) + (SELECT COUNT(*) FROM stg_empleado) +
        (SELECT COUNT(*) FROM stg_categoria_producto) + (SELECT COUNT(*) FROM stg_cliente) +
        (SELECT COUNT(*) FROM stg_pedido) + (SELECT COUNT(*) FROM stg_producto) +
        (SELECT COUNT(*) FROM stg_detalle_pedido) + (SELECT COUNT(*) FROM stg_pago)
    ),
    filas_observadas = (
        (SELECT COUNT(*) FROM stg_oficina WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_empleado WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_categoria_producto WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_cliente WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_pedido WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_producto WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_detalle_pedido WHERE estado_calidad <> 'VALIDO') +
        (SELECT COUNT(*) FROM stg_pago WHERE estado_calidad <> 'VALIDO')
    ),
    estado = 'COMPLETADO_EXITOSO'
WHERE id_lote = @lote_stg;

UPDATE ctl_ejecucion_staging
SET filas_validas = filas_extraidas - filas_observadas
WHERE id_lote = @lote_stg;

-- 3. VERIFICACION DE INTEGRIDAD Y CONCILIACION EN STAGING (816 FILAS = 100%)
SELECT '1. oficina -> stg_oficina' AS tabla, (SELECT COUNT(*) FROM jardineria_ea3.oficina) AS origen, (SELECT COUNT(*) FROM stg_oficina) AS staging UNION ALL
SELECT '2. empleado -> stg_empleado', (SELECT COUNT(*) FROM jardineria_ea3.empleado), (SELECT COUNT(*) FROM stg_empleado) UNION ALL
SELECT '3. Categoria_producto -> stg_categoria_producto', (SELECT COUNT(*) FROM jardineria_ea3.Categoria_producto), (SELECT COUNT(*) FROM stg_categoria_producto) UNION ALL
SELECT '4. cliente -> stg_cliente', (SELECT COUNT(*) FROM jardineria_ea3.cliente), (SELECT COUNT(*) FROM stg_cliente) UNION ALL
SELECT '5. pedido -> stg_pedido', (SELECT COUNT(*) FROM jardineria_ea3.pedido), (SELECT COUNT(*) FROM stg_pedido) UNION ALL
SELECT '6. producto -> stg_producto', (SELECT COUNT(*) FROM jardineria_ea3.producto), (SELECT COUNT(*) FROM stg_producto) UNION ALL
SELECT '7. detalle_pedido -> stg_detalle_pedido', (SELECT COUNT(*) FROM jardineria_ea3.detalle_pedido), (SELECT COUNT(*) FROM stg_detalle_pedido) UNION ALL
SELECT '8. pago -> stg_pago', (SELECT COUNT(*) FROM jardineria_ea3.pago), (SELECT COUNT(*) FROM stg_pago);

SELECT * FROM ctl_ejecucion_staging;
