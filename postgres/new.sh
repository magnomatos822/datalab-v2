#!/bin/bash

set -e

# The 'psql' command is run with the superuser defined by POSTGRES_USER
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create databases for other services if they don't exist
    CREATE DATABASE nessie;
    CREATE DATABASE prefect_server;
    CREATE DATABASE mlflow_db;
    CREATE DATABASE airbyte;

    -- Grant privileges if needed (optional, as the main user is owner)
    GRANT ALL PRIVILEGES ON DATABASE nessie TO ${POSTGRES_USER};
    GRANT ALL PRIVILEGES ON DATABASE prefect_server TO ${POSTGRES_USER}; -- <-- AND THIS LINE
    GRANT ALL PRIVILEGES ON DATABASE mlflow_db TO ${POSTGRES_USER};
    GRANT ALL PRIVILEGES ON DATABASE airbyte TO ${POSTGRES_USER};
EOSQL