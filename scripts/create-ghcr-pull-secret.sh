#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="${NAMESPACE:-hello-dev}"
SECRET_NAME="${SECRET_NAME:-ghcr-creds}"
DOCKER_SERVER="${DOCKER_SERVER:-ghcr.io}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not installed." >&2
  exit 1
fi

if [[ -z "${GITHUB_USERNAME:-}" ]]; then
  echo "Set GITHUB_USERNAME before running this script." >&2
  exit 1
fi

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "Set GITHUB_TOKEN before running this script." >&2
  exit 1
fi

kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret docker-registry "${SECRET_NAME}" \
  --docker-server="${DOCKER_SERVER}" \
  --docker-username="${GITHUB_USERNAME}" \
  --docker-password="${GITHUB_TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Created or updated image pull secret ${SECRET_NAME} in namespace ${NAMESPACE}"
