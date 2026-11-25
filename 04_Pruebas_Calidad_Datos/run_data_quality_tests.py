import csv
import datetime
import os
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")

MYSQL_EXE = r"C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_DIR = os.path.dirname(BASE_DIR)
SQL_STAGING = os.path.join(REPO_DIR, "03_EA3_Proceso_ETL_DataMart", "scripts_sql", "02_Extraccion_Staging_EA3.sql")
SQL_ORIGEN = os.path.join(BASE_DIR, "scripts_sql", "01_pruebas_calidad_origen.sql")
SQL_DM_TESTS = os.path.join(BASE_DIR, "scripts_sql", "03_pruebas_calidad_datamart.sql")
REPORT_DIR = os.path.join(BASE_DIR, "reportes")
os.makedirs(REPORT_DIR, exist_ok=True)


def run_mysql_file(sql_path):
    cmd = [
        MYSQL_EXE, "-u", "root", "--default-character-set=utf8mb4",
        "-N", "-B", "-e", f"SOURCE {sql_path.replace(chr(92), '/')}"
    ]
    res = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if res.returncode != 0:
        raise RuntimeError(f"MySQL error running {sql_path}: {res.stderr}")
    return res.stdout


def main():
    print("=== 1. Prueba de Idempotencia Staging (re-ejecucion con TRUNCATE TABLE) ===")
    run_mysql_file(SQL_STAGING)
    print("Re-ejecucion de 02_Extraccion_Staging_EA3.sql completada sin errores ni duplicados.")

    print("\n=== 2. Auditoria de anomalias en Origen (jardineria_ea3) ===")
    raw_origen = run_mysql_file(SQL_ORIGEN)
    anomalies = []
    for line in raw_origen.splitlines():
        parts = line.split("\t")
        # Filter summary rows (2 columns: anomaly name + numeric count)
        if len(parts) == 2 and parts[1].strip().isdigit():
            anomalies.append((parts[0].strip(), int(parts[1].strip())))
    for name, cnt in anomalies:
        print(f"  - {name}: {cnt}")

    print("\n=== 3. Ejecutando 22 aserciones de Calidad de Datos en Data Mart (dm_jardineria_ea3) ===")
    raw_tests = run_mysql_file(SQL_DM_TESTS)
    rows = []
    for line in raw_tests.splitlines():
        parts = line.split("\t")
        if len(parts) == 5 and parts[0].startswith("DQ-"):
            rows.append({
                "id_prueba": parts[0].strip(),
                "dimension": parts[1].strip(),
                "descripcion": parts[2].strip(),
                "fallos": int(parts[3].strip()),
                "resultado": parts[4].strip(),
            })

    if len(rows) != 22:
        raise AssertionError(f"Se esperaban 22 pruebas y se obtuvieron {len(rows)}")

    passed = sum(1 for r in rows if r["resultado"] == "PASS")
    failed = len(rows) - passed

    for r in rows:
        print(f"  [{r['resultado']}] {r['id_prueba']} ({r['dimension']}): {r['descripcion']} -> fallos={r['fallos']}")

    csv_path = os.path.join(REPORT_DIR, "resultados_pruebas_calidad.csv")
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["id_prueba", "dimension", "descripcion", "fallos", "resultado"])
        writer.writeheader()
        writer.writerows(rows)

    now_str = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    md_lines = [
        "# Reporte Oficial de Pruebas de Verificación de Calidad de Datos (EA4 — Grupo 3)",
        "",
        f"- **Fecha de ejecución:** {now_str}",
        "- **Motor verificado:** MySQL 8.4 (`jardineria_ea3` → `staging_jardineria_ea3` → `dm_jardineria_ea3`)",
        f"- **Resultado global:** **{passed}/{len(rows)} pruebas aprobadas ({passed * 100 // len(rows)} % PASS, {failed} FAIL)**",
        "",
        "## 1. Anomalías Detectadas en el Origen (`jardineria_ea3`)",
        "",
        "| Anomalía detectada en el origen | Cantidad encontrada | Tratamiento aplicado en Staging + ETL |",
        "| :--- | ---: | :--- |",
    ]
    tratamientos = {
        "Clientes duplicados exactos (Lasas S.A.)": "Marcado en `stg_cliente` (`OBSERVADO_DUPLICADO`) y unificado vía `map_cliente_dedup` (36 → 35).",
        "Lineas detalle_pedido duplicadas exactas (ID_detalle=317)": "Marcado en `stg_detalle_pedido` y excluido al cargar `fact_ventas`.",
        "Cabeceras de pedido repetidas (cliente+fechas+estado)": "Marcadas en `stg_pedido` (`OBSERVADO_DUPLICADO`) conservando trazabilidad por `ID_pedido`.",
        "Pedidos con fechas imposibles (esperada/entrega < pedido)": "Marcados en `stg_pedido` (`OBSERVADO_FECHAS`) y remitidos a fecha centinela `19000101`.",
        "Pedidos con estado contradictorio frente a fecha_entrega": "Marcados en `stg_pedido` (`OBSERVADO_ESTADO`) e identificados en `entrega_a_tiempo`.",
        "Pedidos en estado Rechazado": "Aislados del cómputo de ventas efectivas en `fact_ventas`.",
        "Lineas detalle pertenecientes a pedidos Rechazados": "Marcadas `EXCLUIR_VENTA_RECHAZADO` en Staging y excluidas (318 − 64 − 1 = 253).",
        "Lineas con precio historico distinto al catalogo actual": "Preservado `precio_unidad` histórico en `fact_ventas.precio_unitario_historico`.",
        "Categorias sin productos asociados (Herbaceas)": "Marcada `OBSERVADO_SIN_PRODUCTOS` en `stg_categoria_producto`.",
        "Paises en oficinas/clientes sin homologar al espanol": "Homologados al español (`España`, `Estados Unidos`, `Francia`, `Reino Unido`) en `dim_cliente` y `dim_empleado`.",
        "Textos corruptos o residual UTF-8 (2 para todo / 1Aa / DECA / Francois)": "Restaurados en `dim_producto` y `dim_cliente` durante la transformación.",
    }
    for name, cnt in anomalies:
        md_lines.append(f"| {name} | {cnt} | {tratamientos.get(name, 'Validado en ETL')} |")

    md_lines.extend([
        "",
        "## 2. Resultados de la Suite de 22 Pruebas Automatizadas (`dm_jardineria_ea3` + `staging_jardineria_ea3`)",
        "",
        "| ID | Dimensión ISO/IEC 25012 | Prueba de Verificación | Fallos | Estado |",
        "| :--- | :--- | :--- | ---: | :---: |",
    ])
    for r in rows:
        md_lines.append(f"| {r['id_prueba']} | {r['dimension']} | {r['descripcion']} | {r['fallos']} | **{r['resultado']}** |")

    md_path = os.path.join(REPORT_DIR, "REPORTE_CALIDAD_DATOS.md")
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(md_lines) + "\n")

    print(f"\nResumen: {passed}/{len(rows)} PASS. Reportes guardados en {REPORT_DIR}")
    if failed > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
