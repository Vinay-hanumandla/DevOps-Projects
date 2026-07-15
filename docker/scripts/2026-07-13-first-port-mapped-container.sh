#!/usr/bin/env bash
# last_verified: 2026-07-14 · Docker 29.2.0
#
# Run my first container and map its port end to end.
#
# Spins up an nginx container and maps host port 8080 to container port 80.
# Verifies it's reachable, then tears down.
#
# I kept mixing up the port order (host:container) the first time — the
# script makes it repeatable so I don't have to remember the syntax.

IMAGE="nginx:1.25-alpine"
CONTAINER_NAME="port-test"
HOST_PORT="8080"
CONTAINER_PORT="80"

echo "=== Pulling $IMAGE ==="
docker pull "$IMAGE"

echo "=== Starting container $CONTAINER_NAME on port $HOST_PORT -> $CONTAINER_PORT ==="
docker run --rm -d \
    --name "$CONTAINER_NAME" \
    -p "$HOST_PORT:$CONTAINER_PORT" \
    "$IMAGE"

# Give nginx a moment to start
sleep 1

echo "=== Verifying nginx responds ==="
# -f means curl exits with a non-zero code if the HTTP response indicates
# an error; -s silences progress output
curl -sf http://localhost:"$HOST_PORT" > /dev/null && \
    echo "OK — nginx is serving on localhost:$HOST_PORT" || \
    echo "FAIL — could not reach nginx"

echo "=== Container logs ==="
docker logs "$CONTAINER_NAME"

echo "=== Stopping container ==="
docker stop "$CONTAINER_NAME"
