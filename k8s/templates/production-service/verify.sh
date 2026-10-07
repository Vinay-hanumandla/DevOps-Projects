#!/usr/bin/env bash
# last_verified: 2026-10-07 · kubernetes n/a
# verify.sh — dry-run the production-service Kustomization without touching a cluster.
set -euo pipefail

if ! command -v kubectl >/dev/null 2>&1; then
  echo "SKIP: kubectl not found; cannot dry-run the Kustomization." >&2
  exit 0
fi

rendered="$(kubectl kustomize . 2>/dev/null || kubectl apply -k . --dry-run=client -o yaml 2>/dev/null || true)"
if [ -z "${rendered}" ]; then
  echo "FAIL: kustomize render produced no output." >&2
  exit 1
fi

for kind in Deployment Service ServiceAccount HorizontalPodAutoscaler PodDisruptionBudget NetworkPolicy ResourceQuota LimitRange; do
  if ! grep -q "kind: ${kind}" <<<"${rendered}"; then
    echo "FAIL: rendered output is missing kind: ${kind}." >&2
    exit 1
  fi
done

echo "OK: Kustomization renders all 8 expected resource kinds."
