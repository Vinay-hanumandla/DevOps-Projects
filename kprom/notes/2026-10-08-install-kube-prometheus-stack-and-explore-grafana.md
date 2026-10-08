---
last_verified: 2026-10-08
tool_version: n/a
---

# Installing the kube-prometheus stack and exploring Grafana

I installed kube-prometheus-stack on a local cluster to see what a turnkey monitoring stack looks like.

## What I did

1. Installed the chart with a small values file that flips the three services to NodePort so I could reach the UIs from outside the cluster:
   ```bash
   helm install monitoring <chart-ref> -f values-local.yaml
   ```
2. Waited for the pods to come up. The chart deploys the Prometheus Operator, Prometheus, Alertmanager, node-exporter, kube-state-metrics, and Grafana as one release.
3. Opened Grafana in a browser with the default `admin` / `admin` credentials.

## What I saw in Grafana

The chart provisions a folder of dashboards for me automatically. The most useful ones on a first pass:

- **Kubernetes / Cluster** — cluster-wide resource usage, node capacity, and pod counts.
- **Kubernetes / Pods** — per-pod CPU, memory, and restart counts.
- **Kubernetes / Nodes** — per-node CPU, memory, and disk pressure.
- **Prometheus** — the built-in Prometheus dashboard, showing scrape performance and query stats.

The dashboards ship as ConfigMaps the chart loads into Grafana, so they show up without me configuring anything.

## What tripped me up

- The default service type is ClusterIP, so nothing is reachable from a laptop unless I set a `service.type` override. I had to flip `prometheus.service.type`, `alertmanager.service.type`, and `grafana.service.type` to NodePort.
- The default admin password is `admin` only because I did not set `grafana.adminPassword`. I should have pointed it at an existing secret instead.

## What I'd try next

I want to open the Prometheus UI and run a couple of PromQL queries against the cluster metrics, then see which default alerting rules are firing so I understand how Alertmanager routes them.