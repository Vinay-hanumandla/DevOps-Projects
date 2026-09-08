#!/usr/bin/env bash
# last_verified: 2026-09-08 · Helm 3.x
set -Eeuo pipefail

#
# helm-release-workflow.sh
# A reusable release workflow: lint → template → diff → upgrade → (optional) rollback.
# Designed for CI pipelines or manual releases where you want each gate to pass
# before the next step runs.
#

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Required:
  -c, --chart PATH        Path to the chart directory
  -n, --namespace NS      Kubernetes namespace
  -r, --release NAME      Helm release name

Optional:
  -f, --values FILE       Extra values file (can be repeated)
  -e, --env ENV           Environment name (dev|staging|prod) — selects values-<env>.yaml
  -s, --skip-diff         Skip the diff step (useful when helm-diff is not installed)
  -w, --wait              Wait for pods to be ready after upgrade
      --atomic            Use --atomic on upgrade (auto-rollback on failure)
      --dry-run           Render and validate only — do not apply
      --rollback-to REV   Roll back to a specific revision and exit
  -h, --help              Show this help
EOF
}

CHART=""
NAMESPACE=""
RELEASE=""
VALUES_FILES=()
ENV_NAME=""
SKIP_DIFF=false
WAIT=false
ATOMIC=false
DRY_RUN=false
ROLLBACK_TO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--chart)    CHART="$2";          shift 2 ;;
    -n|--namespace) NAMESPACE="$2";     shift 2 ;;
    -r|--release)  RELEASE="$2";        shift 2 ;;
    -f|--values)   VALUES_FILES+=("$2"); shift 2 ;;
    -e|--env)      ENV_NAME="$2";       shift 2 ;;
    -s|--skip-diff) SKIP_DIFF=true;     shift ;;
    -w|--wait)     WAIT=true;           shift ;;
    --atomic)      ATOMIC=true;         shift ;;
    --dry-run)     DRY_RUN=true;        shift ;;
    --rollback-to) ROLLBACK_TO="$2";    shift 2 ;;
    -h|--help)     usage; exit 0 ;;
    *)             echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$CHART" || -z "$NAMESPACE" || -z "$RELEASE" ]]; then
  echo "ERROR: --chart, --namespace, and --release are required." >&2
  usage >&2
  exit 1
fi

if [[ ! -d "$CHART" ]]; then
  echo "ERROR: Chart directory not found: $CHART" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] $*"; }
fail() { echo "[$(date -u '+%Y-%m-%dT%H:%M:%SZ')] FAIL: $*" >&2; exit 1; }

# Build the common helm arguments array
build_helm_args() {
  local args=()
  args+=("$CHART")
  args+=(--namespace "$NAMESPACE")
  args+=(--release-name "$RELEASE")
  for vf in "${VALUES_FILES[@]}"; do
    args+=(-f "$vf")
  done
  if [[ -n "$ENV_NAME" ]]; then
    args+=(-f "${CHART}/values-${ENV_NAME}.yaml")
  fi
  echo "${args[@]}"
}

# ---------------------------------------------------------------------------
# Rollback shortcut — if --rollback-to is set, skip everything else
# ---------------------------------------------------------------------------
if [[ -n "$ROLLBACK_TO" ]]; then
  log "Rolling back release '$RELEASE' to revision $ROLLBACK_TO ..."
  helm rollback "$RELEASE" "$ROLLBACK_TO" --namespace "$NAMESPACE" --wait
  log "Rollback complete."
  exit 0
fi

# ---------------------------------------------------------------------------
# Step 1 — Lint
# ---------------------------------------------------------------------------
log "Step 1/5: Linting chart ..."
helm lint "$CHART" --namespace "$NAMESPACE"
log "Lint passed."

# ---------------------------------------------------------------------------
# Step 2 — Template (local render to catch template errors)
# ---------------------------------------------------------------------------
log "Step 2/5: Templating chart locally ..."
HELM_ARGS=$(build_helm_args)
# shellcheck disable=SC2086
helm template $HELM_ARGS > /dev/null
log "Template render succeeded."

# ---------------------------------------------------------------------------
# Step 3 — Diff (optional, requires helm-diff plugin)
# ---------------------------------------------------------------------------
if [[ "$SKIP_DIFF" == "false" ]]; then
  if helm plugin list 2>/dev/null | grep -q '^diff'; then
    log "Step 3/5: Diffing against current release ..."
    # shellcheck disable=SC2086
    helm diff upgrade $HELM_ARGS --namespace "$NAMESPACE" || true
    log "Diff complete (review output above)."
  else
    log "Step 3/5: helm-diff plugin not installed — skipping."
  fi
else
  log "Step 3/5: Diff skipped (--skip-diff)."
fi

# ---------------------------------------------------------------------------
# Step 4 — Upgrade (--install for idempotent apply)
# ---------------------------------------------------------------------------
UPGRADE_ARGS=()
UPGRADE_ARGS+=(--namespace "$NAMESPACE")
UPGRADE_ARGS+=(--install)
UPGRADE_ARGS+=(--create-namespace)
if [[ "$WAIT" == "true" ]]; then
  UPGRADE_ARGS+=(--wait)
fi
if [[ "$ATOMIC" == "true" ]]; then
  UPGRADE_ARGS+=(--atomic)
fi
if [[ "$DRY_RUN" == "true" ]]; then
  UPGRADE_ARGS+=(--dry-run)
fi
for vf in "${VALUES_FILES[@]}"; do
  UPGRADE_ARGS+=(-f "$vf")
done
if [[ -n "$ENV_NAME" ]]; then
  UPGRADE_ARGS+=(-f "${CHART}/values-${ENV_NAME}.yaml")
fi

log "Step 4/5: Upgrading release ..."
# shellcheck disable=SC2086
helm upgrade "$RELEASE" "$CHART" ${UPGRADE_ARGS[@]+"${UPGRADE_ARGS[@]}"}
log "Upgrade succeeded."

# ---------------------------------------------------------------------------
# Step 5 — Verify (status check)
# ---------------------------------------------------------------------------
log "Step 5/5: Checking release status ..."
helm status "$RELEASE" --namespace "$NAMESPACE"
log "Release '$RELEASE' is deployed in namespace '$NAMESPACE'."
