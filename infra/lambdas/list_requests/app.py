import json
import os

import boto3
import psycopg2


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

def lambda_handler(event, context):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT id, description FROM requests")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    requests = [{"id": r[0], "description": r[1]} for r in rows]
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(requests),
    }