---
last_verified: 2026-09-26
tool_version: "n/a"
---

# my-service chart scaffold

I built the chart the values inheritance guide keeps pointing at. It didn't exist yet, so `-f values-staging.yaml` in the guide had nothing to run against. Now it does.

## What I made

A plain chart with a shared base plus one override file per environment:

- `Chart.yaml` — just names the chart, nothing clever
- `values.yaml` — base defaults (1 replica, ClusterIP on 8080)
- `values-dev.yaml`, `values-staging.yaml`, `values-prod.yaml` — only the keys that differ
- `templates/deployment.yaml`, `templates/service.yaml` — read from values, no environment logic

## What I checked

I compared every file against the layout and values in the inheritance guide by hand — same keys, same override values, templates reading the same paths. I couldn't run `helm lint` here (no helm in this box), so that check is still open:

```bash
helm lint ./my-service
helm template my-service ./my-service -f ./my-service/values-staging.yaml
```

Staging should show 2 replicas, prod 4 with LoadBalancer, and base port 8080 carrying through untouched in both.

**Got stuck on:** nothing yet, but I haven't installed it anywhere. Next I'd try an actual upgrade into a throwaway namespace and watch what `--wait` does.
