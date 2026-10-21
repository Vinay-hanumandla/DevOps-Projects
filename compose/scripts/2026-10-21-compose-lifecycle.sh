# last_verified: 2026-10-21 · compose n/a
#!/usr/bin/env bash
# Compose lifecycle: up, wait for healthy, logs, down with cleanup

compose up -d
echo "waiting for services to become healthy..."
# poll until all are healthy
while :; do
  unhealthy=$(docker compose ps --format '{{.Health}}' | grep -v healthy || true)
  if [ -z "$unhealthy" ]; then
    break
  fi
  sleep 2
done
echo "stack is up"
docker compose logs --tail=20

# cleanup on exit
trap 'docker compose down' EXIT