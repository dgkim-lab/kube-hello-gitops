#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${DEV_DB_NAMESPACE:-dev-db}"
SECRET_NAME="${DEV_DB_SECRET_NAME:-dev-db-postgres-secret}"
POSTGRES_DB="${DEV_DB_POSTGRES_DB:-postgres}"
POSTGRES_USER="${DEV_DB_POSTGRES_USER:-postgres}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_env() {
  if [[ -z "${!1:-}" ]]; then
    echo "Missing required environment variable: $1" >&2
    exit 1
  fi
}

need kubectl
require_env DEV_DB_POSTGRES_PASSWORD

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-literal=POSTGRES_DB="${POSTGRES_DB}" \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${DEV_DB_POSTGRES_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Created or updated ${NAMESPACE}/${SECRET_NAME}."
