# Gateway Controller Evaluation And Selection Reference

Date: 2026-05-31
Type: reference document
Scope mode: evaluation only (no cluster mutations)
Decision at this date: **Recommend Envoy Gateway** as the selected controller.

## When To Load This Doc
- Load this document only for tasks that require Gateway controller comparison, selection rationale, or replacement planning inputs.
- Do not load this document for unrelated implementation/debugging work.
- If loaded, extract only the section needed for the current task.

## Scope
- Source of truth: Gateway API v1.5 implementations matrix + v1.5 conformance reports.
- Candidates compared: `agentgateway`, `envoy-gateway`, `nginx-gateway-fabric`, `kgateway`.
- Required QA resources: `GatewayClass`, `Gateway`, `HTTPRoute`, `GRPCRoute`, `TLSRoute`, `ListenerSet`, `BackendTLSPolicy`, `ReferenceGrant`.

## Comparison (v1.5 evidence)

| Candidate | Report | Feature evidence in report | Install reproducibility (for Flux/kind) | Risk signal |
|---|---|---|---|---|
| Envoy Gateway | `envoy-gateway/experimental-v1.8.0-gateway-namespace-mode-report.yaml` | `ListenerSet`, `BackendTLSPolicy`, `GRPCRouteNamedRule`, `TLSRouteModeMixed`, `TLSRouteModeTerminate` | OCI Helm chart `oci://docker.io/envoyproxy/gateway-helm` pinned `v1.8.0`; explicit CRD guidance | Lowest relative risk in this set |
| agentgateway | `agentgateway-agentgateway/v1.1.0-report.yaml` | `ListenerSet`, `BackendTLSPolicy`, `GRPCRouteNamedRule`, `TLSRouteModeMixed`, `TLSRouteModeTerminate` | Docs include Helm/Flux install paths | Newer ecosystem footprint |
| nginx-gateway-fabric | `nginx-nginx-gateway-fabric/experimental-2.6.0-default-report.yaml` | `ListenerSet`, `BackendTLSPolicy`, `TLSRoute*` | Installable; report available as experimental mode in v1.5 tree | Lower confidence due to report status |
| kgateway | `kgateway/v2.3.0-beta.3-report.yaml` | `ListenerSet`, `BackendTLSPolicy`, `GRPCRouteNamedRule`, `TLSRoute*` | Installable | Reported version is beta |

## Why Envoy Gateway
- Meets required Gateway API feature baseline in upstream v1.5 evidence.
- Pinned, reproducible OCI Helm install path fits Flux workflows.
- Better maturity/operational confidence vs alternatives above.

## Guardrails For Reuse
- Keep one active Gateway controller and one `GatewayClass`.
- Replace Traefik cleanly; do not introduce dual-controller steady state.
- Keep versions pinned and manifest ownership explicit.
- If live bake-off is needed, use disposable kind cluster only.

## Sources
- https://gateway-api.sigs.k8s.io/docs/implementations/versions/v1.5/
- https://github.com/kubernetes-sigs/gateway-api/tree/main/conformance/reports/v1.5
- https://gateway.envoyproxy.io/v1.8/install/install-helm/
- https://agentgateway.dev/docs/kubernetes/main/install/
