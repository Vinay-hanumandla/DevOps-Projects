# Changelog

All notable changes to this kit are documented here. The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

- **2026-10-19** — Added `helm/docs/helm-3.13-migration-guide.md` (Helm 3.13+ migration guide covering values precedence change, OCI registry support, and library charts). Added `helm/templates/polished-chart-scaffold/` (Chart.yaml, values.yaml, values.schema.json, ci/staging-values.yaml, ci/kubeconform.sh, templates/_helpers.tpl, templates/deployment.yaml, templates/service.yaml, templates/tests/test-connection.yaml, README.md) — a schema-validated chart scaffold with a kubeconform CI gate.