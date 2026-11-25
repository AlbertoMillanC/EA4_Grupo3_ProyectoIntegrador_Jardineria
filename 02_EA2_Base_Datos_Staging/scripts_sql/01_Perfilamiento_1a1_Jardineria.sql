-- ============================================================================
-- EVIDENCIA DE APRENDIZAJE 2 (CORREGIDA): PERFILAMIENTO 1 A 1 DE DATOS ORIGEN
-- Curso: Bases de Datos II (PREICA2602B020061) - Docente: Mg. Carolina Marquez
-- Estudiante: Carlos Alberto Millan Castano - Grupo 3
-- Motor: MySQL 8.4 (MySQL Workbench)
-- ============================================================================

USE jardineria;

-- ----------------------------------------------------------------------------
-- PASO 1: DICCIONARIO DE ESTRUCTURA, TIPOS DE DATOS Y REGLAS NOT NULL
-- ----------------------------------------------------------------------------
SELECT 
    TABLE_NAME AS tabla,
    COLUMN_NAME AS columna,
    DATA_TYPE AS tipo_dato,
    CHARACTER_MAXIMUM_LENGTH AS longitud_max_definida,
    IS_NULLABLE AS acepta_nulos,
    COLUMN_KEY AS tipo_llave
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'jardineria'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ----------------------------------------------------------------------------
-- PASO 2: PERFILAMIENTO COLUMNA POR COLUMNA (UNO A UNO) EN LAS 8 TABLAS
-- Total de filas, registros con datos, nulos reales, valores unicos y longitudes
-- ----------------------------------------------------------------------------

-- Perfilamiento tabla: categoria_producto
SELECT 'categoria_producto' AS tabla, 'Id_Categoria' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`Id_Categoria`) AS registros_con_datos, COUNT(*) - COUNT(`Id_Categoria`) AS nulos_reales, COUNT(DISTINCT `Id_Categoria`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`Id_Categoria`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`Id_Categoria`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`Id_Categoria`)), 2) AS CHAR) AS long_media FROM jardineria.`categoria_producto`
UNION ALL
SELECT 'categoria_producto' AS tabla, 'Desc_Categoria' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`Desc_Categoria`) AS registros_con_datos, COUNT(*) - COUNT(`Desc_Categoria`) AS nulos_reales, COUNT(DISTINCT `Desc_Categoria`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`Desc_Categoria`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`Desc_Categoria`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`Desc_Categoria`)), 2) AS CHAR) AS long_media FROM jardineria.`categoria_producto`
UNION ALL
SELECT 'categoria_producto' AS tabla, 'descripcion_texto' AS columna, 'text' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`descripcion_texto`) AS registros_con_datos, COUNT(*) - COUNT(`descripcion_texto`) AS nulos_reales, COUNT(DISTINCT `descripcion_texto`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`descripcion_texto`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`descripcion_texto`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`descripcion_texto`)), 2) AS CHAR) AS long_media FROM jardineria.`categoria_producto`
UNION ALL
SELECT 'categoria_producto' AS tabla, 'descripcion_html' AS columna, 'text' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`descripcion_html`) AS registros_con_datos, COUNT(*) - COUNT(`descripcion_html`) AS nulos_reales, COUNT(DISTINCT `descripcion_html`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`descripcion_html`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`descripcion_html`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`descripcion_html`)), 2) AS CHAR) AS long_media FROM jardineria.`categoria_producto`
UNION ALL
SELECT 'categoria_producto' AS tabla, 'imagen' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`imagen`) AS registros_con_datos, COUNT(*) - COUNT(`imagen`) AS nulos_reales, COUNT(DISTINCT `imagen`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`imagen`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`imagen`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`imagen`)), 2) AS CHAR) AS long_media FROM jardineria.`categoria_producto`;

