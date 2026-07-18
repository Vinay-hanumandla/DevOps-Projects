#!/usr/bin/env bash
# last_verified: 2026-07-18 · Docker
#
# Run my first container and map its port end to end.
#
# Following the Docker quickstart — I kept getting the port order
# backwards (it's HOST_PORT:CONTAINER_PORT, not the reverse).
# This script makes the workflow repeatable so I don't have to
# remember the syntax each time.

IMAGE="nginx:1.27-alpine"
CONTAINER_NAME="port-map-demo"
HOST_PORT="8080"
CONTAINER_PORT="80"

echo "=== Pulling $IMAGE ==="
docker pull "$IMAGE"

# -d runs in the background so I get the terminal back;
# --rm auto-removes the container after it stops.
echo "=== Starting $CONTAINER_NAME — mapping host $HOST_PORT to container $CONTAINER_PORT ==="
docker run --rm -d \
    --name "$CONTAINER_NAME" \
    -p "$HOST_PORT:$CONTAINER_PORT" \
    "$IMAGE"

# nginx needs a moment to boot before it accepts connections
sleep 1

echo "=== Verifying nginx responds on http://localhost:$HOST_PORT ==="
if curl -sf http://localhost:"$HOST_PORT" > /dev/null; then
    echo "OK — nginx is reachable at http://localhost:$HOST_PORT"
else
    echo "FAIL — could not reach nginx on port $HOST_PORT"
fi

# Cleaning up so I don't leave containers running by accident
echo "=== Stopping $CONTAINER_NAME ==="
docker stop "$CONTAINER_NAME"
echo "Done"
