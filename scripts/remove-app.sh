#!/usr/bin/env bash

set -euo pipefail

ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
APP_NAMESPACE="${APP_NAMESPACE:-hello-dev}"
ROOT_APP="${ROOT_APP:-root-dev}"
CHILD_APPS="${CHILD_APPS:-hello-app-dev kube-hello-app-dev}"
ARGOCD_FINALIZER="${ARGOCD_FINALIZER:-resources-finalizer.argocd.argoproj.io}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required but not installed." >&2
  exit 1
fi

patch_finalizer_if_exists() {
  local app_name="$1"

  if kubectl -n "${ARGOCD_NAMESPACE}" get application "${app_name}" >/dev/null 2>&1; then
    echo "Adding Argo CD resource finalizer to application/${app_name}"
    kubectl -n "${ARGOCD_NAMESPACE}" patch application "${app_name}" \
      --type merge \
      -p "{\"metadata\":{\"finalizers\":[\"${ARGOCD_FINALIZER}\"]}}"
  else
    echo "Application ${app_name} not found in namespace ${ARGOCD_NAMESPACE}; skipping finalizer patch"
  fi
}

echo "Preparing Argo CD applications for clean deletion"
for app_name in ${CHILD_APPS}; do
  patch_finalizer_if_exists "${app_name}"
done
patch_finalizer_if_exists "${ROOT_APP}"

echo "Deleting root Argo CD application ${ROOT_APP}"
kubectl -n "${ARGOCD_NAMESPACE}" delete application "${ROOT_APP}" --ignore-not-found

echo "Deleting child Argo CD applications as a fallback"
for app_name in ${CHILD_APPS}; do
  kubectl -n "${ARGOCD_NAMESPACE}" delete application "${app_name}" --ignore-not-found
done

echo "Deleting workload namespace ${APP_NAMESPACE}"
kubectl delete namespace "${APP_NAMESPACE}" --ignore-not-found

echo "Removal requested."
echo "Verify with:"
echo "  kubectl -n ${ARGOCD_NAMESPACE} get applications.argoproj.io"
echo "  kubectl get namespace ${APP_NAMESPACE}"
