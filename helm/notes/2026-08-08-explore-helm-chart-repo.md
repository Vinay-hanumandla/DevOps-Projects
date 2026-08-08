---
last_verified: 2026-08-08
tool_version: n/a
---
# Exploring the Helm chart repository and chart structure

> First-day notes on browsing a Helm chart repo and poking at chart internals.

## What I found

I opened the official Helm Hub and picked a simple chart to inspect. The repository is a static site with an `index.yaml` that lists every available chart, version, and download URL.

Downloading a chart with `helm pull` gave me a tarball. Extracting it showed the same layout every chart uses:

```
Chart.yaml          — metadata (name, version, description)
values.yaml         — default configurable values
charts/             — sub-chart dependencies
templates/          — Kubernetes manifest templates
README.md           — chart docs
```

`Chart.yaml` is the chart manifest. `values.yaml` holds defaults you can override. The `templates/` folder contains Go-templated YAML that renders into actual K8s manifests.

## What tripped me up

I tried editing `values.yaml` directly, but then realized Helm treats this as the base defaults file. The usual workflow is to supply a separate override file that only contains the keys you want to change.

## What I'll try next

Create a values override file and run `helm install` with it to see the rendered output.