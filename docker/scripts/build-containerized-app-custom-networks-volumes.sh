#!/usr/bin/env bash
# last_verified: 2026-09-03 · Docker n/a

set -euo pipefail

# docker-009 — Build a containerized app from scratch with custom networks and named volumes
# Level: L3 | Output: script(bash)

APP_NAME="myapp"
IMAGE_TAG="${APP_NAME}:local"
NETWORK_NAME="${APP_NAME}-net"
VOLUME_NAME="${APP_NAME}-data"
CONTAINER_WEB="${APP_NAME}-web"
CONTAINER_TEST="${APP_NAME}-test"

cleanup() {
  echo "[cleanup] Removing containers..."
  docker rm -f "${CONTAINER_WEB}" "${CONTAINER_TEST}" 2>/dev/null || true
  echo "[cleanup] Removing network..."
  docker network rm "${NETWORK_NAME}" 2>/dev/null || true
  # Do not remove the volume so the user can inspect persisted data
  echo "[cleanup] Done. Volume '${VOLUME_NAME}' retained for inspection."
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

WORKDIR="$(mktemp -d)"
cd "${WORKDIR}"
echo "[setup] Working in ${WORKDIR}"

# 1. Write a tiny Python HTTP server app
cat > app.py <<'PYEOF'
import http.server
import socketserver
import os
import json

PORT = 8000
DATA_DIR = "/data"

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok", "path": DATA_DIR}).encode())
        else:
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            files = os.listdir(DATA_DIR) if os.path.isdir(DATA_DIR) else []
            self.wfile.write(
                f"Hello from {os.environ.get('APP_NAME', 'container')}\n".encode()
            )
            self.wfile.write(f"Persisted files: {files}\n".encode())

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving on port {PORT}")
    httpd.serve_forever()
PYEOF

# 2. Write a minimal Dockerfile
cat > Dockerfile <<'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY app.py .
ENV APP_NAME=myapp
RUN mkdir -p /data && echo "persisted-file" > /data/seed.txt
VOLUME /data
EXPOSE 8000
CMD ["python", "app.py"]
EOF

# 3. Build the image
echo "[build] Building ${IMAGE_TAG}..."
docker build -t "${IMAGE_TAG}" .

# 4. Create a custom bridge network
echo "[network] Creating ${NETWORK_NAME}..."
docker network create "${NETWORK_NAME}" >/dev/null

# 5. Create a named volume
echo "[volume] Creating ${VOLUME_NAME}..."
docker volume create "${VOLUME_NAME}" >/dev/null

# 6. Run the web container on the custom network with the named volume
echo "[run] Starting ${CONTAINER_WEB}..."
docker run -d \
  --name "${CONTAINER_WEB}" \
  --network "${NETWORK_NAME}" \
  -v "${VOLUME_NAME}:/data" \
  -e APP_NAME="${APP_NAME}" \
  "${IMAGE_TAG}"

# 7. Wait for the server to become ready
echo "[wait] Waiting for ${CONTAINER_WEB}:8000..."
for i in $(seq 1 30); do
  if docker exec "${CONTAINER_WEB}" python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" >/dev/null 2>&1; then
    echo "[wait] Ready after ${i} attempt(s)."
    break
  fi
  if [ "${i}" -eq 30 ]; then
    echo "ERROR: ${CONTAINER_WEB} did not become healthy in time." >&2
    exit 1
  fi
  sleep 1
done

# 8. Verify inter-container communication via the custom network
echo "[verify] Testing connectivity from a temporary Alpine container..."
docker run --rm \
  --network "${NETWORK_NAME}" \
  alpine:3.20 \
  sh -c "apk add --no-cache curl >/dev/null 2>&1 && curl -fsS http://${CONTAINER_WEB}:8000/health"

echo "[verify] Listing persisted files via curl..."
docker run --rm \
  --network "${NETWORK_NAME}" \
  alpine:3.20 \
  sh -c "apk add --no-cache curl >/dev/null 2>&1 && curl -fsS http://${CONTAINER_WEB}:8000/"

echo ""
echo "SUCCESS: Containerized app is running with:"
echo "  Image  : ${IMAGE_TAG}"
echo "  Network: ${NETWORK_NAME}"
echo "  Volume : ${VOLUME_NAME}"
echo ""
echo "Next steps you can try manually:"
echo "  docker exec ${CONTAINER_WEB} ls -la /data"
echo "  docker network inspect ${NETWORK_NAME}"
echo "  docker volume inspect ${VOLUME_NAME}"
