---
last_verified: 2026-09-19
tool_version: n/a
---

# Multi-service app scaffold — Helm chart, ingress, and monitoring

## Purpose

A starting point for a small web app made of two services: a static frontend and a backend API. The scaffold ships as one Helm chart plus an ingress definition and a set of Prometheus alert rules, so routing and basic monitoring come up together with the workloads instead of being bolted on later.

## When to use

Use this when a team needs a runnable two-tier example to try out chart values, ingress hosts, and scrape annotations in a throwaway namespace. It is one way to lay out the pieces; some teams prefer one chart per service or a shared library chart, and the docs also suggest Kustomize overlays as an alternative for plain-manifest workflows.

## Prerequisites

- A cluster you can write to, with an ingress controller already installed and a matching `ingressClassName`.
- The Helm CLI and `kubectl`, both pointed at that cluster.
- Container images for the frontend and backend pushed to a registry you can pull from; the default `values.yaml` entries are placeholders.

## Steps

1. Copy this directory out of the kit and point the images at real ones:

   ```bash
   cp -r multi-service-app ~/my-app
   cd ~/my-app
   ```

   Edit `values.yaml`: set `frontend.image`, `backend.image`, and `ingress.host` to real values.

2. Render the chart locally first and check the output looks right:

   ```bash
   helm template my-app . -f values.yaml
   ```

3. Install into a scratch namespace:

   ```bash
   kubectl create namespace demo
   helm install my-app . --namespace demo -f values.yaml
   ```

4. Load the alert rules in `monitoring/prometheus-rules.yaml` into Prometheus (via a ConfigMap referenced under `rule_files`). The chart's Services already carry `prometheus.io/scrape` annotations, so a Prometheus using Kubernetes service discovery starts collecting `up`, request-rate, and latency series with no extra wiring.

5. Point a browser or curl at the ingress host:

   ```bash
   curl http://app.example.local/
   curl http://app.example.local/api/healthz
   ```

   (Replace the host with whatever `ingress.host` is set to, and make sure it resolves to the ingress controller address.)

## Verify

- `kubectl --namespace demo rollout status deployment/my-app-frontend` reports a successful rollout, and the same for `my-app-backend`.
- `kubectl --namespace demo get ingress` shows the host from `values.yaml` with an address assigned.
- In Prometheus, the `up` series for both services is `1`, and the `ServiceDown` alert from the rules file is loaded but not firing.
