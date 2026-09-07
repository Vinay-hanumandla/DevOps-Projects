#!/usr/bin/env bash
# last_verified: 2026-09-06 · Docker n/a

set -euo pipefail

# docker-012 — Image build automation script: multi-arch buildx with caching, tagging, and registry push
# Level: L3 | Output: script(bash)

APP_NAME="myapp"
REGISTRY="localhost:5000"
PLATFORMS="linux/amd64,linux/arm64"
BUILDER_NAME="multiarch-builder"
CACHE_DIR="${HOME}/.buildx-cache/${APP_NAME}"

cleanup() {
  echo "[cleanup] Removing working container..."
  docker rm -f "${APP_NAME}-test" 2>/dev/null || true
}

trap cleanup EXIT

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: '$1' is required but not found in PATH." >&2
    exit 1
  fi
}

require_cmd docker

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not running or not accessible." >&2
  exit 1
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "ERROR: docker buildx is not available." >&2
  exit 1
fi

# 1. Create a buildx builder instance if it doesn't already exist
if ! docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
  echo "[setup] Creating buildx builder '${BUILDER_NAME}'..."
  docker buildx create --name "${BUILDER_NAME}" --use
else
  echo "[setup] Using existing buildx builder '${BUILDER_NAME}'"
  docker buildx use "${BUILDER_NAME}"
fi

# 2. Prepare cache directories
mkdir -p "${CACHE_DIR}"

# 3. Write a minimal test image
cat > Dockerfile <<'EOF'
FROM alpine
RUN echo "Hello from multi-arch build" > /greeting.txt
CMD ["cat", "/greeting.txt"]
EOF

# 4. Build for multiple platforms with local cache and push to registry
echo "[build] Building and pushing multi-arch image..."
docker buildx build \
  --platform "${PLATFORMS}" \
  --cache-from "type=local,src=${CACHE_DIR}" \
  --cache-to "type=local,dest=${CACHE_DIR},mode=max" \
  -t "${REGISTRY}/${APP_NAME}:latest" \
  --push \
  .

# 5. Verify the pushed image runs correctly
echo "[verify] Pulling and running the pushed image..."
docker run --rm "${REGISTRY}/${APP_NAME}:latest"

echo ""
echo "SUCCESS: Multi-arch image built and pushed to ${REGISTRY}/${APP_NAME}:latest"
echo "  Platforms : ${PLATFORMS}"
echo "  Cache     : ${CACHE_DIR}"
