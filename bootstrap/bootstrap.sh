#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-flux-playground}"
FLUX_NAMESPACE="flux-system"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_cmd kind
require_cmd kubectl
require_cmd flux

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN must be set for Flux GitRepository auth." >&2
  exit 1
fi

echo "Recreating kind cluster: ${CLUSTER_NAME}"
kind delete cluster --name "${CLUSTER_NAME}" || true
kind create cluster --name "${CLUSTER_NAME}" --config "${ROOT_DIR}/bootstrap/kind/cluster.yaml"

echo "Installing Flux controllers from pinned manifest"
kubectl apply -f "${ROOT_DIR}/clusters/flux-playground/flux-system/gotk-components.yaml"

echo "Applying Flux Git auth secret"
kubectl -n "${FLUX_NAMESPACE}" create secret generic flux-system \
  --from-literal=username=git \
  --from-literal=password="${GITHUB_TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Applying Flux sync objects"
kubectl apply -f "${ROOT_DIR}/clusters/flux-playground/flux-system/gotk-sync.yaml"

echo "Bootstrap verification"
kubectl config current-context
flux check
kubectl get pods -n "${FLUX_NAMESPACE}"
flux get sources git -A
flux get kustomizations -A
