---
last_verified: 2026-10-10
tool_version: n/a
sources: []
---

# Quickstart walkthrough: deploying kube-prometheus-stack via Helm, what tripped me up, and the scrape-config mental model

I followed the kube-prometheus-stack Helm chart to get a full monitoring stack running on a local cluster. This is what worked, what didn't, and the mental model that finally clicked.

## What I did

1. Added the Prometheus community Helm repo and installed the chart with a minimal values file:
   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install monitoring prometheus-community/kube-prometheus-stack \
     -n monitoring --create-namespace \
     -f values-local.yaml
   ```

2. My `values-local.yaml` only overrides three things — the service types so I can reach the UIs from my laptop:
   ```yaml
   prometheus:
     service:
       type: NodePort
   alertmanager:
     service:
       type: NodePort
   grafana:
     service:
       type: NodePort
       adminPassword: "changeme"
   ```

3. Waited for pods to come up — about 2 minutes on my machine:
   ```bash
   kubectl -n monitoring get pods -w
   ```

4. Port-forwarded to Grafana (or used the NodePort):
   ```bash
   kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
   ```
   Logged in with `admin` / `changeme`.

## What the chart actually installs

The chart deploys everything as one Helm release. Here's what lands in the cluster:

| Component | What it is |
|-----------|------------|
| Prometheus Operator | Controller that watches Prometheus/Alertmanager/ServiceMonitor CRs |
| Prometheus (CR) | The actual Prometheus server, configured via the Prometheus custom resource |
| Alertmanager (CR) | Handles alert routing, inhibition, silencing |
| node-exporter | DaemonSet scraping host metrics (CPU, memory, disk, network) |
| kube-state-metrics | Deployment exposing k8s object state as metrics |
| Grafana | Pre-provisioned with dashboards and Prometheus datasource |
| ServiceMonitors | CRs telling the operator what to scrape (kubelet, apiserver, etc.) |
| PrometheusRules | Default alerting rules for control plane and node health |

## The scrape-config mental model (what finally clicked)

Before this, I thought: "I need to write a `prometheus.yml` with scrape configs." That's the standalone Prometheus mental model.

With the Operator, the model is inverted:

1. **You don't edit `prometheus.yml` directly.** The Operator generates it from the Prometheus CR's `serviceMonitorSelector` and `podMonitorSelector`.

2. **ServiceMonitor = "what to scrape".** It selects Services by label and tells Prometheus how to scrape their pods. The chart creates ServiceMonitors for kubelet, apiserver, etcd, scheduler, controller-manager, and node-exporter automatically.

3. **PodMonitor = "scrape pods directly".** For workloads that don't have a Service, you create a PodMonitor instead.

4. **Prometheus CR = "which ServiceMonitors/PodMonitors to include".** The `serviceMonitorSelector` and `podMonitorSelector` are label selectors. The chart's default Prometheus CR selects `release: monitoring` (the Helm release name), so any ServiceMonitor with that label gets picked up.

5. **Your app = create a ServiceMonitor with the right labels.** To get your app scraped, you don't touch Prometheus config. You create a ServiceMonitor in your app's namespace with `release: monitoring` label, pointing at your app's Service.

This is the key insight: **scrape config becomes a distributed concern** — each team owns their ServiceMonitor, the platform team owns the Prometheus CR selector.

## What tripped me up

- **Default service type is ClusterIP.** Nothing is reachable from outside the cluster unless you override `service.type` to NodePort or LoadBalancer. I wasted 15 minutes wondering why port-forward didn't work — turned out I had the wrong service name.

- **Grafana admin password.** If you don't set `grafana.adminPassword`, it generates a random one stored in a secret. I had to decode it:
  ```bash
  kubectl -n monitoring get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d
  ```

- **ServiceMonitor namespace matching.** By default, the Prometheus CR only selects ServiceMonitors in the *same namespace* (monitoring). To scrape apps in other namespaces, you need either:
  - `serviceMonitorNamespaceSelector: {}` in the Prometheus CR (select all namespaces), or
  - Create ServiceMonitors in the monitoring namespace that target Services in other namespaces (messy)

- **The `release` label convention.** The chart labels everything with `release: monitoring`. If you install a second stack with a different release name, you need to update the Prometheus CR's selector to match both, or run two Prometheus instances.

- **Resource defaults are tiny.** The default Prometheus resources are 100m CPU / 1Gi memory — OOMs immediately on a real cluster. I had to bump:
  ```yaml
  prometheus:
    prometheusSpec:
      resources:
        requests:
          memory: 2Gi
          cpu: 500m
        limits:
          memory: 4Gi
          cpu: 2000m
  ```

## What I'd try next

1. Create a ServiceMonitor for a sample Go app with RED metrics (rate, errors, duration) and verify it shows up in Prometheus targets.
2. Look at the default PrometheusRules the chart installs — understand which alerts fire for control plane vs. node issues.
3. Configure Alertmanager to route alerts to Slack/PagerDuty instead of the default no-op receiver.
4. Try the `kube-prometheus` (not `kube-prometheus-stack`) project for a more GitOps-friendly, CR-only approach without Helm.