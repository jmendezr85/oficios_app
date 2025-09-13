import os
import json
import sys
import glob
import traceback
from pathlib import Path

import boto3
from botocore.exceptions import BotoCoreError, ClientError


# ----------------------------
# Utilidades de logging/errores
# ----------------------------
def _fail(prefix: str, exc: Exception) -> None:
    print(f"[ERROR] {prefix}: {exc}")
    traceback.print_exc()
    sys.exit(1)


# ----------------------------
# Sesión boto3 con región fija
# ----------------------------
def get_boto3_session():
    """
    Crea una sesión de boto3 con región garantizada.
    Respeta AWS_PROFILE si está definido.
    """
    region = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION") or "us-east-2"
    profile = os.getenv("AWS_PROFILE")
    try:
        if profile:
            return boto3.session.Session(profile_name=profile, region_name=region)
        return boto3.session.Session(region_name=region)
    except Exception as e:
        _fail("Creando sesión boto3", e)


# ----------------------------
# Lectura del Secret (JSON)
# ----------------------------
def _get_secret_id_from_env() -> str:
    return (
        os.getenv("DB_SECRET_NAME")
        or os.getenv("DB_SECRET_ID")
        or "oficiosapp/db-credentials"
    )


def load_db_secret(secret_id: str) -> dict:
    """
    Lee el secret desde Secrets Manager (maneja BOM y valida JSON).
    Devuelve dict con: user, password, host, port, dbname, region
    """
    session = get_boto3_session()
    client = session.client("secretsmanager")

    try:
        resp = client.get_secret_value(SecretId=secret_id)
    except (BotoCoreError, ClientError) as e:
        _fail("Leyendo Secret en Secrets Manager", e)

    secret_str = resp.get("SecretString")
    if not secret_str and resp.get("SecretBinary"):
        sec = resp["SecretBinary"]
        if isinstance(sec, (bytes, bytearray)):
            secret_str = sec.decode("utf-8", errors="replace")
        else:
            secret_str = str(sec)

    if isinstance(secret_str, (bytes, bytearray)):
        secret_str = secret_str.decode("utf-8", errors="replace")

    # Elimina posible BOM y espacios extra
    secret_str = (secret_str or "").lstrip("\ufeff").strip()

    try:
        data = json.loads(secret_str)
    except json.JSONDecodeError as e:
        print("[DEBUG] SecretString recibido (para inspección):")
        print(secret_str)
        _fail("SecretString no es JSON válido (revisa comillas/BOM)", e)

    required = ["username", "password", "host", "port", "dbname"]
    missing = [k for k in required if k not in data]
    if missing:
        print("[DEBUG] Claves presentes en Secret:", list(data.keys()))
        _fail(f"Faltan campos en el secret: {missing}", Exception("Campos incompletos"))

    try:
        port = int(data["port"])
    except Exception:
        port = 3306

    return {
        "user": data["username"],
        "password": data["password"],
        "host": data["host"],
        "port": port,
        "dbname": data["dbname"],
        "region": session.region_name,
    }


# ----------------------------
# Conexión y creación de DB
# ----------------------------
def ensure_database(creds: dict) -> None:
    """
    Autentica SIN database, crea la DB si no existe y verifica conexión a la DB.
    Requiere: pip install pymysql
    """
    try:
        import pymysql  # noqa: F401
    except ImportError as e:
        print("[INFO] Falta dependencia PyMySQL. Instala con: pip install pymysql")
        _fail("Importando PyMySQL", e)

    import pymysql

    # 1) Autenticar SIN seleccionar database
    try:
        conn = pymysql.connect(
            host=creds["host"],
            user=creds["user"],
            password=creds["password"],
            port=creds["port"],
            connect_timeout=10,
        )
    except Exception as e:
        _fail("Autenticando en MySQL (sin DB)", e)

    try:
        with conn.cursor() as cur:
            cur.execute(
                f"CREATE DATABASE IF NOT EXISTS `{creds['dbname']}` "
                f"CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
            )
            print(f"[OK] Base creada/verificada: {creds['dbname']}")
    finally:
        conn.close()

    # 2) Conectar YA con la DB y probar
    try:
        conn = pymysql.connect(
            host=creds["host"],
            user=creds["user"],
            password=creds["password"],
            database=creds["dbname"],
            port=creds["port"],
            connect_timeout=10,
        )
        with conn.cursor() as cur:
            cur.execute("SELECT DATABASE(), CURRENT_USER();")
            print("[OK] SELECT DATABASE(), CURRENT_USER() ->", cur.fetchone())
    except Exception as e:
        _fail("Conectando a la DB seleccionada", e)
    finally:
        try:
            conn.close()
        except Exception:
            pass


