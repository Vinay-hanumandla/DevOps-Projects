---
last_verified: 2026-07-19
tool_version: n/a
sources:
  - https://kodekloud.com/blog/docker-tutorial-for-beginners
  - https://dev.to/prodevopsguytech/100-common-docker-errors-solutions-4le0
  - https://tech-insider.org/docker-tutorial-beginners-containerization-2026
---

# Docker — quick primer

> First-day notes for someone who's never used Docker. Personal voice, plain language.

## What is it?

Docker is a containerization platform — it lets you package an application with everything it needs (code, runtime, libraries, config) into a single unit called a container. Think of it like a lightweight virtual machine, but instead of emulating a whole OS, it shares the host's kernel and only bundles the user-space bits. The result: containers start in seconds, use way less disk and memory than VMs, and behave the same on your laptop, a test server, or a deployment server.

I'd describe Docker to someone who's used Python virtualenvs as "virtualenv for your whole app, including the OS-level dependencies." The big difference: Docker isolates at the process/filesystem level, not just the Python package level.

## What does it do?

Docker lets you build images (read-only templates), run them as containers (writable instances), publish containers to registries (image storage), and compose multi-container setups. You describe the setup in a `Dockerfile` and Docker handles the rest — pulling base images, caching build layers, networking containers, and mounting storage.

## Why does it exist?

Before Docker, the standard onboarding for a new dev was a README with 47 manual steps: "Install PostgreSQL 14, Redis 6, Ruby 3.2, bundle install, copy .env.example, run migrations, pray." Every machine was slightly different, so bugs that only happened on the staging server were a fact of life. Docker fixes that by making the environment part of the artifact. If it runs in a container on my machine, it runs the same way in CI and on a server — no more "works on my machine."

## Key terminology

- **Image** — A read-only snapshot of a filesystem plus metadata (exposed ports, entrypoint, etc.). Think of it like a class definition. Example: `nginx:1.27-alpine` is an image.
- **Container** — A running instance of an image. It gets a writable layer on top and its own network namespace. Example: `docker run nginx` creates a container from the nginx image.
- **Dockerfile** — A recipe for building an image. Each instruction (`FROM`, `RUN`, `COPY`) creates a layer. Example: `FROM python:3.12-slim` starts every Python app Dockerfile I've seen.
- **Daemon / Engine** — The background process (`dockerd`) that manages images, containers, networks, and volumes. The `docker` CLI talks to it via a socket.
- **Registry** — A server that stores and distributes images. Docker Hub is the default public registry. Example: `docker pull postgres:16` pulls from Docker Hub.
- **Volume** — Persistent storage that outlives a container. Containers are ephemeral by default — delete the container, lose the data. Volumes fix that. Example: `docker run -v mydata:/data app`.
- **Port mapping** — Exposes a container port on the host. Syntax `-p HOST_PORT:CONTAINER_PORT`. Example: `docker run -p 8080:80 nginx` makes nginx reachable on localhost:8080.
- **docker compose** — Docker's multi-container orchestration tool (V2, built-in). Define services, networks, and volumes in a `compose.yaml` file and start everything with `docker compose up`. The old `docker-compose` (hyphen, V1) has been EOL since 2023.
- **Layer** — Each instruction in a Dockerfile creates a layer. Docker caches layers, so rebuilding is fast if only the last few instructions changed. Example: changing a `COPY` invalidates that layer and everything after it, so put infrequent changes early in the Dockerfile.

## A tiny example

```bash
# Pull the hello-world test image and run it
docker run hello-world
```

That single command downloads the `hello-world` image from Docker Hub and runs it in a container. The container prints a success message explaining that Docker works, then exits. It's the equivalent of `print("hello world")` — the smallest thing that proves the tool is installed and working.

## What I'll cover next

Now that I know the landscape and the vocabulary, the next step is actually installing Docker and getting the daemon running on my machine. After that I want to pull a real image (nginx or alpine), poke around inside a running container, and eventually build my own image with a Dockerfile.
