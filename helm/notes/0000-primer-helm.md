---
last_verified: 2026-07-31
tool_version: n/a
---

# Helm — quick primer

> First-day notes for someone who's never used Helm. Personal voice, plain language.

## What is it?

Helm is a package manager for Kubernetes. If you've used `apt` or `npm` to install software on a Linux box or a Node project, Helm does something similar but for Kubernetes applications. It lets you define, install, and upgrade complex Kubernetes applications using charts — bundles of pre-configured Kubernetes resources.

## What does it do?

Helm takes a chart (a collection of YAML templates and values) and renders it into Kubernetes manifests, then applies them to a cluster. It tracks what's been deployed so you can upgrade, roll back, or uninstall the same way you'd update a package on your laptop.

## Why does it exist?

Before Helm, deploying an application on Kubernetes meant manually writing Deployments, Services, ConfigMaps, and Ingress objects — and keeping those files in sync across dev, staging, and prod. Helm wraps all of that into a single reusable chart so you install a chart and get the whole application stack at once.

## Key terminology

- **Chart** — a Helm package containing templates and default values. Example: `helm install myapp ./mychart/` renders and deploys everything in that chart.
- **Release** — a running instance of a chart in a cluster. Example: installing the same chart twice with different names gives you two releases.
- **Values file** — a YAML file that overrides the chart's defaults. Example: `helm install myapp ./mychart/ -f custom-values.yaml` sets custom config.
- **Repository** — a hosted collection of charts Others can use. Example: `helm repo add stable https://charts.helm.sh/stable` adds a public repo.
- **Helmfile** — a declarative file that lists multiple releases to deploy. Example: a `helmfile.yaml` declares all infra apps in one place.
- **Dependency** — a chart can depend on other charts. Example: your app chart might depend on a Redis chart and a PostgreSQL chart.

## A tiny example

```bash
helm repo add stable https://charts.helm.sh/stable
helm repo update
helm install my-nginx stable/nginx-ingress --namespace ingress --create-namespace
helm version
```

This adds a chart repository, refreshes the local cache, and installs the nginx ingress controller into a new namespace.

## What I'll cover next

I want to dig into writing my own chart from scratch and understanding how template values interact between `values.yaml` and the chart templates. After that, I plan to explore Helm hooks and dependency management for more complex deployments.