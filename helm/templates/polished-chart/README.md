---
last_verified: 2026-10-19
tool_version: n/a
---

# polished-chart — Helm chart template

## Purpose

A reusable, polished Helm chart template that pairs a small, self-describing chart with JSON Schema validation of `values.yaml` and a rendered-manifest conformance step. It is meant as a starting point for application charts that want baseline shape validation before they reach a cluster, plus a gate that renders the chart and checks the resulting manifests against the target Kubernetes API.

## When to use

Use this template when scaffolding a new application chart that should reject invalid values early (at render or lint time, not at install time) and when you want a lightweight conformance check on rendered manifests. Skip it for one-off Helm installations that are never repackaged, or for charts that deliberately allow free-form values.

## Prerequisites

- Helm installed and on `PATH` (the `helm` binary).
- `helm template` run against a target namespace to render manifests.
- A JSON Schema validator to evaluate `values.schema.json` against `values.yaml`, or a pipeline step that performs the same check.
- kubeconform (or an equivalent conformance tool) available if the rendered-manifest gate is enabled.

## Steps

1. Copy `helm/templates/polished-chart/` into your chart location and rename `polished-chart` to your application name.
2. Edit `Chart.yaml`: set `name`, `description`, `version`, and `appVersion` for your application.
3. Edit `values.yaml` to carry your base defaults (replica count, image, service port, resources).
4. Keep `values.schema.json` in sync with `values.yaml`: every key written into `values.yaml` should be declared in the schema, and required keys must remain required.
5. Render the chart: `helm template <release> ./polished-chart -f values.yaml` and review the resulting `templates/deployment.yaml` and `templates/service.yaml` output.
6. Validate values against `values.schema.json` before installing.
7. Render to a directory and run kubeconform (or equivalent) against the rendered manifests in strict mode for the target Kubernetes version.

## Verify

- `helm lint ./polished-chart` reports no structural problems with `Chart.yaml`, `values.yaml`, and the templates.
- `helm template` produces valid YAML for `deployment.yaml` and `service.yaml`, and the image, port, and replica values appear where expected.
- A values file missing `replicaCount`, `image.repository`, `image.tag`, `service.type`, or `service.port` fails the JSON Schema validation.
- kubeconform in strict mode reports no errors against the rendered manifests for the configured Kubernetes version.

## Common errors

- `values.yaml` gains a key that `values.schema.json` does not declare: the schema rejects it with `additionalProperties` set to false. Add the key to the schema or remove it from values.
- `replicaCount` set to zero or a negative number fails the `minimum: 1` constraint.
- `image.pullPolicy` set to a value outside `Always`, `IfNotPresent`, `Never` fails the enum constraint.
- Rendered `containerPort` and `service.port` disagree: the service targets a port the container does not expose, so the Service sends traffic to a closed port.
- kubeconform flags a rendered CustomResourceDefinition: CRDs are not part of the core Kubernetes API schema kubeconform checks by default; skip them explicitly in the kubeconform configuration.

## References

- `helm/docs/helm-production-best-practices.md` — production-oriented Helm guidance this template complements.
- `helm/docs/helm-values-inheritance.md` — how base values and environment override files relate, which this template's `values.yaml` follows.
