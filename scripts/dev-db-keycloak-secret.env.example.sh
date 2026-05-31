#!/usr/bin/env bash

# Kubernetes namespace where the PostgreSQL secret should be created.
export DEV_DB_NAMESPACE="keycloak"

# Name of the Kubernetes secret referenced by the Keycloak Deployment.
export DEV_DB_SECRET_NAME="dev-db-keycloak-postgres-secret"

# PostgreSQL database used by Keycloak.
export DEV_DB_POSTGRES_DB="postgres"

# PostgreSQL user used by Keycloak.
export DEV_DB_POSTGRES_USER="keycloak"

# PostgreSQL schema used by Keycloak.
export DEV_DB_POSTGRES_SCHEMA="keycloak"

# PostgreSQL password for the Keycloak user. Replace this before running the script.
export DEV_DB_POSTGRES_PASSWORD="replace-me"

# Initial Keycloak admin user created on first startup.
export KEYCLOAK_BOOTSTRAP_ADMIN_USERNAME="admin"

# Initial Keycloak admin password. Replace this before running the script.
export KEYCLOAK_BOOTSTRAP_ADMIN_PASSWORD="replace-me"
