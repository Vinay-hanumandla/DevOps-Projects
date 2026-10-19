---
last_verified: 2026-10-19
tool_version: n/a
sources:
---

# Helm chart repository management and dependency locking

## Purpose

This reference covers how to manage Helm chart repositories and how to lock chart dependencies so builds are reproducible. It explains where charts live, how to add and synchronize repositories, how to declare chart dependencies, and how `Chart.lock` pins dependency versions across installs and upgrades.

## When to use

Use this reference when you need to:

- Add a chart repository and keep its local index in sync.
- Package and share a chart through a repository or OCI registry.
- Declare dependencies between charts and pin them so every install resolves the same versions.
- Troubleshoot a release whose dependencies changed between runs.

## Prerequisites

- Helm installed and on `PATH`.
- A chart directory with `Chart.yaml` and `values.yaml`.
- Network access to the chart repository or OCI registry you plan to use.

## Steps

### Add and sync a chart repository

1. Add a repository by name and URL:

   ```bash
   helm repo add my-repo <repository-url>
   ```

2. Synchronize the local index from every configured repository:

   ```bash
   helm repo update
   ```

3. Search the repository for a chart:

   ```bash
   helm search repo my-repo
   ```

4. List configured repositories:

   ```bash
   helm repo list
   ```

`helm repo update` downloads the latest `index.yaml` from each configured repository. Without it, `helm search repo` and `helm install` may see stale chart versions.

### Remove a repository

```bash
helm repo remove my-repo
```

### Declare and lock chart dependencies

Edit `Chart.yaml` and list dependencies under the `dependencies` key, pinning each to a specific version:

```yaml
dependencies:
  - name: postgresql
    version: "<pinned-version>"
    repository: "<repository-url>"
```

Then resolve, fetch, and record the dependencies:

```bash
helm dependency build
helm dependency lock
helm dependency list
```

- `helm dependency build` reads `Chart.yaml`, downloads the listed dependencies into `charts/`, and writes or updates `Chart.lock`.
- `helm dependency lock` regenerates `Chart.lock` from `Chart.yaml` without downloading, useful when you only want to record the pinned versions.
- `helm dependency list` shows the resolved dependencies and their versions from `Chart.lock`.

Commit `Chart.lock` alongside `Chart.yaml` so every environment installs the same dependency versions. Re-run `helm dependency build` after changing `Chart.yaml` dependencies, then commit the regenerated `Chart.lock`.

### Install from a repository

```bash
helm install my-release my-repo/my-chart --namespace default
```

For OCI registries, reference the chart by its OCI URI instead of a repository name:

```bash
helm install my-release oci://registry.example.com/charts/my-chart
```

## Verify

- `helm lint` exits zero for the chart and every dependency.
- `helm template` renders the chart with locked dependencies without errors.
- `helm dependency list` shows versions matching `Chart.lock`.
- `helm install` and `helm upgrade` resolve the same dependency versions across environments when `Chart.lock` is committed.

## Common errors

- `Chart.lock` is missing or stale: `helm dependency build` may resolve a newer dependency version than intended. Regenerate `Chart.lock` after every `Chart.yaml` dependency change and commit it.
- A dependency repository is not configured: `helm dependency build` fails to download a chart whose `repository` was never added with `helm repo add`.
- Version ranges resolve differently over time: prefer exact versions in `Chart.yaml` and rely on `Chart.lock` to pin the resolved digest.
- Mixing repository charts and OCI charts in the same `Chart.yaml` can fail when one registry requires authentication the other does not.

## References

- `helm-values-inheritance.md` — chart value merge order across environments
- `helm-production-best-practices.md` — release management and pre-flight checks
