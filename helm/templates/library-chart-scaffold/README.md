---
last_verified: 2026-09-26
tool_version: "n/a"
---

# Helm chart scaffold — library chart pattern, values schema, and chart testing

## Purpose

When several services share the same rendering conventions, copying a `_helpers.tpl` file from chart to chart drifts within weeks. This scaffold shows one way to stop that: a `lib-common` library chart holding the named templates, an application chart (`web-api`) consuming them, a `values.schema.json` that rejects bad overrides early, and a test-hook pod so `helm test` confirms the release answers after install. The docs also suggest packaging the library and publishing it, but a local `file://` dependency is the simpler starting point used here.

## Layout

```
library-chart-scaffold/
├── lib-common/                  ← type: library, no workloads of its own
│   ├── Chart.yaml
│   ├── values.yaml              ← defaults-as-documentation
│   └── templates/_helpers.tpl   ← lib-common.labels, lib-common.fullname, lib-common.image
└── app/                         ← type: application, consumes lib-common
    ├── Chart.yaml               ← file://../lib-common dependency
    ├── values.yaml
    ├── values.schema.json       ← replicaCount, image, service constraints
    ├── ci/staging-values.yaml   ← override used by the test loop below
    └── templates/
        ├── deployment.yaml      ← rendered via lib-common includes
        ├── service.yaml
        └── tests/test-connection.yaml  ← helm.sh/hook: test pod
```

## Steps

1. Copy the whole `library-chart-scaffold/` directory next to the service being charted and rename `app/` to the service name.
2. Update the dependency in `app/Chart.yaml` if the library moves, then refresh the local dependency lock so the chart directory carries a usable `charts/` subdirectory.
3. Adjust `app/values.yaml` for the service. Keep every key inside what `values.schema.json` allows — required keys are `image.repository`, `image.tag`, and `service.port`; `service.type` is limited to the three listed enum values.
4. Put per-environment differences in files shaped like `app/ci/staging-values.yaml` (only differing keys, relying on deep merge) rather than editing the base values.
5. Extend `templates/tests/` with one hook pod per check that matters after install (connectivity first, then anything service-specific).

## Verify

Render and lint before installing anything:

```bash
helm lint ./app
helm template web-api ./app -f ./app/ci/staging-values.yaml
```

`helm lint` also checks values against `values.schema.json`, so an override that breaks the schema — a string `replicaCount`, a missing `service.port`, an unknown `service.type` — fails here instead of at deploy time. To see the schema working, temporarily set `replicaCount: "two"` in a copy of the values and re-run lint; the run should fail, and restoring the integer makes it pass again.

After installing the release, run the chart test:

```bash
helm test web-api
```

A passing run means the test-connection pod reached the Service on the configured port. If the pod fails, describing it usually points at either a wrong port in values or the Service selector not matching the Deployment labels.
