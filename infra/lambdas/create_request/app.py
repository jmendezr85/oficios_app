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
    body = json.loads(event.get("body", "{}"))
    description = body.get("description")
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO requests (description) VALUES (%s) RETURNING id", (description,)
    )
    request_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return {
        "statusCode": 201,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"id": request_id}),
    }