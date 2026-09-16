---
last_verified: 2026-09-16
tool_version: n/a
sources: []
---
# How I wired Grafana into a Prometheus + Alertmanager on-call pipeline

## Purpose

Grafana alone shows dashboards, but it doesn't wake someone up at 3am when a metric drops. This doc records how I connected Grafana to a Prometheus metrics source and routed alerts through Alertmanager so that a firing rule reaches an on-call engineer by email and Slack.

## Components and their roles

- **Prometheus** scrapes targets and stores time-series metrics. Grafana queries it with PromQL.
- **Grafana** visualizes the data and hosts the alerting rule definitions in dashboard panels.
- **Alertmanager** receives notifications from Grafana, deduplicates alerts, groups them, and routes them to receivers (email, Slack, PagerDuty).

## Wiring Prometheus to Grafana

Add Prometheus as a data source in Grafana:

1. Open Configuration → Data sources → Add data source → Prometheus.
2. Set the URL to the Prometheus server's address (for example, a container
   hostname like `prometheus:9090` on a Docker network, or the node port if
   Prometheus is deployed on a host). Save. Test the connection — Grafana runs
   a small query against the data source's status endpoint.

Once the data source is healthy, dashboards built on Prometheus panels will show live data.

## Defining alerting rules

Grafana's unified alerting lets you write rules directly in the UI:

1. Open the dashboard containing the panel you want to alert on.
2. Click the panel title → Edit → Alert.
3. Set the evaluation interval, the PromQL expression, and the threshold.
4. Define labels (e.g. `severity: critical`) and annotations (e.g. a description with `{{ $values.B }}`).

Rules can also be exported as YAML from the Alerting → Alert rules page and version-controlled alongside the rest of the repo.

## Routing alerts through Alertmanager

Configure an Alertmanager contact point in Grafana:

1. Go to Alerting → Contact points → New contact point.
2. Choose a type (Email, Slack, etc.) and fill in the details.
3. Optionally add an integration webhook that points at an Alertmanager instance.

Grafana can either manage alerting entirely on its own, or hand off to a standalone Alertmanager via a webhook integration. The standalone approach is useful when multiple teams share one Alertmanager.

## Notification policies

Under Alerting → Notification policies, define how grouped alerts get routed:

- A `group_by` field (e.g. `alertname`, `severity`) controls which alerts are batched together.
- A `group_wait` field (e.g. `30s`) delays the first notification so more related alerts can be bundled.
- A `group_interval` field (e.g. `5m`) controls how often repeat notifications are sent.
- Each policy maps to a matcher and a receiver.

## Verify the pipeline

1. Create a test rule with a threshold that is already breached. It should fire within one evaluation cycle.
2. Check Alerting → Alert rules for a `Firing` state.
3. Check the Alertmanager UI (or the contact point's receiver) for the received notification.

## Common pitfalls

- **Alertmanager URL mismatch.** The webhook integration URL must match the
  Alertmanager's external URL. A trailing slash or wrong scheme silently drops
  alerts.
- **Labels don't propagate.** Labels set on a Grafana rule are not automatically
  forwarded to Alertmanager. Add them explicitly in the rule's labels block.
- **Grouping too aggressively.** Grouping everything by `alertname` can hide the
  fact that the same alert is firing in multiple regions. Include `region` or
  `instance` in the group key.