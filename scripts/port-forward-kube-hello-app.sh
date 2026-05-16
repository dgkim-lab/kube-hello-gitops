#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="${NAMESPACE:-hello-dev}"
SERVICE_NAME="${SERVICE_NAME:-kube-hello-app}"
LOCAL_PORT="${LOCAL_PORT:-3000}"
REMOTE_PORT="${REMOTE_PORT:-80}"

echo "Port-forwarding service/${SERVICE_NAME} in namespace ${NAMESPACE}"
echo "Open http://localhost:${LOCAL_PORT} while this command is running"

exec kubectl -n "${NAMESPACE}" port-forward "svc/${SERVICE_NAME}" "${LOCAL_PORT}:${REMOTE_PORT}"
