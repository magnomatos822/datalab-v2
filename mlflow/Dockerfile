    # mlflow/Dockerfile
    FROM python:3.9-slim

    RUN pip install --no-cache-dir mlflow boto3 psycopg2-binary

    ENTRYPOINT ["mlflow", "server"]
