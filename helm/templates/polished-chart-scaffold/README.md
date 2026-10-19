---
last_verified: 2026-10-19
tool_version: "3.13"
sources: []
---

# Polished Helm chart scaffold

## Purpose

This scaffold shows a single chart that is polished from the start: a `Chart.yaml` written to the schema, a `values.yaml` guarded by a JSON Schema so bad overrides fail at `helm lint` time, and a CI step that runs `kubeconform` over the rendered manifests. It is a step up from the `library-chart-scaffold` in that the validation is explicit and machine-checked rather than relying on the chart test pod alone.

## Layout

```
polished-chart-scaffold/
├── Chart.yaml                  ← schema-conformant chart metadata
├── values.yaml                 ← defaults
├── values.schema.json          ← JSON Schema for values.yaml
├── ci/
│   ├── staging-values.yaml     ← override used by the lint/test loop
│   └── kubeconform.sh          ← render + validate rendered manifests
└── templates/
    ├── _helpers.tpl            ← named templates
    ├── deployment.yaml
    ├── service.yaml
    └── tests/test-connection.yaml
```

## Chart.yaml schema

`Chart.yaml` follows the Helm chart schema. Required fields are `apiVersion` (v2), `name`, and `version`. Optional but recommended: `description`, `type` (`application` or `library`), `appVersion`, `annotations`, and `dependencies`. Validate with `helm lint` or against the schema published by the Helm project.

```yaml
# Chart.yaml
apiVersion: v2
name: polished-service
description: Example service chart with JSON Schema validation and kubeconform CI gate
type: application
version: 0.1.0
appVersion: "1.0.0"
annotations:
  category: service
  "helm.sh/validated": "kubeconform"
```

## values.yaml with JSON Schema

Keep defaults minimal and put environment differences in override files. The companion `values.schema.json` declares the contract:

```yaml
# values.yaml
replicaCount: 1
image:
  repository: myregistry.io/polished-service
  tag: "1.0.0"
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

```json
// values.schema.json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "title": "Polished Service Chart Values",
  "type": "object",
  "required": ["image", "service"],
  "properties": {
    "replicaCount": { "type": "integer", "minimum": 0 },
    "image": {
      "type": "object",
      "required": ["repository", "tag"],
      "properties": {
        "repository": { "type": "string" },
        "tag": { "type": "string" },
        "pullPolicy": { "type": "string" }
      }
    },
    "service": {
      "type": "object",
      "required": ["port"],
      "properties": {
        "type": { "type": "string", "enum": ["ClusterIP", "LoadBalancer", "NodePort"] },
        "port": { "type": "integer", "minimum": 1, "maximum": 65535 }
      }
    },
    "resources": { "type": "object" }
  }
}
```

`helm lint` checks values against this schema, so a string `replicaCount` or an unknown `service.type` fails before deploy.

## Kubeconform CI gate

Render the chart to YAML and validate every document against the Kubernetes schema using `kubeconform`. The CI script below does exactly that:

```bash
# ci/kubeconform.sh
#!/usr/bin/env bash
set -euo pipefail
CHART_DIR="$(cd "$(dirname "$0")/.." && pwd)"
helm template polished-service "$CHART_DIR" -f "$CHART_DIR/ci/staging-values.yaml" \
  | kubeconform -summary -ignore-missing-schemas
```

Run it locally before pushing:

```bash
chmod +x ci/kubeconform.sh
./ci/kubeconform.sh
```

A passing run means every rendered document matched a known Kubernetes schema. If a field is renamed or an API version is wrong, kubeconform reports the offending document and its kind.

## Templates

Templates stay environment-agnostic; only the values files carry environment differences.

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    {{- include "polished-service.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
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

```yaml
# templates/_helpers.tpl
{{- define "polished-service.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
```

## Verify

1. `helm lint ./` exits 0 and reports no schema violations.
2. `helm template polished-service ./ -f ./ci/staging-values.yaml` renders without errors.
3. `./ci/kubeconform.sh` exits 0 with every document summarised as valid.
4. `helm test polished-service` runs the test-connection pod and reports success.