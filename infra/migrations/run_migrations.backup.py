import json
import os
import logging

import boto3
import psycopg2

logger = logging.getLogger()
logger.setLevel(logging.INFO)

secrets_client = boto3.client("secretsmanager")

def get_connection():
    secret_name = os.environ["DB_SECRET_NAME"]
    proxy_endpoint = os.environ["DB_PROXY_ENDPOINT"]
    secret = secrets_client.get_secret_value(SecretId=secret_name)
    creds = json.loads(secret["SecretString"])
    return psycopg2.connect(
        host=proxy_endpoint,
        user=creds["username"],
        password=creds["password"],
        dbname=creds.get("dbname", "oficios"),
    )

def run_migrations():
    conn = None
    try:
        conn = get_connection()
        cur = conn.cursor()
        # TODO: Add real migration logic here
        cur.execute("SELECT 1")
        conn.commit()
        cur.close()
        return {
            "statusCode": 200,
            "body": "Migrations executed successfully",
        }
    except Exception as error:
        logger.exception("Error running migrations: %s", error)
        print(f"Failed to run migrations: {error}")
        if conn:
            conn.rollback()
        return {
            "statusCode": 500,
            "body": f"Failed to run migrations: {error}",
        }
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    print(run_migrations())