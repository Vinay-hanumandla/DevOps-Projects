---
last_verified: 2026-10-06
tool_version: "n/a"
---

# Choosing a Kubernetes secret management approach

## Purpose

This reference compares three common patterns for getting sensitive values into cluster workloads: encrypted-in-git secrets, an operator that mirrors an outside vault into cluster Secrets, and a driver that mounts outside secrets as volumes. It gives a decision rule for picking one per environment rather than mixing all three ad hoc.

## When to use

- Encrypted-in-git secrets fit teams that want every desired state in the repository and already review changes through pull requests. The encrypted blob lives beside the manifests, and only the in-cluster controller can decrypt it.
- An operator that syncs from an outside vault fits teams that already store secrets in a central vault service and want cluster Secrets to stay a read-through cache of that source. Rotation happens at the vault, and the operator refreshes the mirror on a schedule.
- A driver that mounts secrets as volumes fits workloads that should never persist a copy as a cluster Secret object, or that need rotation without restarting pods. The value appears as files under the container mount path and refreshes while the pod runs.

| Signal | Encrypted-in-git | Vault-sync operator | Volume-mount driver |
|---|---|---|---|
| Source of truth | Git repository | Outside vault service | Outside vault service |
| What lands in the cluster | A native Secret, decrypted by the controller | A native Secret, mirrored from the vault | Files under a volume mount, no mirrored Secret |
| Rotation story | Re-encrypt and commit, controller reconciles | Update vault, operator re-syncs on its interval | Update vault, driver refreshes the mounted files |
| Offline or disconnected clusters | Works, decryption key stays in cluster | Needs vault reachability on sync | Needs vault reachability on mount and refresh |
| Audit trail | Git history of who changed the encrypted blob | Vault audit log plus sync status on the custom resource | Vault audit log plus mount events |

A workable default is one approach per trust boundary: encrypted-in-git for a small platform team that owns both the repo and the cluster, vault-sync where a central security team already owns rotation and audit, volume-mount where the threat model forbids leaving a standing Secret copy.

## Prerequisites

- A cluster with cluster-admin equivalent access for installing controllers.
- A namespace per workload, with a least-privilege service account for the consuming app.
- A way to back up whatever holds the plaintext: the decryption key, or the vault itself.
- Agreement on which environments share a vault and which stay self-contained.

## Steps

1. Classify each secret by lifetime: static bootstrap values versus short-lived credentials that rotate on a schedule. Static values tolerate the git flow; rotating values push toward the vault-backed options.
2. For the encrypted-in-git path, generate a cluster-side key pair, scope decryption to the target namespaces, and commit only the encrypted form. Keep the plaintext out of shell history and out of pull request descriptions.
3. For the vault-sync path, create one store definition per vault backend, then one sync definition per workload that names the remote key and the destination Secret shape. Start with a long refresh interval and shorten it only after observing sync status events.
4. For the volume-mount path, attach the driver to the pod volume list and reference the remote key by name. Have the application read the file at startup and re-read it on each use rather than caching the first read forever.
5. Wire the consuming workload the same way regardless of path: environment variable or file reference, never a hardcoded literal. Keep the reference name stable so the backend can change without editing the deployment.
6. Grant read access narrowly: the controller or driver identity may read the vault, the workload identity may read only its own Secret or mount, and human operators get neither by default.

## Verify

- List the workload namespace and confirm only the expected Secret or mounted volume exists, with no plaintext copy in annotations or logs.
- Describe the sync or mount status object and confirm the last sync time is recent and reports no error condition.
- Rotate one non-production value at the source and confirm the cluster copy updates within the configured interval without manual intervention.
- Delete the workload pod and confirm the replacement still resolves the secret, proving the value comes from the controller rather than from node-local state.

## Common errors

- Committing the plaintext file next to the encrypted one, usually from an editor backup or a mis-scoped ignore rule. Verify the committed tree contains only the encrypted form before opening the pull request.
- Pointing two sync definitions at the same destination Secret name, so they overwrite each other on every interval. Give each workload its own destination name.
- Reading a mounted file once at startup and never again, which silently defeats live rotation. Re-read per request or on a short timer.
- Granting the sync controller broader vault access than the workloads it serves, turning a namespace compromise into a vault-wide read. Scope the store definition to the smallest key prefix each team needs.
