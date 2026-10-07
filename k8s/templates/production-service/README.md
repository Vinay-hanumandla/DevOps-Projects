---
last_verified: 2026-10-07
tool_version: n/a
---

# Production service template

## Purpose

A copy-paste starting point for running a stateless HTTP service in production: Deployment, Service, dedicated ServiceAccount, HorizontalPodAutoscaler, PodDisruptionBudget, default-deny NetworkPolicy, and namespace resource budgets (ResourceQuota plus LimitRange), wired together through a Kustomization so each environment only overrides the image tag and replica bounds.

## When to use

Use this template when a service graduates from an ad-hoc Deployment to something that must survive node drains, traffic spikes, and noisy neighbours. It is deliberately boring: one container, ClusterIP exposure, CPU and memory based autoscaling, and budgets that keep one namespace from starving the rest of the cluster.

## Prerequisites

- A namespace to own the service and its budgets.
- A container image for the service exposing `GET /healthz` on port 8080.
- Cluster DNS and a metrics pipeline capable of serving CPU and memory utilization to the HPA.

## Layout

| File | Contains |
|---|---|
| `deployment.yaml` | 3-replica Deployment, rolling update with zero unavailable, pod anti-affinity, probes, resource requests and limits, restricted pod and container security settings |
| `service.yaml` | ClusterIP Service mapping port 80 to the container port |
| `serviceaccount.yaml` | Dedicated ServiceAccount so the workload never runs as `default` |
| `hpa.yaml` | Autoscaler, 3 to 10 replicas on CPU and memory utilization with a scale-down stabilization window |
| `pdb.yaml` | Disruption budget keeping at least 2 pods available during voluntary disruptions |
| `networkpolicy.yaml` | Default-deny policy allowing ingress from same-app pods and the ingress namespace, egress to DNS and outbound HTTPS only |
| `namespace-budgets.yaml` | ResourceQuota capping namespace totals plus a LimitRange defaulting requests and limits for containers that omit them |
| `kustomization.yaml` | Resource list, shared labels, and the `images:` slot that rewrites the image tag per environment |
| `verify.sh` | Dry-run check that the rendered Kustomization is valid |

## Steps

1. Copy this directory and rename the `checkout-api` app label, resource names, and selectors to the service name.
2. Set the image tag in `kustomization.yaml` (`images:` → `newTag`) to the release built by CI, matching the tag in `deployment.yaml`.
3. Adjust budgets: container requests and limits in `deployment.yaml`, totals in `namespace-budgets.yaml`, and the HPA utilization targets to match load-test results.
4. Open the NetworkPolicy for the service's real callers: add the client pod selectors or namespaces under `ingress.from`, and extend `egress` only for destinations the service genuinely calls.
5. Render and apply per environment:
   ```bash
   kubectl apply -k . -n <namespace> --dry-run=client
   ./verify.sh
   kubectl apply -k . -n <namespace>
   ```

## Verify

- `./verify.sh` exits 0 and the dry-run output contains all eight resource kinds.
- `kubectl get hpa,pdb,networkpolicy,resourcequota,limitrange -n <namespace>` shows every budget and policy bound to the service name.
- Rolling out a new tag keeps at least 2 pods ready throughout, and draining a node never drops below the PDB floor.
- Traffic from an unlabeled test pod is refused while the ingress path still reaches `/healthz`.

## Common errors

- **HPA stuck at `unknown` utilization:** the metrics pipeline is not serving `metrics.k8s.io`; autoscaling stays pinned at `minReplicas` until metrics flow.
- **Pods unschedulable after applying the quota:** existing usage plus the new requests exceeds the ResourceQuota; raise the quota totals or lower per-container requests.
- **DNS or HTTPS calls fail after the policy lands:** the workload needs an egress destination not listed in `networkpolicy.yaml`; add the destination rather than deleting the policy.
- **Image tag drift between files:** `deployment.yaml` and the `images:` stanza in `kustomization.yaml` disagree; the Kustomization rewrite wins at apply time, so treat it as the single source of truth.

## See also

- `../../manifests/production-deployment.yaml` — the equivalent single-file manifest this template was factored out of; read it for the tuning rationale behind each field.
