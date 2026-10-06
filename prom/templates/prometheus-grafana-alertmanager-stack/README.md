---
last_verified: 2026-10-06
tool_version: n/a
---

# Prometheus + Grafana + Alertmanager stack scaffold

## Purpose

A single-command local monitoring stack: Prometheus scraping itself and Alertmanager, alert and recording rules loaded from files, Alertmanager routing alerts to a webhook receiver, and Grafana provisioned with a Prometheus datasource plus a stack-overview dashboard. Everything the three tools need is mounted from this directory, so the stack is reproducible from a clean checkout with no manual setup in the UIs.

## When to use

- Learning how recording rules, alert rules, and Alertmanager routing fit together on a live stack.
- A starting point for a project monitoring setup where Grafana datasources and dashboards are provisioned as files rather than configured by hand.
- Trying PromQL or rule syntax against a running server before porting it to another environment.

This scaffold deliberately leaves out multi-host service discovery, HA, remote write, and long-term storage — those are separate decisions this layout does not make.

## Prerequisites

- Docker Engine with the compose plugin (`docker compose version`).
- Free local ports 3000 (Grafana), 9090 (Prometheus), and 9093 (Alertmanager).

## Layout

```
prometheus-grafana-alertmanager-stack/
├── docker-compose.yaml            # prometheus, alertmanager, grafana services
├── .env.example                   # Grafana admin credentials
├── prometheus/
│   ├── prometheus.yml             # scrape jobs, rule_files, alerting endpoint
│   └── rules/
│       ├── recording-rules.yml    # pre-computed rate series the dashboard queries
│       └── alert-rules.yml        # alerts routed to Alertmanager
├── alertmanager/
│   └── alertmanager.yml           # route tree and webhook receiver
└── grafana/
    ├── provisioning/
    │   ├── datasources/datasources.yaml
    │   └── dashboards/dashboards.yaml
    └── dashboards/stack-overview.json
```

## Steps

1. Copy the environment file and set the Grafana credentials: `cp .env.example .env`.
2. Start the stack: `docker compose up -d`.
3. Open http://localhost:3000 and sign in with the credentials from `.env`. The Prometheus datasource and the "Stack Overview" dashboard are already provisioned under the `Stack` folder.
4. Check Prometheus at http://localhost:9090 — *Status → Rules* lists the `prometheus-self-recording` and `stack-health` groups; *Status → Targets* lists the `prometheus` and `alertmanager` jobs.
5. Check Alertmanager at http://localhost:9093 — the UI shows the configured route tree and receiver.

## Verify

```bash
curl -fsS http://localhost:9090/-/ready          # Prometheus is Ready.
curl -fsS http://localhost:9093/-/ready          # Alertmanager is ready.
curl -fsS http://localhost:3000/api/health       # {"database":"ok", ...}

# Both rule groups are loaded:
curl -fsS http://localhost:9090/api/v1/rules | jq '.data.groups[].name'

# Recording rule output appears after the first evaluation interval (~1 min):
curl -fsS 'http://localhost:9090/api/v1/query?query=job:prometheus_http_requests_total:rate5m'
```

To exercise the alert path end to end: `docker compose stop alertmanager`, wait for the `prometheus` job's `up` to drop (five minutes, matching the `for` in `alert-rules.yml`), then check `docker compose logs alertmanager` for the delivery attempt to the placeholder webhook receiver. `docker compose start alertmanager` restores the scrape target.

## Common errors

- **`found no rule files` in the Prometheus logs** — `rule_files` paths are resolved inside the container, so they must be `/etc/prometheus/rules/...`, not the host-relative paths.
- **Grafana datasource fails with a connection error** — the provisioned URL is `http://prometheus:9090`, the compose service name. Using `localhost:9090` there points back into the Grafana container itself.
- **Dashboard panels show "No data"** — the panel datasource `uid` (`prometheus-stack`) must match the provisioned datasource `uid`, and recording-rule panels need one evaluation interval before the recorded series exists.
- **Alerts never fire** — `for: 5m` means the condition must hold for five minutes, not one evaluation. A target down for less than that stays pending.
- **Webhook delivery errors in the Alertmanager logs** — the scaffold ships a placeholder receiver URL (`http://localhost:5001/alerts`). Point it at a real endpoint, or expect failed deliveries (which is exactly what the `AlertmanagerNotificationsFailing` rule measures).

## Teardown

`docker compose down -v` removes the containers and the named Grafana storage volume; the scaffold files themselves are untouched.
