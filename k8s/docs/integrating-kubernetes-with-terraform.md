---
last_verified: 2026-09-18
tool_version: n/a
---

# Integrating Kubernetes with Terraform

> A practical boundary between provisioning cluster infrastructure and managing the workloads that run on it.

## Purpose

Terraform and Kubernetes solve adjacent parts of the same delivery problem. Terraform is useful for declaring the infrastructure around a cluster: the network, nodes, access settings, and other resources that must exist before applications can run. Kubernetes is useful for declaring the desired state of the applications and supporting resources once a cluster is available.

Keeping those responsibilities separate makes changes easier to review. A cluster change should be evaluated as an infrastructure change, while an application change should be evaluated as a workload change. The two systems can still share values such as an environment name, region, cluster identifier, or application configuration, but each system should own the resources it is best suited to reconcile.

## When to use this pattern

This approach fits teams that want repeatable cluster provisioning and declarative workload management without turning one tool into the control plane for everything. It is also useful when different people review infrastructure and application changes, or when the same workload needs to move between several similarly structured environments.

It is less useful for a short-lived experiment where a single person is making all changes manually. In that case, a smaller setup may be easier to understand. The boundary becomes valuable when changes recur, need review, or must be reproduced consistently.

## Define the ownership boundary

Start by deciding which resources belong to each layer:

- **Infrastructure layer:** cluster lifecycle, networking, node capacity, identity and access settings, and shared services needed to make the cluster usable.
- **Workload layer:** application configuration, scheduling preferences, exposure rules, health checks, and the desired state of resources inside the cluster.
- **Shared inputs:** environment names, release identifiers, and configuration values that both layers consume but neither layer silently rewrites.

The important rule is to avoid two controllers trying to own the same resource. If Terraform creates a cluster-level object, Kubernetes workload declarations should treat it as an input. If Kubernetes owns an in-cluster object, Terraform should not recreate or delete it during a routine infrastructure change.

## A repeatable workflow

1. **Describe the cluster inputs.** Keep environment-specific values in a small, reviewable input file. Include only values needed by the infrastructure and workload layers.
2. **Provision the cluster.** Run the infrastructure change through the normal review process. Confirm that the resulting cluster is reachable and that its shared inputs are available to the workload layer.
3. **Render workload declarations.** Generate or select the workload configuration for the target environment. Keep environment differences explicit rather than relying on an operator's memory.
4. **Apply workload state.** Submit the desired workload state to the cluster through the team's established change process. Let Kubernetes reconcile the declared state over time.
5. **Observe the result.** Check that the expected workloads become available, that health signals are acceptable, and that the observed state matches the intended release.
6. **Record the release boundary.** Keep the infrastructure revision and workload revision identifiable so a later incident can be traced to the change that introduced it.

The order matters. Provisioning should establish a stable target before workload changes are introduced. Workload changes should not be used as a substitute for fixing missing cluster infrastructure.

## Verification checklist

After an infrastructure change, confirm that the cluster endpoint is usable, the intended node capacity is present, and the shared inputs resolve to the expected environment. After a workload change, confirm that the intended application state is present, health checks report success, and traffic reaches the expected workload.

For a combined change, verify each layer independently before judging the release. If the cluster is healthy but the workload is not, inspect the workload boundary. If the workload declaration is valid but the cluster inputs are wrong, inspect the infrastructure boundary. This separation keeps troubleshooting focused and prevents a small configuration mistake from being mistaken for a failure of both tools.

## Common mistakes

The most common mistake is giving both tools ownership of the same object. Another is copying environment-specific values into several places, which allows the layers to drift. A third is applying workload changes before the cluster inputs they depend on are ready.

Treat the boundary as an explicit contract: Terraform publishes the cluster context, and Kubernetes reconciles the workload context. Keep that contract small, reviewable, and consistent across environments.
