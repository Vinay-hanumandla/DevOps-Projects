#!/usr/bin/env bash
# last_verified: 2026-07-20 · docker 27

# Following the Docker getting-started guide to understand container lifecycle
# and image inspection. Ran commands one by one first, then scripted it.

set -x

IMAGE="nginx:alpine"
NAME="learn-lifecycle"

docker pull "$IMAGE"

# Inspect the image metadata — layers, entrypoint, exposed ports
docker image inspect "$IMAGE" | head -25

# Start a container in the background
docker run -d --name "$NAME" "$IMAGE"

# Verify it's running and look at its details
docker ps --filter "name=$NAME"
docker container inspect "$NAME" | grep -E '"Id"|"Status"|"IPAddress"' | head -5

# Stop gracefully (not kill — learned that stop sends SIGTERM, then SIGKILL after 10s)
docker stop "$NAME"

# Remove so next run starts clean
docker rm "$NAME"

echo "Done — saw the full run → stop → remove lifecycle"