-- Perfilamiento tabla: cliente
SELECT 'cliente' AS tabla, 'ID_cliente' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_cliente`) AS registros_con_datos, COUNT(*) - COUNT(`ID_cliente`) AS nulos_reales, COUNT(DISTINCT `ID_cliente`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_cliente`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_cliente`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_cliente`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'nombre_cliente' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`nombre_cliente`) AS registros_con_datos, COUNT(*) - COUNT(`nombre_cliente`) AS nulos_reales, COUNT(DISTINCT `nombre_cliente`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`nombre_cliente`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`nombre_cliente`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`nombre_cliente`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'nombre_contacto' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`nombre_contacto`) AS registros_con_datos, COUNT(*) - COUNT(`nombre_contacto`) AS nulos_reales, COUNT(DISTINCT `nombre_contacto`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`nombre_contacto`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`nombre_contacto`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`nombre_contacto`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'apellido_contacto' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`apellido_contacto`) AS registros_con_datos, COUNT(*) - COUNT(`apellido_contacto`) AS nulos_reales, COUNT(DISTINCT `apellido_contacto`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`apellido_contacto`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`apellido_contacto`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`apellido_contacto`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'telefono' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`telefono`) AS registros_con_datos, COUNT(*) - COUNT(`telefono`) AS nulos_reales, COUNT(DISTINCT `telefono`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`telefono`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`telefono`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`telefono`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'fax' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`fax`) AS registros_con_datos, COUNT(*) - COUNT(`fax`) AS nulos_reales, COUNT(DISTINCT `fax`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`fax`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`fax`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`fax`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'linea_direccion1' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`linea_direccion1`) AS registros_con_datos, COUNT(*) - COUNT(`linea_direccion1`) AS nulos_reales, COUNT(DISTINCT `linea_direccion1`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`linea_direccion1`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`linea_direccion1`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`linea_direccion1`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'linea_direccion2' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`linea_direccion2`) AS registros_con_datos, COUNT(*) - COUNT(`linea_direccion2`) AS nulos_reales, COUNT(DISTINCT `linea_direccion2`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`linea_direccion2`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`linea_direccion2`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`linea_direccion2`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'ciudad' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ciudad`) AS registros_con_datos, COUNT(*) - COUNT(`ciudad`) AS nulos_reales, COUNT(DISTINCT `ciudad`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ciudad`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ciudad`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ciudad`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'region' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`region`) AS registros_con_datos, COUNT(*) - COUNT(`region`) AS nulos_reales, COUNT(DISTINCT `region`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`region`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`region`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`region`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'pais' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`pais`) AS registros_con_datos, COUNT(*) - COUNT(`pais`) AS nulos_reales, COUNT(DISTINCT `pais`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`pais`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`pais`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`pais`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'codigo_postal' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`codigo_postal`) AS registros_con_datos, COUNT(*) - COUNT(`codigo_postal`) AS nulos_reales, COUNT(DISTINCT `codigo_postal`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`codigo_postal`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`codigo_postal`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`codigo_postal`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'ID_empleado_rep_ventas' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_empleado_rep_ventas`) AS registros_con_datos, COUNT(*) - COUNT(`ID_empleado_rep_ventas`) AS nulos_reales, COUNT(DISTINCT `ID_empleado_rep_ventas`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_empleado_rep_ventas`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_empleado_rep_ventas`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_empleado_rep_ventas`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`
UNION ALL
SELECT 'cliente' AS tabla, 'limite_credito' AS columna, 'decimal' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`limite_credito`) AS registros_con_datos, COUNT(*) - COUNT(`limite_credito`) AS nulos_reales, COUNT(DISTINCT `limite_credito`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`limite_credito`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`limite_credito`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`limite_credito`)), 2) AS CHAR) AS long_media FROM jardineria.`cliente`;

-- Perfilamiento tabla: detalle_pedido
SELECT 'detalle_pedido' AS tabla, 'ID_pedido' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_pedido`) AS registros_con_datos, COUNT(*) - COUNT(`ID_pedido`) AS nulos_reales, COUNT(DISTINCT `ID_pedido`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_pedido`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_pedido`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_pedido`)), 2) AS CHAR) AS long_media FROM jardineria.`detalle_pedido`
UNION ALL
SELECT 'detalle_pedido' AS tabla, 'ID_producto' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_producto`) AS registros_con_datos, COUNT(*) - COUNT(`ID_producto`) AS nulos_reales, COUNT(DISTINCT `ID_producto`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_producto`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_producto`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_producto`)), 2) AS CHAR) AS long_media FROM jardineria.`detalle_pedido`
UNION ALL
SELECT 'detalle_pedido' AS tabla, 'cantidad' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`cantidad`) AS registros_con_datos, COUNT(*) - COUNT(`cantidad`) AS nulos_reales, COUNT(DISTINCT `cantidad`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`cantidad`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`cantidad`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`cantidad`)), 2) AS CHAR) AS long_media FROM jardineria.`detalle_pedido`
UNION ALL
SELECT 'detalle_pedido' AS tabla, 'precio_unidad' AS columna, 'decimal' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`precio_unidad`) AS registros_con_datos, COUNT(*) - COUNT(`precio_unidad`) AS nulos_reales, COUNT(DISTINCT `precio_unidad`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`precio_unidad`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`precio_unidad`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`precio_unidad`)), 2) AS CHAR) AS long_media FROM jardineria.`detalle_pedido`
UNION ALL
SELECT 'detalle_pedido' AS tabla, 'numero_linea' AS columna, 'smallint' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`numero_linea`) AS registros_con_datos, COUNT(*) - COUNT(`numero_linea`) AS nulos_reales, COUNT(DISTINCT `numero_linea`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`numero_linea`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`numero_linea`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`numero_linea`)), 2) AS CHAR) AS long_media FROM jardineria.`detalle_pedido`;

-- Perfilamiento tabla: empleado
SELECT 'empleado' AS tabla, 'ID_empleado' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_empleado`) AS registros_con_datos, COUNT(*) - COUNT(`ID_empleado`) AS nulos_reales, COUNT(DISTINCT `ID_empleado`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_empleado`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_empleado`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_empleado`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'nombre' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`nombre`) AS registros_con_datos, COUNT(*) - COUNT(`nombre`) AS nulos_reales, COUNT(DISTINCT `nombre`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`nombre`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`nombre`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`nombre`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'apellido1' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`apellido1`) AS registros_con_datos, COUNT(*) - COUNT(`apellido1`) AS nulos_reales, COUNT(DISTINCT `apellido1`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`apellido1`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`apellido1`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`apellido1`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'apellido2' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`apellido2`) AS registros_con_datos, COUNT(*) - COUNT(`apellido2`) AS nulos_reales, COUNT(DISTINCT `apellido2`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`apellido2`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`apellido2`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`apellido2`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'extension' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`extension`) AS registros_con_datos, COUNT(*) - COUNT(`extension`) AS nulos_reales, COUNT(DISTINCT `extension`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`extension`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`extension`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`extension`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'email' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`email`) AS registros_con_datos, COUNT(*) - COUNT(`email`) AS nulos_reales, COUNT(DISTINCT `email`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`email`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`email`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`email`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'ID_oficina' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_oficina`) AS registros_con_datos, COUNT(*) - COUNT(`ID_oficina`) AS nulos_reales, COUNT(DISTINCT `ID_oficina`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_oficina`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_oficina`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_oficina`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'ID_jefe' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_jefe`) AS registros_con_datos, COUNT(*) - COUNT(`ID_jefe`) AS nulos_reales, COUNT(DISTINCT `ID_jefe`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_jefe`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_jefe`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_jefe`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`
UNION ALL
SELECT 'empleado' AS tabla, 'puesto' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`puesto`) AS registros_con_datos, COUNT(*) - COUNT(`puesto`) AS nulos_reales, COUNT(DISTINCT `puesto`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`puesto`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`puesto`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`puesto`)), 2) AS CHAR) AS long_media FROM jardineria.`empleado`;

