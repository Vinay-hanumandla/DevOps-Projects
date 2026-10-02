#!/usr/bin/env bash
# last_verified: 2026-10-02 · docker n/a
# docker-023 — Reusable Docker build wrapper: cache-from, multi-platform,
# SBOM generation, and Trivy scan gate.
# Level: L4 | Output: script(bash)
#
# Purpose: one entry point for building, tagging, and pushing a service
#   image with registry cache reuse, multi-platform output, an attached
#   SBOM, and a vulnerability scan that fails the run on high-severity
#   findings.
# When to use: in CI or locally whenever an image needs a repeatable
#   build-and-gate flow instead of ad-hoc docker build invocations.
# Prerequisites: a running Docker daemon with buildx, push access to the
#   target registry (docker login beforehand); trivy on PATH if scanning.
# Steps: parse args -> ensure builder -> buildx build with cache-from,
#   SBOM/provenance attestations, and push -> scan the pushed tag with
#   trivy -> verify the tag resolves via imagetools inspect.
# Verify: re-run with the same IMAGE/TAG and confirm the second run
#   reports cached layers, prints the SBOM path, and exits 0 on a clean
#   scan; introduce a vulnerable base and confirm a non-zero exit.
#
# Usage:
#   ./docker-build-wrapper.sh --image myorg/myapp --tag test-build
#   ./docker-build-wrapper.sh --image myorg/myapp --tag test-build \
#       --platform linux/amd64 --no-scan --sbom-out ./sbom.json

set -euo pipefail

PROG="$(basename "$0")"

IMAGE=""
TAG="dev"
PLATFORMS="linux/amd64,linux/arm64"
CONTEXT="."
DOCKERFILE="Dockerfile"
CACHE_FROM=""
CACHE_TO=""
SBOM_OUT="sbom.json"
WANT_SBOM=true
WANT_SCAN=true
PUSH=true

usage() {
  cat <<EOF
Usage: $PROG --image NAME [--tag TAG] [options]

Required:
  --image NAME        Image name (e.g. myorg/myapp)

Options:
  --tag TAG           Image tag (default: dev)
  --platform PLATS    Comma-separated platforms (default: linux/amd64,linux/arm64)
  --context PATH      Build context (default: .)
  --dockerfile PATH   Dockerfile path (default: Dockerfile)
  --cache-from SPEC   Cache source (default: type=registry,ref=<image>:buildcache)
  --cache-to SPEC     Cache destination (default: type=registry,ref=<image>:buildcache,mode=max)
  --sbom-out PATH     Where to write the SBOM document (default: sbom.json)
  --no-sbom           Skip SBOM generation
  --no-scan           Skip the Trivy scan gate
  --no-push           Build without pushing (local load of first platform)
  -h, --help          Show this help
EOF
}

die() {
  echo "ERROR: $1" >&2
  exit "${2:-1}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)      IMAGE="$2"; shift 2 ;;
    --tag)        TAG="$2"; shift 2 ;;
    --platform)   PLATFORMS="$2"; shift 2 ;;
    --context)    CONTEXT="$2"; shift 2 ;;
    --dockerfile) DOCKERFILE="$2"; shift 2 ;;
    --cache-from) CACHE_FROM="$2"; shift 2 ;;
    --cache-to)   CACHE_TO="$2"; shift 2 ;;
    --sbom-out)   SBOM_OUT="$2"; shift 2 ;;
    --no-sbom)    WANT_SBOM=false; shift ;;
    --no-scan)    WANT_SCAN=false; shift ;;
    --no-push)    PUSH=false; shift ;;
    -h|--help)    usage; exit 0 ;;
    *) die "unknown option: $1 (see --help)" 2 ;;
  esac
done

[[ -n "$IMAGE" ]] || die "--image is required (see --help)" 2
[[ -f "$CONTEXT/$DOCKERFILE" ]] || [[ -f "$DOCKERFILE" ]] \
  || die "Dockerfile not found at $CONTEXT/$DOCKERFILE" 2

FULL_TAG="${IMAGE}:${TAG}"
if [[ -z "$CACHE_FROM" ]]; then
  CACHE_FROM="type=registry,ref=${IMAGE}:buildcache"
fi
if [[ -z "$CACHE_TO" ]]; then
  CACHE_TO="type=registry,ref=${IMAGE}:buildcache,mode=max"
fi

# 1. Docker daemon must be reachable; without it nothing below can run.
docker info >/dev/null 2>&1 \
  || die "Docker daemon is not reachable (is dockerd running?)" 3

# 2. Reuse (or create) a builder that supports the requested platforms.
BUILDER_NAME="build-wrapper-builder"
if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  echo "==> Creating buildx builder '${BUILDER_NAME}'"
  docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
  docker buildx inspect --bootstrap
else
  echo "==> Using existing builder '${BUILDER_NAME}'"
  docker buildx use "$BUILDER_NAME"
fi

# 3. Build with registry cache, SBOM/provenance attestations, and push.
echo "==> Building ${FULL_TAG} for ${PLATFORMS}"
BUILD_ARGS=(
  docker buildx build
  --platform "$PLATFORMS"
  --cache-from "$CACHE_FROM"
  --cache-to "$CACHE_TO"
  --file "$DOCKERFILE"
  --tag "$FULL_TAG"
)
if [[ "$WANT_SBOM" == true ]]; then
  BUILD_ARGS+=(--sbom=true --provenance=true)
fi
if [[ "$PUSH" == true ]]; then
  BUILD_ARGS+=(--push)
else
  BUILD_ARGS+=(--load)
fi
BUILD_ARGS+=("$CONTEXT")

"${BUILD_ARGS[@]}" || die "build failed for ${FULL_TAG}" 4

# 4. Persist the SBOM document next to the build for audit purposes.
if [[ "$WANT_SBOM" == true ]]; then
  if docker sbom --help >/dev/null 2>&1; then
    echo "==> Writing SBOM to ${SBOM_OUT}"
    docker sbom --format spdx-json --output "$SBOM_OUT" "$FULL_TAG" \
      || die "could not generate SBOM for ${FULL_TAG}" 5
  else
    echo "==> WARN: 'docker sbom' subcommand not available; SBOM lives on as a build attestation only"
  fi
fi

# 5. Scan gate: fail the run when high-severity issues are present.
if [[ "$WANT_SCAN" == true ]]; then
  if command -v trivy >/dev/null 2>&1; then
    echo "==> Scanning ${FULL_TAG} with trivy (HIGH,CRITICAL fail the gate)"
    trivy image --severity HIGH,CRITICAL --exit-code 1 "$FULL_TAG" \
      || die "scan gate failed: ${FULL_TAG} has HIGH/CRITICAL findings" 6
  else
    echo "==> WARN: trivy not on PATH; skipping scan gate for ${FULL_TAG}"
  fi
fi

# 6. Verify the pushed tag resolves before reporting success.
if [[ "$PUSH" == true ]]; then
  echo "==> Verifying ${FULL_TAG} resolves in the registry"
  docker buildx imagetools inspect "$FULL_TAG" >/dev/null \
    || die "verify failed: ${FULL_TAG} does not resolve after push" 7
fi

echo "==> Done: ${FULL_TAG} (platforms: ${PLATFORMS}, sbom: ${WANT_SBOM}, scan: ${WANT_SCAN})"
