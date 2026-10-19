---
last_verified: 2026-10-19
tool_version: "3.13"
sources: []
---

# Helm 3.13+ migration guide

## Purpose

This guide covers what actually changed when moving to Helm 3.13 and later, and what to check in existing charts before upgrading. Helm 3.13 introduced a values precedence change that broke backwards compatibility for some charts; 3.14 addressed it. If you are coming from 3.12 or earlier, the three areas that matter most are values precedence, OCI registry support, and library charts.

## Values precedence change (3.13 → 3.14)

Helm 3.13 reordered how values from a parent chart, imported values, and sub-chart values merge. The change broke some charts that relied on the previous order, and Helm 3.14 restored the prior behaviour while keeping the underlying fix.

- In 3.13.0 the precedence was: user-specified values (CLI) → sub-chart values → imported values → parent chart values.
- In 3.13.1 and 3.14.0 the order was corrected to: user-specified values → parent chart values → imported values → sub-chart values.

The practical effect: a parent chart can again supply defaults into a sub-chart, which was possible in 3.8.2 through 3.12.3. If your chart sets values for a sub-chart from the parent `values.yaml`, verify the result after upgrading. The fix is tracked in the Helm issue and pull request for values precedence (issue 12460, fix in pull request 12480).

## OCI registry support

Beginning with Helm 3, charts can be stored in OCI-compatible container registries as an alternative to Helm repositories. OCI support graduated from experimental to generally available in Helm 3.8.0.

- Before 3.8.0, set `HELM_EXPERIMENTAL_OCI=1` to enable it.
- From 3.8.0 onward, OCI support is on by default and no environment variable is needed.

Key commands use the `oci://` prefix:

```console
$ helm push mychart-0.1.0.tgz oci://localhost:5000/helm-charts
Pushed: localhost:5000/helm-charts/mychart:0.1.0
```

Notes:
- The registry reference must be prefixed with `oci://` and must not include the basename or tag; the chart name and semantic version are inferred from `Chart.yaml`.
- `helm push` works only against `.tgz` files produced by `helm package`.
- A provenance file (`.prov`) placed next to the chart archive is uploaded automatically.
- The `helm-push` plugin conflicts with the built-in `push`; as of v0.10.0 it was renamed `cm-push`.
- Supported subcommands: `helm pull`, `helm push`, `helm show`, `helm template`, `helm install`, `helm upgrade`.

Hosted registries with OCI support include Amazon ECR, Azure Container Registry, Cloudsmith, Docker Hub, Google Artifact Registry, Harbor, IBM Cloud Container Registry, JFrog Artifactory, and RepoFlow. A local Docker Registry or `zot` can be used for testing only.

## Library charts

Library charts were formalised in Helm 3. They are charts whose only purpose is to define named templates that other charts reuse, avoiding copy-paste of `_helpers.tpl` across charts.

- Set `type: library` in `Chart.yaml`. A library chart cannot be installed on its own.
- Named templates live in `templates/` files, typically `_*.tpl`. Files starting with an underscore are not rendered as Kubernetes manifests.
- An application chart consumes a library chart by listing it under `dependencies` in its `Chart.yaml`, then running `helm dependency update`.

```yaml
# mylibchart/Chart.yaml
apiVersion: v2
name: mylibchart
type: library
version: 0.1.0
```

```yaml
# mychart/Chart.yaml
dependencies:
  - name: mylibchart
    version: 0.1.0
    repository: file://../mylibchart
```

## Other changes to know

- `helm install` now requires a release name or `--generate-name`.
- `helm list` shows only releases in the current namespace by default; use `--all-namespaces` for the old behaviour.
- Release metadata is stored in Secrets by default (Helm 2 used ConfigMaps).
- `helm init`, `helm home`, `helm serve`, and `helm reset` were removed.
- `crd-install` hooks were replaced by a `crds/` directory in the chart, installed before rendering.
- The Go import path changed from `k8s.io/helm` to `helm.sh/helm/v3`.

## Verify

1. `helm lint ./charts/my-service` exits 0.
2. `helm template test-release ./charts/my-service` renders without errors.
3. For OCI: `helm push mychart-0.1.0.tgz oci://localhost:5000/helm-charts` succeeds and `helm pull oci://localhost:5000/helm-charts/mychart:0.1.0` retrieves it.
4. For library charts: `helm dependency update` populates `charts/` and `helm template` renders the consuming chart without error.