# ----------------------------
# Ejecución de .sql (opcional)
# ----------------------------
def run_sql_folder(creds: dict, folder: Path = None) -> None:
    """
    Busca y ejecuta archivos .sql ordenados por nombre.
    Limpia comentarios (-- y /* */) antes de dividir por ';' para evitar splits falsos.
    """
    try:
        import pymysql  # noqa: F401
    except ImportError:
        print("[INFO] Para ejecutar .sql instala: pip install pymysql")
        return

    import re
    import pymysql

    if folder is None:
        folder = Path(__file__).with_name("sql")  # infra/migrations/sql

    if not folder.exists():
        print(f"[INFO] Carpeta de migraciones SQL no encontrada: {folder}. Omitiendo.")
        return

    sql_files = sorted(folder.glob("*.sql"))
    if not sql_files:
        print(f"[INFO] No hay archivos .sql en {folder}. Nada que aplicar.")
        return

    print(f"[INFO] Ejecutando {len(sql_files)} archivo(s) .sql en {folder} ...")

    conn = None
    try:
        conn = pymysql.connect(
            host=creds["host"],
            user=creds["user"],
            password=creds["password"],
            database=creds["dbname"],
            port=creds["port"],
            autocommit=True,
        )
        with conn.cursor() as cur:
            for path in sql_files:
                print(f"[MIG] {path.name}")
                raw = path.read_text(encoding="utf-8")

                # 1) Eliminar comentarios de bloque /* ... */ (incluye saltos de línea)
                no_block = re.sub(r"/\*.*?\*/", "", raw, flags=re.S)

                # 2) Eliminar comentarios de línea -- hasta fin de línea
                lines = []
                for line in no_block.splitlines():
                    # Si la línea tiene '--', corta ahí
                    if "--" in line:
                        line = line.split("--", 1)[0]
                    lines.append(line)
                cleaned = "\n".join(lines)

                # 3) Dividir por ';' y ejecutar cada sentencia
                statements = [s.strip() for s in cleaned.split(";") if s.strip()]
                for stmt in statements:
                    cur.execute(stmt)
        print("[OK] Migraciones SQL aplicadas.")
    except Exception as e:
        _fail("Ejecutando migraciones SQL", e)
    finally:
        try:
            if conn:
                conn.close()
        except Exception:
            pass
        
def verify_app_user(creds: dict) -> None:
    """
    Se conecta con el usuario de la APP (no admin) y muestra:
    - quién soy (CURRENT_USER)
    - conteos de tablas sembradas
    """
    import pymysql
    import os

    app_user = os.getenv("APP_DB_USER", "oficios_app")
    app_pass = os.getenv("APP_DB_PASS", "Oficios#2025!App")

    conn = pymysql.connect(
        host=creds["host"],
        user=app_user,
        password=app_pass,
        database=creds["dbname"],
        port=creds["port"],
        connect_timeout=10,
    )
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT DATABASE(), CURRENT_USER();")
            print("[OK] APP USER ->", cur.fetchone())

            cur.execute("SELECT COUNT(*) FROM categorias;")
            print("[OK] categorias:", cur.fetchone()[0])

            cur.execute("SELECT COUNT(*) FROM usuarios;")
            print("[OK] usuarios:", cur.fetchone()[0])

            cur.execute("SELECT COUNT(*) FROM servicios;")
            print("[OK] servicios:", cur.fetchone()[0])
    finally:
        conn.close()


def main() -> None:
    secret_id = _get_secret_id_from_env()
    creds = load_db_secret(secret_id)

    print(f"[OK] Región: {creds['region']}  |  Secret: {secret_id}")
    print(
        f"[OK] Conectando a {creds['host']}:{creds['port']}/{creds['dbname']} "
        f"como {creds['user']}"
    )

    # Crea/verifica DB y prueba conexión
    ensure_database(creds)

    # Ejecuta .sql si existen (infra/migrations/sql/*.sql)
    run_sql_folder(creds)

    print("[DONE] Migraciones finalizadas.")
    
    # Verificar login con usuario de aplicación y conteos
    verify_app_user(creds)


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception as e:
        print(f"Failed to run migrations: {e}")
        traceback.print_exc()
        sys.exit(1)