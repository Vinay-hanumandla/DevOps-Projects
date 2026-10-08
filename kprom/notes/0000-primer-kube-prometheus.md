---
last_verified: 2026-10-08
tool_version: n/a
---

# Kube-Prometheus — quick primer

> First-day notes for someone who's never used Kube-Prometheus. Personal voice, plain language.

## What is it?

Kube-Prometheus is a Helm chart that installs a full monitoring stack onto a Kubernetes cluster: Prometheus for metrics, Alertmanager for alerts, and Grafana for dashboards, all wired together by the Prometheus Operator. If you've run the standalone Prometheus binary on one box, Kube-Prometheus is that same idea, but deployed as a Kubernetes-native, operator-managed, one-command install.

It's different from hand-writing a `prometheus.yml`. Instead of editing scrape configs and running containers yourself, you install a chart, pass it a values file, and the operator turns that into the right Custom Resources and keeps them in sync.

## What does it do?

It deploys the Prometheus Operator plus Prometheus, Alertmanager, node-exporter, kube-state-metrics, and Grafana as a single Helm release, and it provisions a set of curated cluster dashboards into Grafana automatically. It also ships default alerting rules for the control plane (kube-apiserver, kubelet, kube-scheduler, etcd) and node health. Each UI sits behind its own Service.

## Why does it exist?

Before this chart, running Prometheus in a cluster meant assembling the pieces yourself: install the operator, write a Prometheus custom resource, create Services and ServiceMonitors, configure Alertmanager, then install Grafana separately and point it at the right URL. The kube-prometheus-stack chart bundles all of that into one release so a monitoring stack goes from zero to running in a single `helm install`.

## Key terminology

- **Chart** — the kube-prometheus-stack package itself. Example: `helm install monitoring <chart-ref>`.
- **Prometheus Operator** — the controller that watches Prometheus/Alertmanager custom resources and reconciles the deployments. It is one component inside the kube-prometheus project, not the whole thing.
- **ServiceMonitor** — a custom resource telling the operator which pods to scrape and how. The chart creates ServiceMonitors for kubelet, kube-apiserver, etcd, and the other control-plane components for you.
- **Values file** — a YAML override passed with `-f` that flips the chart's defaults. Example: setting `grafana.service.type: NodePort` is what lets you reach Grafana from a laptop.
- **Release** — the running instance of the chart in your cluster. Example: `helm uninstall monitoring` removes everything the chart created.

## A tiny example

```bash
helm install monitoring <chart-ref> -f values-local.yaml
```

With a `values-local.yaml` that sets `prometheus.service.type`, `alertmanager.service.type`, and `grafana.service.type` to NodePort, this installs the whole stack in one release and exposes each UI on a node port.

## What I'll cover next

I want to install the stack on a local cluster, open Grafana to see which dashboards got provisioned, then look at the default alerting rules to understand how Alertmanager routes them.