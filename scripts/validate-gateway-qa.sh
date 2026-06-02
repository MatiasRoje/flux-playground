#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
infra_render="$(mktemp)"
workload_render="$(mktemp)"
trap 'rm -f "$infra_render" "$workload_render"' EXIT

kubectl kustomize "$repo_root/clusters/flux-playground/infrastructure/config" > "$infra_render"
kubectl kustomize "$repo_root/clusters/flux-playground/workload/dev" > "$workload_render"

yq -e '
  select(.apiVersion == "gateway.networking.k8s.io/v1" and .kind == "GatewayClass" and .metadata.name == "envoy-gateway")
  | .spec.parametersRef.group == "gateway.envoyproxy.io"
    and .spec.parametersRef.kind == "EnvoyProxy"
    and .spec.parametersRef.name == "kind-nodeport"
    and .spec.parametersRef.namespace == "infra"
' "$infra_render" >/dev/null

yq -e '
  select(.apiVersion == "gateway.envoyproxy.io/v1alpha1" and .kind == "EnvoyProxy" and .metadata.name == "kind-nodeport")
  | .metadata.namespace == "infra"
    and .spec.provider.type == "Kubernetes"
    and .spec.provider.kubernetes.envoyService.type == "NodePort"
    and (.spec.provider.kubernetes.envoyService.patch.value.spec.ports[] | select(.port == 80) | .nodePort == 30080)
    and (.spec.provider.kubernetes.envoyService.patch.value.spec.ports[] | select(.port == 443) | .nodePort == 30443)
' "$infra_render" >/dev/null

yq -e '
  select(.apiVersion == "gateway.networking.k8s.io/v1" and .kind == "Gateway" and .metadata.name == "dev-gateway")
  | .spec.addresses[0].type == "IPAddress"
    and .spec.addresses[0].value == "127.0.0.1"
' "$workload_render" >/dev/null

yq -e '
  select(.apiVersion == "v1" and .kind == "Service" and (.metadata.name == "tcp-backend" or .metadata.name == "tls-backend" or .metadata.name == "udp-backend"))
  | .spec.selector.app == "whoami"
' "$workload_render" >/dev/null
