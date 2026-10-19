#!/usr/bin/env bash
# last_verified: 2026-10-19 · Helm 3.13
# Render the chart to YAML and validate every document with kubeconform.
set -euo pipefail
CHART_DIR="$(cd "$(dirname "$0")/.." && pwd)"
helm template polished-service "$CHART_DIR" \
  -f "$CHART_DIR/ci/staging-values.yaml" \
  | kubeconform -summary -ignore-missing-schemas