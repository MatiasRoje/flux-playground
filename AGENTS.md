 This repo is a GitOps playground for a local kind cluster managed by Flux.

Before implementation work:
- Read `karpathy-guidelines` skill.
- Work in small phases.
- Stop for human review after every phase.
- Do not continue into the next phase until the user approves.
- Keep manifests simple, explicit, pinned, and maintainable.
- Prefer established Flux/Kubernetes/Helm patterns over custom abstractions.
- Do not silently choose major design tradeoffs. Ask first.

Implementation style:
- Make one coherent phase per change set.
- Verify each phase with concrete commands, e.g. `kubectl kustomize`.
- Record exact versions and chart sources.
- Keep namespaces and ownership clear.
- Avoid unrelated cleanup.
- Avoid generated noise unless it is necessary and reproducible.

GitOps rules:
- After kind and Flux bootstrap, all cluster resources must come from Git.
- Use Flux `Kustomization` dependencies to order phases.
- Use exact chart versions, not ranges.
- Use OCI charts where verified and available.
- Stop if a chart/source/version does not resolve exactly.

Docs usage:
- `docs/` files are optional future-reference context, not enforced policy.
- Default behavior: do **not** load `docs/` files unless there is a concrete, task-specific need.
- Load `docs/` only when the current task explicitly depends on information that is likely to be in a specific doc.
- Never load `docs/` "just in case" or for generic background.
- Do not bulk-load docs into context; read only the exact file and section needed.
- If a doc is loaded, keep the extracted context minimal and directly relevant to the current change.