-- Perfilamiento tabla: oficina
SELECT 'oficina' AS tabla, 'ID_oficina' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_oficina`) AS registros_con_datos, COUNT(*) - COUNT(`ID_oficina`) AS nulos_reales, COUNT(DISTINCT `ID_oficina`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_oficina`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_oficina`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_oficina`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'Descripcion' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`Descripcion`) AS registros_con_datos, COUNT(*) - COUNT(`Descripcion`) AS nulos_reales, COUNT(DISTINCT `Descripcion`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`Descripcion`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`Descripcion`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`Descripcion`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'ciudad' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ciudad`) AS registros_con_datos, COUNT(*) - COUNT(`ciudad`) AS nulos_reales, COUNT(DISTINCT `ciudad`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ciudad`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ciudad`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ciudad`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'pais' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`pais`) AS registros_con_datos, COUNT(*) - COUNT(`pais`) AS nulos_reales, COUNT(DISTINCT `pais`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`pais`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`pais`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`pais`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'region' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`region`) AS registros_con_datos, COUNT(*) - COUNT(`region`) AS nulos_reales, COUNT(DISTINCT `region`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`region`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`region`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`region`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'codigo_postal' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`codigo_postal`) AS registros_con_datos, COUNT(*) - COUNT(`codigo_postal`) AS nulos_reales, COUNT(DISTINCT `codigo_postal`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`codigo_postal`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`codigo_postal`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`codigo_postal`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'telefono' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`telefono`) AS registros_con_datos, COUNT(*) - COUNT(`telefono`) AS nulos_reales, COUNT(DISTINCT `telefono`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`telefono`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`telefono`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`telefono`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'linea_direccion1' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`linea_direccion1`) AS registros_con_datos, COUNT(*) - COUNT(`linea_direccion1`) AS nulos_reales, COUNT(DISTINCT `linea_direccion1`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`linea_direccion1`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`linea_direccion1`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`linea_direccion1`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`
UNION ALL
SELECT 'oficina' AS tabla, 'linea_direccion2' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`linea_direccion2`) AS registros_con_datos, COUNT(*) - COUNT(`linea_direccion2`) AS nulos_reales, COUNT(DISTINCT `linea_direccion2`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`linea_direccion2`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`linea_direccion2`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`linea_direccion2`)), 2) AS CHAR) AS long_media FROM jardineria.`oficina`;

-- Perfilamiento tabla: pago
SELECT 'pago' AS tabla, 'ID_cliente' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_cliente`) AS registros_con_datos, COUNT(*) - COUNT(`ID_cliente`) AS nulos_reales, COUNT(DISTINCT `ID_cliente`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_cliente`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_cliente`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_cliente`)), 2) AS CHAR) AS long_media FROM jardineria.`pago`
UNION ALL
SELECT 'pago' AS tabla, 'forma_pago' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`forma_pago`) AS registros_con_datos, COUNT(*) - COUNT(`forma_pago`) AS nulos_reales, COUNT(DISTINCT `forma_pago`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`forma_pago`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`forma_pago`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`forma_pago`)), 2) AS CHAR) AS long_media FROM jardineria.`pago`
UNION ALL
SELECT 'pago' AS tabla, 'id_transaccion' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`id_transaccion`) AS registros_con_datos, COUNT(*) - COUNT(`id_transaccion`) AS nulos_reales, COUNT(DISTINCT `id_transaccion`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`id_transaccion`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`id_transaccion`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`id_transaccion`)), 2) AS CHAR) AS long_media FROM jardineria.`pago`
UNION ALL
SELECT 'pago' AS tabla, 'fecha_pago' AS columna, 'date' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`fecha_pago`) AS registros_con_datos, COUNT(*) - COUNT(`fecha_pago`) AS nulos_reales, COUNT(DISTINCT `fecha_pago`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`fecha_pago`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`fecha_pago`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`fecha_pago`)), 2) AS CHAR) AS long_media FROM jardineria.`pago`
UNION ALL
SELECT 'pago' AS tabla, 'total' AS columna, 'decimal' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`total`) AS registros_con_datos, COUNT(*) - COUNT(`total`) AS nulos_reales, COUNT(DISTINCT `total`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`total`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`total`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`total`)), 2) AS CHAR) AS long_media FROM jardineria.`pago`;

-- Perfilamiento tabla: pedido
SELECT 'pedido' AS tabla, 'ID_pedido' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_pedido`) AS registros_con_datos, COUNT(*) - COUNT(`ID_pedido`) AS nulos_reales, COUNT(DISTINCT `ID_pedido`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_pedido`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_pedido`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_pedido`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`
UNION ALL
SELECT 'pedido' AS tabla, 'fecha_pedido' AS columna, 'date' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`fecha_pedido`) AS registros_con_datos, COUNT(*) - COUNT(`fecha_pedido`) AS nulos_reales, COUNT(DISTINCT `fecha_pedido`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`fecha_pedido`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`fecha_pedido`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`fecha_pedido`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`
UNION ALL
SELECT 'pedido' AS tabla, 'fecha_esperada' AS columna, 'date' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`fecha_esperada`) AS registros_con_datos, COUNT(*) - COUNT(`fecha_esperada`) AS nulos_reales, COUNT(DISTINCT `fecha_esperada`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`fecha_esperada`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`fecha_esperada`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`fecha_esperada`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`
UNION ALL
SELECT 'pedido' AS tabla, 'fecha_entrega' AS columna, 'date' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`fecha_entrega`) AS registros_con_datos, COUNT(*) - COUNT(`fecha_entrega`) AS nulos_reales, COUNT(DISTINCT `fecha_entrega`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`fecha_entrega`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`fecha_entrega`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`fecha_entrega`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`
UNION ALL
SELECT 'pedido' AS tabla, 'estado' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`estado`) AS registros_con_datos, COUNT(*) - COUNT(`estado`) AS nulos_reales, COUNT(DISTINCT `estado`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`estado`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`estado`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`estado`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`
UNION ALL
SELECT 'pedido' AS tabla, 'comentarios' AS columna, 'text' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`comentarios`) AS registros_con_datos, COUNT(*) - COUNT(`comentarios`) AS nulos_reales, COUNT(DISTINCT `comentarios`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`comentarios`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`comentarios`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`comentarios`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`
UNION ALL
SELECT 'pedido' AS tabla, 'ID_cliente' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_cliente`) AS registros_con_datos, COUNT(*) - COUNT(`ID_cliente`) AS nulos_reales, COUNT(DISTINCT `ID_cliente`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_cliente`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_cliente`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_cliente`)), 2) AS CHAR) AS long_media FROM jardineria.`pedido`;

-- Perfilamiento tabla: producto
SELECT 'producto' AS tabla, 'ID_producto' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`ID_producto`) AS registros_con_datos, COUNT(*) - COUNT(`ID_producto`) AS nulos_reales, COUNT(DISTINCT `ID_producto`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`ID_producto`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`ID_producto`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`ID_producto`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'nombre' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`nombre`) AS registros_con_datos, COUNT(*) - COUNT(`nombre`) AS nulos_reales, COUNT(DISTINCT `nombre`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`nombre`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`nombre`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`nombre`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'Categoria' AS columna, 'int' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`Categoria`) AS registros_con_datos, COUNT(*) - COUNT(`Categoria`) AS nulos_reales, COUNT(DISTINCT `Categoria`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`Categoria`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`Categoria`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`Categoria`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'dimensiones' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`dimensiones`) AS registros_con_datos, COUNT(*) - COUNT(`dimensiones`) AS nulos_reales, COUNT(DISTINCT `dimensiones`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`dimensiones`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`dimensiones`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`dimensiones`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'proveedor' AS columna, 'varchar' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`proveedor`) AS registros_con_datos, COUNT(*) - COUNT(`proveedor`) AS nulos_reales, COUNT(DISTINCT `proveedor`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`proveedor`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`proveedor`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`proveedor`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'descripcion' AS columna, 'text' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`descripcion`) AS registros_con_datos, COUNT(*) - COUNT(`descripcion`) AS nulos_reales, COUNT(DISTINCT `descripcion`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`descripcion`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`descripcion`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`descripcion`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'cantidad_en_stock' AS columna, 'smallint' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`cantidad_en_stock`) AS registros_con_datos, COUNT(*) - COUNT(`cantidad_en_stock`) AS nulos_reales, COUNT(DISTINCT `cantidad_en_stock`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`cantidad_en_stock`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`cantidad_en_stock`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`cantidad_en_stock`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'precio_venta' AS columna, 'decimal' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`precio_venta`) AS registros_con_datos, COUNT(*) - COUNT(`precio_venta`) AS nulos_reales, COUNT(DISTINCT `precio_venta`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`precio_venta`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`precio_venta`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`precio_venta`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`
UNION ALL
SELECT 'producto' AS tabla, 'precio_proveedor' AS columna, 'decimal' AS tipo_dato, COUNT(*) AS total_filas, COUNT(`precio_proveedor`) AS registros_con_datos, COUNT(*) - COUNT(`precio_proveedor`) AS nulos_reales, COUNT(DISTINCT `precio_proveedor`) AS valores_unicos, CAST(MIN(CHAR_LENGTH(`precio_proveedor`)) AS CHAR) AS min_longitud, CAST(MAX(CHAR_LENGTH(`precio_proveedor`)) AS CHAR) AS max_longitud, CAST(ROUND(AVG(CHAR_LENGTH(`precio_proveedor`)), 2) AS CHAR) AS long_media FROM jardineria.`producto`;

-- ----------------------------------------------------------------------------
-- PASO 3: PERFILAMIENTO DE ANOMALIAS DE NEGOCIO E INTEGRIDAD REFERENCIAL
-- ----------------------------------------------------------------------------

-- 3A. Pedidos huerfanos (ID_cliente = 38 no existe en cliente)
SELECT p.ID_pedido, p.ID_cliente AS cliente_inexistente, p.estado 
FROM pedido p LEFT JOIN cliente c ON p.ID_cliente = c.ID_cliente 
WHERE c.ID_cliente IS NULL;

-- 3B. Pagos huerfanos (ID_cliente = 38 no existe en cliente)
SELECT pg.id_transaccion, pg.ID_cliente AS cliente_inexistente, pg.total 
FROM pago pg LEFT JOIN cliente c ON pg.ID_cliente = c.ID_cliente 
WHERE c.ID_cliente IS NULL;

-- 3C. Detalles de pedido huerfanos (pedidos 116-128 no existen en pedido)
SELECT dp.ID_pedido AS pedido_inexistente, dp.ID_producto, dp.cantidad 
FROM detalle_pedido dp LEFT JOIN pedido p ON dp.ID_pedido = p.ID_pedido 
WHERE p.ID_pedido IS NULL;

-- 3D. Clientes duplicados (Lasas S.A.)
SELECT nombre_cliente, telefono, ciudad, COUNT(*) AS veces
FROM cliente
GROUP BY nombre_cliente, telefono, ciudad
HAVING COUNT(*) > 1;

-- 3E. Pedidos duplicados
SELECT ID_cliente, fecha_pedido, fecha_esperada, estado, COUNT(*) AS veces
FROM pedido
GROUP BY ID_cliente, fecha_pedido, fecha_esperada, estado
HAVING COUNT(*) > 1;

-- 3F. Fechas imposibles (fecha_esperada o fecha_entrega menor a fecha_pedido)
SELECT ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega, estado
FROM pedido
WHERE fecha_esperada < fecha_pedido OR fecha_entrega < fecha_pedido;

-- 3G. Estados contradictorios
SELECT ID_pedido, fecha_pedido, fecha_entrega, estado
FROM pedido
WHERE (estado = 'Entregado' AND fecha_entrega IS NULL)
   OR (estado IN ('Pendiente', 'Rechazado') AND fecha_entrega IS NOT NULL);
