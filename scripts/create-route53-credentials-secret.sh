#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${CERT_MANAGER_NAMESPACE:-cert-manager}"
SECRET_NAME="${ROUTE53_SECRET_NAME:-route53-credentials}"

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
require_env AWS_ACCESS_KEY_ID
require_env AWS_SECRET_ACCESS_KEY

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-literal=access-key-id="${AWS_ACCESS_KEY_ID}" \
  --from-literal=secret-access-key="${AWS_SECRET_ACCESS_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Created or updated ${NAMESPACE}/${SECRET_NAME}."
