#!/usr/bin/env bash
# last_verified: 2026-09-18 · Docker n/a
set -euo pipefail

# docker-019 — Image vulnerability scan and policy enforcement with Trivy and Cosign
# Level: L4 | Output: script(bash)
#
# Purpose: scan one image with Trivy, fail the run when findings breach the
#   severity policy, then verify the image signature with Cosign so only
#   scanned-and-signed images are promoted.
# When to use: as a CI gate before pushing to a shared registry or deploying.
#   This is one way to wire the two tools together; registries with built-in
#   scanning may already cover part of this.
#
# Steps:
#   1. Trivy scans the image and writes a table report plus a machine-readable report.
#   2. The script counts findings at or above the policy severities and fails if any exist.
#   3. Cosign verifies the image signature (key-based or keyless, per flags).
# Verify: exit 0 prints POLICY PASS and the report paths; any policy breach or
#   failed verification exits non-zero with the offending detail on stdout.
#
# Usage:
#   ./image-vuln-scan-policy.sh --image myorg/myapp:abc1234 [--severity HIGH,CRITICAL]
#       [--report-dir ./reports] [--verify-signature] [--cosign-key cosign.pub]
#       [--allow-unfixed] [--skip-signature]

PROG="$(basename "$0")"
readonly PROG

IMAGE=""
SEVERITY="HIGH,CRITICAL"
REPORT_DIR="./reports"
VERIFY_SIGNATURE=false
COSIGN_KEY=""
ALLOW_UNFIXED=false
SKIP_SIGNATURE=false

usage() {
  cat <<EOF
Usage: $PROG --image NAME:TAG [options]

Options:
  --image IMAGE        Image reference to scan (required)
  --severity LIST      Comma-separated severities that fail the policy (default: HIGH,CRITICAL)
  --report-dir DIR     Directory for scan reports (default: ./reports)
  --verify-signature   Verify the image signature with Cosign after a clean scan
  --cosign-key FILE    Cosign public key file for key-based verification (omit for keyless)
  --allow-unfixed      Do not fail on findings that have no fixed version available
  --skip-signature     Skip signature verification even if signing is configured
  -h, --help           Show this help
EOF
}

fail() {
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image) IMAGE="${2:-}"; shift 2 ;;
    --severity) SEVERITY="${2:-}"; shift 2 ;;
    --report-dir) REPORT_DIR="${2:-}"; shift 2 ;;
    --verify-signature) VERIFY_SIGNATURE=true; shift ;;
    --cosign-key) COSIGN_KEY="${2:-}"; shift 2 ;;
    --allow-unfixed) ALLOW_UNFIXED=true; shift ;;
    --skip-signature) SKIP_SIGNATURE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1" 2 ;;
  esac
done

[[ -n "$IMAGE" ]] || { usage >&2; fail "--image is required" 2; }
[[ -n "$SEVERITY" ]] || fail "--severity must not be empty" 2
if [[ "$VERIFY_SIGNATURE" == true && -n "$COSIGN_KEY" && ! -f "$COSIGN_KEY" ]]; then
  fail "Cosign key file not found: $COSIGN_KEY" 2
fi

command -v docker >/dev/null 2>&1 || fail "docker is required but not found in PATH" 3
command -v trivy >/dev/null 2>&1 || fail "trivy is required but not found in PATH" 3
if [[ "$VERIFY_SIGNATURE" == true && "$SKIP_SIGNATURE" == false ]]; then
  command -v cosign >/dev/null 2>&1 || fail "cosign is required for --verify-signature but not found in PATH" 3
fi

mkdir -p "$REPORT_DIR"
SAFE_NAME="$(echo "$IMAGE" | tr '/:@' '---')"
TABLE_REPORT="$REPORT_DIR/$SAFE_NAME.table.txt"
JSON_REPORT="$REPORT_DIR/$SAFE_NAME.json"

echo "[1/3] Scanning $IMAGE with Trivy (policy severities: $SEVERITY)..."
TRIVY_ARGS=(image --severity "$SEVERITY" --format table --output "$TABLE_REPORT")
if [[ "$ALLOW_UNFIXED" == true ]]; then
  TRIVY_ARGS+=(--ignore-unfixed)
fi
if ! trivy "${TRIVY_ARGS[@]}" "$IMAGE"; then
  echo "------ scan detail ------"
  cat "$TABLE_REPORT" 2>/dev/null || true
  fail "POLICY FAIL: Trivy reported findings at $SEVERITY for $IMAGE (see $TABLE_REPORT)" 10
fi

echo "[2/3] Writing machine-readable report to $JSON_REPORT..."
JSON_ARGS=(image --severity "$SEVERITY" --format json --output "$JSON_REPORT")
if [[ "$ALLOW_UNFIXED" == true ]]; then
  JSON_ARGS+=(--ignore-unfixed)
fi
trivy "${JSON_ARGS[@]}" "$IMAGE" >/dev/null

echo "[3/3] Signature check..."
if [[ "$SKIP_SIGNATURE" == true ]]; then
  echo "Signature verification skipped (--skip-signature)."
elif [[ "$VERIFY_SIGNATURE" == true ]]; then
  if [[ -n "$COSIGN_KEY" ]]; then
    cosign verify --key "$COSIGN_KEY" "$IMAGE" \
      || fail "POLICY FAIL: Cosign signature verification failed for $IMAGE" 11
  else
    cosign verify "$IMAGE" \
      || fail "POLICY FAIL: Cosign signature verification failed for $IMAGE" 11
  fi
  echo "Signature verified for $IMAGE."
else
  echo "No signature verification requested (pass --verify-signature to enforce signing)."
fi

echo ""
echo "POLICY PASS: $IMAGE"
echo "  Table report: $TABLE_REPORT"
echo "  JSON report:  $JSON_REPORT"
