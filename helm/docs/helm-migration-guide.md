---
last_verified: 2026-10-19
tool_version: n/a
sources:
---

# Helm migration guide

## Purpose

This guide covers what to review when moving Helm charts and releases to a newer Helm version, and the three areas that most often require changes: values merging behavior, chart storage in OCI-compatible registries, and library charts. It is a reference for planning an upgrade, not a step-by-step runbook for a specific cluster.

## When to use

Use this guide before upgrading Helm in an environment that already runs chart-based releases. It helps you identify which charts need updates, whether stored charts must be re-pushed, and whether library charts are consumed correctly after the move.

## Prerequisites

- A working Helm installation and access to the cluster where releases are deployed.
- A copy of the charts you plan to migrate, including their `Chart.yaml` and `values.yaml` files.
- Access to the chart registry or repository where charts are stored.

## Steps

### Review values merging

Check how each chart merges values from parent charts, imported values, and sub-charts. A change in merge order can silently alter which values win, so render each chart after the upgrade and compare the output against the previous release. Pay attention to charts that set values for a sub-chart from the parent `values.yaml`.

### Migrate stored charts to OCI

If charts are stored in an OCI-compatible registry, confirm the registry supports the chart protocol used by the target Helm version. Package charts with `helm package`, push them to the registry, and verify they can be pulled and installed. Charts stored in a legacy Helm repository can continue to be used as-is; migration to OCI is optional.

### Adopt library charts

Library charts define named templates that other charts reuse and are not installed on their own. Mark a library chart with `type: library` in `Chart.yaml`, place shared templates in `templates/` files that start with an underscore, and consume the library from an application chart by listing it under `dependencies` in `Chart.yaml` and running `helm dependency update`.

## Verify

- `helm lint` exits zero for every migrated chart.
- `helm template` renders each chart without errors and the rendered manifests match the previous release.
- Charts pulled from an OCI registry install and upgrade cleanly.
- Library charts load their named templates and consuming charts render without missing template errors.

## Common errors

- Values that worked before the upgrade render differently after the merge-order change; compare rendered output before and after.
- A chart pushed to an OCI registry fails to pull if the registry reference includes a tag or basename; the chart name and version are inferred from `Chart.yaml`.
- A library chart marked `type: application` can be installed directly, which defeats its purpose; use `type: library` for shared templates only.
- `helm dependency update` must run after changing `dependencies` in `Chart.yaml`, or the `charts/` directory is stale.
