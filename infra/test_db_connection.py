import os
import pymysql
from dotenv import load_dotenv

def main():
    # Carga el .env desde la raíz del proyecto
    root_dir = os.path.dirname(os.path.dirname(__file__))
    env_path = os.path.join(root_dir, ".env")
    if os.path.exists(env_path):
        load_dotenv(env_path)
    else:
        print(f"[WARN] No se encontró .env en {env_path}. Usaré variables de entorno si existen.")

    host = os.getenv("DB_HOST")
    port = int(os.getenv("DB_PORT", "3306"))
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASS")
    dbname = os.getenv("DB_NAME")

    print(f"[INFO] Conectando como {user}@{host}:{port}/{dbname} ...")

    conn = pymysql.connect(
        host=host,
        port=port,
        user=user,
        password=password,
        database=dbname,
        connect_timeout=10,
    )
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT DATABASE(), CURRENT_USER();")
            print("[OK] IDENTIDAD ->", cur.fetchone())

            for table in ("categorias", "usuarios", "servicios"):
                cur.execute(f"SELECT COUNT(*) FROM {table};")
                print(f"[OK] {table}: {cur.fetchone()[0]}")

            cur.execute("""
                SELECT s.id, s.nombre AS servicio, c.nombre AS categoria, s.precio_base
                FROM servicios s
                JOIN categorias c ON c.id = s.categoria_id
                ORDER BY s.id
                LIMIT 5
            """)
            rows = cur.fetchall()
            print("[OK] Muestra de servicios (hasta 5):")
            for r in rows:
                print("   ", r)
    finally:
        conn.close()
        print("[DONE] Test de conexión completado.")

if __name__ == "__main__":
    main()
