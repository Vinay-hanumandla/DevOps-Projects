---
last_verified: 2026-09-17
tool_version: n/a
---

# Managing Kubernetes with Ansible

## Purpose

This is one way to manage Kubernetes workloads with Ansible, using the
`kubernetes.core` collection for raw manifests and CRDs, Helm releases, and
Kustomize overlays. The docs also describe doing each of these with the
native CLIs, so treat this as the "Ansible as glue" option rather than the
only option.

It fits best for day-2 operational playbooks: one playbook that creates a
namespace, installs a CRD, deploys a Helm release into it, and then applies a
Kustomize overlay for environment tweaks. For pure app delivery, plain
`kubectl` or `helm` in CI is usually simpler; Ansible earns its place when the
Kubernetes steps sit between other automation (VM provisioning, DNS, secrets)
in the same run.

## Prerequisites

- A reachable cluster and a kubeconfig with enough RBAC for the objects the
  playbook touches.
- The collection installed: `ansible-galaxy collection install kubernetes.core`.
- The Python dependencies the collection's modules need on the controller
  (the collection docs list them; install them into the same interpreter
  Ansible runs under).
- The kubeconfig kept out of the repo — passed in at runtime via an
  environment variable or a file outside version control, never committed.

## Steps

### 1. Point the play at the right cluster

Set `K8S_AUTH_KUBECONFIG` (or pass `kubeconfig:` per task) so every
`kubernetes.core` task talks to the intended cluster. Running a first task
against the wrong context is the classic mishap here, so print the current
context in a debug task before anything mutating.

### 2. Apply plain manifests and CRDs with the `k8s` module

Use `kubernetes.core.k8s` with `state: present` and either an inline
`definition:` or a `src:` file. This covers built-in types and CRDs alike —
a CRD instance is just another manifest as far as the module is concerned,
though the CRD itself must already be installed or applied first in the same
play.

```yaml
- name: Ensure monitoring namespace exists
  kubernetes.core.k8s:
    state: present
    definition:
      apiVersion: v1
      kind: Namespace
      metadata:
        name: monitoring
```

Re-running the play should report no changes, which doubles as a quick
idempotency check.

### 3. Manage Helm releases with the `helm` module

Use `kubernetes.core.helm` with `name:`, `chart_ref:`, and
`release_namespace:` instead of shelling out to the `helm` binary. Values go
in `values:` or `values_files:`, keeping the release declaration next to the
rest of the play.

```yaml
- name: Deploy metrics stack via Helm
  kubernetes.core.helm:
    name: metrics
    chart_ref: metrics-chart
    release_namespace: monitoring
    create_namespace: false
    values:
      retentionDays: 15
```

### 4. Layer environment differences with Kustomize

Where an overlay directory (`base/` plus per-environment patches) already
exists, point the Kustomize support at it rather than duplicating the
manifests as Ansible templates. The base stays the shared truth; the overlay
carries only the per-environment delta (replica counts, image tags, resource
requests).

### 5. Order the play CRDs first, apps last

A workable order is: namespaces → CRDs (wait for them to be established) →
Helm releases and Kustomize overlays that create instances of those CRDs.
Reversing the last two steps is the usual source of "resource not found"
failures on a fresh cluster.

## Verify

- Run the play with `--check --diff` first and confirm the planned changes
  match expectations.
- Run it for real, then run it again: the second run should report no
  changes, confirming the manifests, release, and overlay are all idempotent.
- Confirm from the cluster side (`kubectl get` on the namespace, CRD
  instances, and Helm release status) that one source — the playbook — owns
  all three layers.
