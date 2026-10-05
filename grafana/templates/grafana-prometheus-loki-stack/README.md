---
last_verified: 2026-10-05
tool_version: n/a
---

# Grafana + Prometheus + Loki observability stack scaffold

## Purpose

A starting point for running metrics and logs side by side on a single
machine: Prometheus scrapes the stack itself, Promtail ships host log files
into Loki, and Grafana provisions both datasources plus a starter dashboard
automatically at first boot.

## When to use

Use this scaffold when a service needs a local place to check a metric graph
and the matching log lines together — for example, confirming a latency spike
in Prometheus while reading the surrounding application logs in Loki. It is
a development scaffold, not a hardened deployment: storage is local named
volumes, auth is a single admin login, and retention is effectively
unbounded until limits are configured.

## Prerequisites

- A container runtime with Compose support.
- Ports 3000, 9090, 3100, and 9080 free on the host.
- Read access to the host log directory mounted by the promtail service.

## Steps

1. Copy the scaffold and choose an admin password:
   `GRAFANA_ADMIN_PASSWORD=<chosen-password> docker compose up -d`
   Omitting the variable keeps the placeholder default, which is only
   acceptable on a laptop.
2. Wait for all four services to report healthy, then open Grafana on port
   3000 and sign in with the admin credentials.
3. Confirm both provisioned datasources answer: the Prometheus datasource
   points at the prometheus service, the Loki datasource at the loki
   service. The hostnames are Compose service names and resolve on the
   default Compose network.
4. Open the "Stack overview" dashboard in the Stack folder. The stat panel
   runs a Prometheus `up` query against the stack itself; the logs panel
   queries the label Promtail attaches to shipped host logs.
5. Before using the scaffold beyond local work, pin each image to an
   explicit tag or digest, set a retention policy in the Loki limits, and
   replace the default admin password handling with the environment's
   secret mechanism.

## Verify

- `docker compose ps` shows grafana, prometheus, loki, and promtail
  running.
- The Prometheus target page on port 9090 lists the prometheus, grafana,
  and loki jobs as up.
- The Grafana Explore view returns log lines for the `{job="varlogs"}`
  query once the host log directory contains matching files.

## Common errors

| Symptom | Cause | Fix |
|---|---|---|
| Dashboard panels show "datasource not found" | Datasource provisioning file edited without matching UIDs | Keep the `uid` fields in `datasources.yaml` identical to the `uid` values in the dashboard JSON |
| Loki returns no logs | Promtail cannot reach Loki or has no files to read | Check that the loki service is up first, then that the mounted log directory exists and contains files matching the configured path pattern |
| Grafana login rejected after changing the password variable | Admin password is set only on first volume initialisation | Remove the grafana-data volume and start fresh, or change the password in the UI instead |

## References

- `docker-compose.yaml` — service wiring, ports, and volume mounts.
- `prometheus/prometheus.yaml` — scrape jobs for the three HTTP services.
- `loki/loki-config.yaml` — single-binary local Loki configuration.
- `promtail/promtail-config.yaml` — host log shipping to Loki.
- `grafana/provisioning/` — provisioned Prometheus and Loki datasources
  plus the dashboard provider.
- `grafana/dashboards/overview.json` — starter dashboard provisioned on
  first boot.
