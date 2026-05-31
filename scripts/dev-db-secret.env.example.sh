#!/usr/bin/env bash

# Kubernetes namespace where the PostgreSQL secret should be created.
export DEV_DB_NAMESPACE="dev-db"

# Name of the Kubernetes secret referenced by the dev-db StatefulSet.
export DEV_DB_SECRET_NAME="dev-db-postgres-secret"

# Initial database created by the PostgreSQL container on first startup.
export DEV_DB_POSTGRES_DB="postgres"

# Initial PostgreSQL user created by the PostgreSQL container on first startup.
export DEV_DB_POSTGRES_USER="postgres"

# Initial PostgreSQL password. Replace this before running the script.
export DEV_DB_POSTGRES_PASSWORD="replace-me"
