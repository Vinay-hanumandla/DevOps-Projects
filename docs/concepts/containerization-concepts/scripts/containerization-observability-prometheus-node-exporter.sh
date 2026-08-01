# last_verified: 2026-07-31 · bash n/a

set -e

# Running Prometheus node_exporter in a container to collect host-level
# metrics. This follows the containerization + observability pattern where
# Docker captures stdout/stderr from each container, which can be forwarded
# to monitoring backends like Fluentd, Loki, or the ELK stack.
# Source: https://www.bmc.com/blogs/devops-containers/

IMAGE="prom/node-exporter:latest"
CONTAINER="node-exporter"
HOST_METRICS_PORT=9100

echo "Pulling node_exporter image..."
docker pull "$IMAGE"

echo "Starting node_exporter container..."
docker run -d \
  --name "$CONTAINER" \
  --restart unless-stopped \
  -p "${HOST_METRICS_PORT}:9100" \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /:/rootfs:ro \
  "${IMAGE}" \
  --path.procfs /host/proc \
  --path.sysfs /host/sys \
  --path.rootfs /rootfs

echo "Verifying container is running..."
docker ps --filter "name=${CONTAINER}"

echo "node_exporter metrics available at http://localhost:${HOST_METRICS_PORT}/metrics"