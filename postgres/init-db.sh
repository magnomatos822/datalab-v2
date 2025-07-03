#!/bin/bash
# This script is executed when the PostgreSQL container is first created.
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE nessie;
    CREATE DATABASE airbyte;
    CREATE DATABASE mlflow_db;
    CREATE DATABASE prefect_server;
EOSQL