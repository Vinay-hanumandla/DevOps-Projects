#!/usr/bin/env bash
# last_verified: 2026-09-07 · Docker buildx
set -Eeuo pipefail

# Multi-arch buildx: build for linux/amd64 and linux/arm64,
# cache layers in the registry, tag with git SHA + semver, and push.
#
# Prerequisites:
#   - docker buildx installed (comes with Docker Desktop or docker-buildx package)
#   - A builder instance with multi-platform support
#   - Registry credentials configured (docker login or credential helper)
#
# Usage:
#   ./multi-arch-buildx.sh --image myorg/myapp --tag v1.2.3 --platform linux/amd64,linux/arm64

PROG="$(basename "$0")"
readonly PROG

usage() {
  cat <<EOF
Usage: $PROG --image NAME --tag TAG [--platform PLATFORMS] [--context PATH]

Options:
  --image NAME        Registry image name (e.g. myorg/myapp)
  --tag TAG           Semver or git SHA tag (e.g. v1.2.3 or abc1234)
  --platform PLATS    Comma-separated target platforms (default: linux/amd64,linux/arm64)
  --context PATH      Build context directory (default: .)
  --cache-from REG    Registry to pull cache from (default: type=registry,ref=<image>:buildcache)
  --cache-to REG      Registry to push cache to   (default: type=registry,ref=<image>:buildcache,mode=max)
  --dry-run           Print the buildx command without executing
  -h, --help          Show this help
EOF
  exit 0
}

# Defaults
IMAGE=""
TAG=""
PLATFORMS="linux/amd64,linux/arm64"
CONTEXT="."
CACHE_FROM=""
CACHE_TO=""
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)      IMAGE="$2"; shift 2 ;;
    --tag)        TAG="$2"; shift 2 ;;
    --platform)   PLATFORMS="$2"; shift 2 ;;
    --context)    CONTEXT="$2"; shift 2 ;;
    --cache-from) CACHE_FROM="$2"; shift 2 ;;
    --cache-to)   CACHE_TO="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=true; shift ;;
    -h|--help)    usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Validate required args
if [[ -z "$IMAGE" || -z "$TAG" ]]; then
  echo "ERROR: --image and --tag are required" >&2
  usage
fi

# Derive cache refs if not explicitly provided
if [[ -z "$CACHE_FROM" ]]; then
  CACHE_FROM="type=registry,ref=${IMAGE}:buildcache"
fi
if [[ -z "$CACHE_TO" ]]; then
  CACHE_TO="type=registry,ref=${IMAGE}:buildcache,mode=max"
fi

# Build the full tag list: image:tag and image:latest
FULL_TAG="${IMAGE}:${TAG}"
LATEST_TAG="${IMAGE}:latest"

echo "==> Building ${FULL_TAG} for ${PLATFORMS}"

# Ensure a buildx builder exists with multi-platform support
BUILDER_NAME="multiarch-builder"
if ! docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
  echo "==> Creating buildx builder: ${BUILDER_NAME}"
  docker buildx create \
    --name "$BUILDER_NAME" \
    --driver docker-container \
    --use
  docker buildx inspect --bootstrap
else
  echo "==> Using existing builder: ${BUILDER_NAME}"
  docker buildx use "$BUILDER_NAME"
fi

# Assemble the buildx command
BUILD_CMD=(
  docker buildx build
  --platform "$PLATFORMS"
  --cache-from "$CACHE_FROM"
  --cache-to "$CACHE_TO"
  --tag "$FULL_TAG"
  --tag "$LATEST_TAG"
  --push
  "$CONTEXT"
)

if $DRY_RUN; then
  echo "==> Dry run — would execute:"
  printf '  %s\n' "${BUILD_CMD[@]}"
  exit 0
fi

# Execute the build
"${BUILD_CMD[@]}"

echo "==> Pushed ${FULL_TAG} and ${LATEST_TAG}"
echo "==> Done"
