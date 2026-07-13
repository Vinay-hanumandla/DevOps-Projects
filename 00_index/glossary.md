# Glossary

## Docker

- **Image** — an immutable, layered template (built from a Dockerfile) that defines a container's filesystem and start command.
- **Container** — a running instance of an image; isolated but ephemeral, so anything written inside is lost when it stops unless a volume is mounted.
- **Tag** — a label on an image (e.g. `nginx:1.25`); pulling without one defaults to `:latest`, which is why pinning a version matters for reproducibility.
- **Port mapping** — binding a host port to a container port with `-p host:container` (host port first); `docker port <container>` shows the resolved mapping.
- **Detached mode** — running a container with `-d` so it runs in the background instead of holding the terminal; view its output later with `docker logs <container>`.
- **Multi-stage build** — using several `FROM` stages in one Dockerfile to build in a heavy toolchain image and copy only the compiled artifact into a small final image.
- **Distroless image** — a minimal final image containing only the app and its runtime dependencies (no shell, package manager, or OS utilities), which shrinks attack surface.
- **Non-root runtime** — configuring the container to run as an unprivileged UID instead of root, a basic security hardening step.
- **Volume** — a persistent, host-managed storage mount that survives container restarts, used when data must outlive the container.
