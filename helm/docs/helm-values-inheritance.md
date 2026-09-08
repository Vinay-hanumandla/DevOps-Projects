---
last_verified: 2026-09-08
tool_version: "3.x"
sources: []
---

# How I wired Helm values inheritance and environment overrides into microservice releases

## Purpose

When deploying the same microservice across dev, staging, and prod, the chart structure stays identical — only the values change. The goal is a single chart directory with a shared `values.yaml` baseline and per-environment override files that layer on top. This avoids duplicating charts while keeping environment differences explicit.

## The inheritance model

Helm merges values in a specific order. The base `values.yaml` in the chart root is always loaded first. When you pass `-f values-staging.yaml`, every key in that override file wins over the base. Passing multiple `-f` flags applies them left to right, so later files win over earlier ones.

```
values.yaml              ← defaults (always loaded)
  ↑ overridden by
values-dev.yaml          ← dev-specific
  ↑ overridden by
values-staging.yaml      ← staging-specific
  ↑ overridden by
values-prod.yaml         ← prod-specific
  ↑ overridden by
--set key=value          ← CLI flags win last
```

This means the base file should hold safe, minimal defaults. Environment files only carry what differs.

## Chart directory layout

```
charts/my-service/
├── Chart.yaml
├── values.yaml                 ← base defaults
├── values-dev.yaml             ← dev overrides
├── values-staging.yaml         ← staging overrides
├── values-prod.yaml            ← prod overrides
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    └── ...
```

## Base values — keeping it lean

The base `values.yaml` should define structure without hardcoding environment-specific behavior. Replicas, resource limits, and image tags are the usual candidates for per-environment overrides.

```yaml
# values.yaml
replicaCount: 1
image:
  repository: myregistry.io/my-service
  tag: "latest"
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 8080
resources:
  limits:
    cpu: 250m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

The template references these with `{{ .Values.replicaCount }}`, `{{ .Values.image.tag }}`, and so on. No environment logic lives in the templates themselves.

## Per-environment overrides

Each environment file only contains the keys that differ from the base. Helm does a deep merge, so you can override nested keys without repeating the entire tree.

```yaml
# values-staging.yaml
replicaCount: 2
image:
  tag: "v1.4.2-rc1"
resources:
  limits:
    cpu: 500m
    memory: 512Mi
```

```yaml
# values-prod.yaml
replicaCount: 4
image:
  tag: "v1.4.1"
  pullPolicy: Always
service:
  type: LoadBalancer
resources:
  limits:
    cpu: "1"
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

Notice that `values-prod.yaml` doesn't repeat the full `service` block — it only changes `type`. The `port: 8080` from the base carries through untouched.

## Wiring it into the release command

The `-f` flag order matters. Pass the environment file last so it wins over any shared overrides:

```bash
helm upgrade --install my-service ./charts/my-service \
  --namespace staging \
  -f values-staging.yaml \
  --wait
```

For CI pipelines, the workflow script (`helm/scripts/helm-release-workflow.sh`) accepts `-e staging` and automatically appends `-f values-staging.yaml`:

```bash
./helm-release-workflow.sh \
  --chart ./charts/my-service \
  --namespace staging \
  --release my-service \
  --env staging \
  --wait
```

## Templates that read the values

Templates stay environment-agnostic. The only place environment awareness shows up is in the values files themselves.

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
        - name: {{ .Release.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.port }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

If a value is missing in the override file, Helm falls back to the base. If it's missing everywhere, the template will fail at render time — which `helm lint` and `helm template` catch before you deploy.

## What I hit along the way

A few patterns that tripped me up:

- **YAML indentation in override files.** An override with wrong indentation silently merges at the wrong level. Running `helm template` locally before deploying saved me from shipping a broken values file to staging.

- **Overriding list values.** Helm replaces entire list entries rather than appending. If the base has `ingress.hosts: [a, b]` and the override has `ingress.hosts: [c]`, the result is just `[c]` — not `[a, b, c]`. For lists, the override needs to be complete.

- **Secrets in values files.** I keep sensitive values out of the committed override files. Instead, they come from sealed-secrets or are injected via `--set` at deploy time. The override files only carry non-sensitive configuration.

## How this connects to what's next

This values layering pattern scales naturally to multi-service releases. When you have shared infrastructure charts (ingress controller, monitoring stack), the same `-f` override strategy applies — a shared `values-common.yaml` plus per-environment overrides. The next step is wiring this into a CI pipeline where the environment selection is driven by branch name or Git tags.
