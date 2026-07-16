#!/usr/bin/env bash
# last_verified: 2026-07-16 · Docker 29.2.0
#
# Run my first container with port mapping and verify end-to-end.
#
# I kept mixing up the host:container port order (it's HOST:CONTAINER,
# not the other way around). Turning the workflow into a script so I
# don't have to re-derive the syntax each time.

IMAGE="nginx:1.25-alpine"
NAME="port-map-demo"
HOST_PORT="8080"
CTR_PORT="80"

echo "=== Pulling $IMAGE ==="
docker pull "$IMAGE"

echo "=== Starting $NAME — mapping host $HOST_PORT to container $CTR_PORT ==="
docker run --rm -d --name "$NAME" -p "$HOST_PORT:$CTR_PORT" "$IMAGE"

sleep 1

echo "=== Verifying nginx responds on localhost:$HOST_PORT ==="
if curl -sf http://localhost:"$HOST_PORT" > /dev/null; then
    echo "OK — nginx is reachable at http://localhost:$HOST_PORT"
else
    echo "FAIL — could not connect"
fi

echo "=== Cleanup: stopping $NAME ==="
docker stop "$NAME"
echo "Done"
