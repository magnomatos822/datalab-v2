#!/bin/sh
# Faz o script parar em caso de erro
set -e

# Adiciona o host do MinIO à configuração do mc
/usr/bin/mc config host add minio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

# Cria os buckets, ignorando se já existirem
/usr/bin/mc mb minio/warehouse --ignore-existing
/usr/bin/mc mb minio/mlflow --ignore-existing
/usr/bin/mc mb minio/airbyte --ignore-existing
/usr/bin/mc mb minio/prefect-flows --ignore-existing

exit 0