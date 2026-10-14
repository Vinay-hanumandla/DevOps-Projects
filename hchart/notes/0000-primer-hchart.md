---
last_verified: 2026-10-14
tool_version: n/a
sources: []
---

# Helm Charts — quick primer

> First-day notes for someone who's never used Helm Charts. Personal voice, plain language.

## What is it?

Helm Charts is the packaging format for Kubernetes applications. If you've used apt, yum, or Homebrew for installing software on Linux/macOS, Helm Charts is that same idea but for Kubernetes clusters. It bundles all the YAML manifests (Deployments, Services, ConfigMaps, Secrets, etc.) needed to run an application into a single versioned package called a "chart." You install a chart with `helm install`, and it renders the templates with your values and applies them to the cluster.

## What does it do?

It lets you define a Kubernetes application once as a collection of templated YAML files, parameterize the bits that change between environments (replica counts, image tags, resource limits, ingress hosts), and then install or upgrade that application with a single command. Charts can depend on other charts (e.g., your app chart depends on a PostgreSQL chart), and Helm handles the dependency graph. You can also pull public charts from repositories like Artifact Hub, customize them with your own values file, and publish your own charts to a chart repository (an HTTP server with an index.yaml).

## Why does it exist?

Before Helm, you either copy-pasted YAML files between projects and manually edited names/image tags for each environment, or you wrote custom scripts to sed/awk your manifests. Both approaches break down as the number of services and environments grows. Helm gives you a standard template engine (Go templates + Sprig functions), a release tracking system (so you can roll back), and a distribution mechanism (chart repos). Day-to-day users are platform engineers packaging internal services, DevOps teams deploying third-party operators (Prometheus, Kafka, databases), and anyone running Kubernetes who wants repeatable, versioned deployments.

## Key terminology

- **Chart** — the package itself: a directory with `Chart.yaml`, `values.yaml`, `templates/`, and optionally `charts/` for dependencies. Example: `my-app-0.3.1.tgz`.
- **Release** — a specific installation of a chart in a cluster, with a name and revision history. Example: `helm install my-release ./my-app` creates release `my-release` revision 1.
- **Values** — the configurable parameters exposed by a chart, defined in `values.yaml` and overridden at install time with `-f my-values.yaml` or `--set key=value`. Example: `replicaCount: 3`.
- **Template** — a Go template file in `templates/` that renders to a Kubernetes manifest when combined with values. Example: `templates/deployment.yaml` uses `.Values.image.repository`.
- **Chart.yaml** — metadata file declaring the chart name, version, appVersion, description, and dependencies. Example: `name: my-app`, `version: 0.3.1`.
- **Repository** — an HTTP server hosting chart packages and an `index.yaml` index. Example: a chart museum instance or GitHub Pages site serving an `index.yaml`.
- **Hook** — a special annotation on a manifest that runs at a specific point in the release lifecycle (pre-install, post-upgrade, etc.). Example: a Job that runs DB migrations before a new version starts.
- **Library chart** — a chart with no templates, only reusable template helpers (e.g., common labels, naming conventions) shared via `chart.yaml` dependencies. Example: `common` chart used by all internal service charts.

## A tiny example

```yaml
# Chart.yaml
apiVersion: v2
name: hello-world
description: A tiny demo chart
version: 0.1.0
appVersion: "1.0.0"
```

```yaml
# values.yaml
replicaCount: 1
image:
  repository: nginx
  tag: "1.25"
service:
  port: 80
```

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-hello
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}-hello
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}-hello
    spec:
      containers:
        - name: hello
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
```

Run `helm install demo ./hello-world` — this renders the template with the values, creates a release named `demo`, and applies the Deployment to the cluster.

## What I'll cover next

I want to explore a public chart's structure to see how real charts organize templates, helpers, and tests. Then I'll build my own minimal chart with a proper `Chart.yaml` and `values.yaml` for a simple web service, and try installing it to a local cluster.