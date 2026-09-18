---
last_verified: 2026-09-18
tool_version: n/a
---

# How I wired Prometheus service discovery with Consul, file SD, and Kubernetes SD for hybrid targets

> A practical note on using Consul-backed, file-backed, and Kubernetes-backed discovery without turning target addresses into a scattered maintenance problem.

## Purpose

I wanted one Prometheus view across services running in a cluster, services registered outside the cluster, and a small set of targets that did not belong in either control plane. Hardcoding every address in one list made changes easy to miss and made ownership unclear.

The approach was to keep three discovery paths, give every discovered target a common label contract, and make each path responsible for a distinct part of the inventory. I still verified each selected endpoint against the metric surface I expected; discovery was only the way I built the target list.

## How I divided ownership

| Discovery path | Ownership boundary |
|---|---|
| Consul-backed discovery | Targets I assigned to the Consul-owned group, including non-cluster endpoints |
| File-backed discovery | A reviewed target list for exceptions, temporary systems, and hosts not represented elsewhere |
| Kubernetes-backed discovery | Targets I assigned to the cluster-owned group |

I kept the paths as separate inventory groups. That made it easier for me to see which source contributed a target and to investigate one path at a time.

## Steps

### 1. Define the target contract first

Before adding any discovery settings, I wrote down the labels that every target should carry:

- `source` identifies Consul, file, or Kubernetes as the discovery owner.
- `environment` distinguishes the deployment context.
- `service` carries the application or workload name.
- `instance` identifies the individual endpoint.

The exact values came from the services I already owned. The important part was consistency: a target should remain recognizable when it moves between discovery sources, and two sources should not silently claim the same endpoint.

### 2. Add the Consul-backed path

For the service-catalog workloads, I assigned the Consul-backed path to targets whose membership I wanted to derive from the catalog. I treated the catalog as the source of truth for that group, then kept the Prometheus-side selection aligned with the service set I expected.

I carried the useful service metadata into labels instead of rebuilding it from target addresses. That kept a service rename or environment change in one place. I also made the expected service set explicit so that an empty or unexpectedly small discovery result was visible during verification.

### 3. Add the file-backed path

The file-backed path covered targets that were valid but did not have a suitable registry entry. I treated the file as a reviewed inventory rather than a scratch list: each entry had enough metadata to identify its service, environment, and owner.

Changes to that file were made as a unit and checked before Prometheus consumed them. This path was intentionally small. If a target started having a natural home in Consul or Kubernetes, I moved it instead of keeping a second source of truth.

### 4. Add the Kubernetes-backed path

For cluster-owned workloads, I used the identity already present in the cluster inventory to select endpoints. I limited the cluster-owned selection to the namespaces and workloads in my expected inventory, then mapped the useful workload identity into labels.

In my workflow, this reduced the need to edit a separate address list when cluster-owned workloads changed. I still kept an expected inventory at the service level, and I did not treat a populated target list as proof that every intended workload was present or healthy.

### 5. Normalize and check for overlap

After all three paths were configured, I compared the resulting targets using the common labels. I looked for:

- the same endpoint appearing under more than one source;
- missing `source`, `environment`, `service`, or `instance` values;
- targets with the right address but the wrong ownership label;
- services expected from one path but absent from the inventory.

When overlap was legitimate, I documented which path won and removed the duplicate from the other path. When overlap was accidental, I corrected the ownership boundary rather than relying on a later query to hide it.

## Verify

I verified the setup in four passes:

1. Compare the discovered target count with the expected count for each source.
2. Check that every target is reachable and reports the expected health state.
3. Add and remove one test entry from each path, then confirm that Prometheus reflects the change.
4. Query a known metric and confirm that its labels preserve source, environment, service, and instance.

I also checked the failure boundaries separately: a missing file should not be confused with an empty Consul result, and a Kubernetes discovery problem should remain visible as a Kubernetes problem. Keeping the jobs separate made that diagnosis much faster.

## What I would improve next

The next step is to turn the label contract and expected inventories into reviewed checks, so a missing service or unexpected duplicate is caught before it becomes a monitoring gap. I would also keep the file-backed inventory deliberately small and revisit it whenever a target gains a natural home in Consul or Kubernetes.
