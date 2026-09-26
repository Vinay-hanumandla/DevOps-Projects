---
last_verified: 2026-09-26
tool_version: "3.x"
sources:
  - https://helm.sh/docs/
  - https://helm.sh/docs/chart_template_guide/
---

# Helm production best practices reference

## Chart structure conventions

Helm charts follow a well-defined directory layout that the `helm create` command generates. Every chart is a directory with `Chart.yaml` at its root.

- `Chart.yaml` — chart metadata: `apiVersion`, `name`, `version`, `description`, `type` (application or library).
- `values.yaml` — default values consumed by templates. Treat this as the contract between chart authors and release operators.
- `templates/` — rendered Kubernetes manifests. Template logic lives here; environment-specific choices live in values files.
- `charts/` — vendored subcharts or dependencies. When present, run `helm dependency update` to regenerate `Chart.lock` and the `charts/` subdirectories.
- `templates/_helpers.tpl` — named template blocks that extract repeated logic (labels, selectors, annotations) into a single definition.
- `templates/NOTES.txt` — post-install notes shown to the operator. Useful for credentials, connection strings, or next steps.

Keep template files small and single-purpose. When a template grows beyond roughly 60 lines, extract a named block into `_helpers.tpl` or split it into a separate template file.

## Test hooks

Helm lets you declare a `test` job via the `helm test` command. A test pod runs after install or upgrade and reports pass/fail through its exit code.

```yaml
# templates/test-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-test"
  annotations:
    "helm.sh/hook": test
spec:
  template:
    spec:
      restartPolicy: Never
      containers:
        - name: test
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          command: ["sh", "-c", "curl -sf http://localhost:8080/healthz"]
```

Use test hooks for:
- Smoke-testing that the release actually responds after upgrade.
- Verifying database migrations completed.
- Asserting that a secret exists and is readable by the release.

Test hooks run in the same namespace as the release. They should not mutate state — they are assertions, not side effects.

## Release management

Helm tracks every release as a revision. `helm history <release>` lists revisions; `helm rollback <release> <revision>` restores a prior state.

Operational checklist for a release:
1. `helm lint` — catch syntax and template errors before touching the cluster.
2. `helm template` — render manifests locally and review them.
3. `helm diff upgrade` (helm-diff plugin) — show what will change without applying.
4. `helm upgrade --install` — apply the new revision. `--install` makes the command idempotent for first-time deploys.
5. `helm status` — confirm the release is healthy.
6. `helm rollback` — restore a previous revision when verification fails.

Use `--atomic` on upgrades when a failed apply must not leave a broken revision behind; Helm rolls back automatically on failure. Use `--wait` only when the chart sets pod readiness checks, otherwise the command can hang on workloads without readiness probes.

## Environment layering

A single chart serves dev, staging, and prod by layering values files. The base `values.yaml` holds safe defaults; per-environment files override only the keys that differ. For the full merge order (chart default < `-f` files left to right < `--set` flags), see helm-012 (helm-values-inheritance.md).

```bash
# base
helm upgrade --install my-service ./charts/my-service --namespace dev -f values-dev.yaml

# staging
helm upgrade --install my-service ./charts/my-service --namespace staging -f values-staging.yaml

# prod
helm upgrade --install my-service ./charts/my-service --namespace prod -f values-prod.yaml
```

For CI, keep environment files checked in next to the chart and drive environment selection from a pipeline variable.

## Pre-flight checks

Before running a release, verify:
- The chart directory exists and `helm lint` passes.
- The target namespace exists or `--create-namespace` is set.
- The helm-diff plugin is installed when diff review is required.
- Required values keys are present; missing keys fail at template render time, which `helm template` catches first.
- Secrets are not committed in plain values files; inject them via `--set`, a secrets manager, or sealed secrets at deploy time.

## Verification

1. `helm lint ./charts/my-service` exits 0.
2. `helm template test-release ./charts/my-service` renders without errors.
3. `helm list --all-namespaces` shows the release in the expected namespace.
4. `helm history my-service -n staging` shows the new revision number.
5. `helm get manifest my-service -n staging` returns the applied manifests for review.