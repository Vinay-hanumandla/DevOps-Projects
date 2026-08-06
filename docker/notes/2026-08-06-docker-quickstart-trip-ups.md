---
last_verified: 2026-08-06
tool_version: "28.5.1"
sources:
  - https://tech-insider.org/docker-tutorial-beginners-containerization-2026
---

# Docker quickstart — what tripped me up today

I ran through the official Docker quickstart on Docker Engine v28.5.1 with Compose v5.1.1. Most of it just worked, but a few spots made me stop and re-read. Here's the rundown.

## What went fine

`docker run hello-world` printed the success message first try, and `docker run -it ubuntu bash` dropped me into a container shell. Building my first image with a Dockerfile was straightforward — `docker build -t myapp .` produced an image I could run with `docker run -p 8080:80 myapp`. The daemon started cleanly and the CLI felt responsive.

## Where I got tripped up

**1. The compose command changed its name.** Following an older guide I typed `docker-compose up` and got `command not found`. Compose v1 (the hyphenated Python tool) is EOL since July 2023; the current command is `docker compose`, a Go plugin that ships with Docker Engine 28.x. Compose is now on v5 "Mont Blanc" and sitting at v5.3 as of mid-2026 — so any tutorial older than a year will steer you wrong here.

**2. `EXPOSE` doesn't publish ports.** My container's web server wasn't reachable from the host. `EXPOSE 80` in the Dockerfile is just documentation; it doesn't bind anything. I needed `-p 8080:80` on `docker run`, or a `ports:` mapping in Compose. `docker port <container>` showed me what was actually mapped.

**3. `depends_on` doesn't wait for readiness.** A dependent service started before the database was ready. `depends_on` only waits for the process to start — not for it to accept connections. The fix is `condition: service_healthy` paired with a `HEALTHCHECK` instruction in the Dockerfile.

**4. `.dockerignore` isn't optional.** My first build context ballooned because Docker shipped my `.git/`, `node_modules/`, and `.env` into the build. A bare `.dockerignore` with `.git`, `__pycache__`, `*.pyc`, `.env`, `node_modules`, and `.vscode` keeps images lean and avoids leaking secrets.

**5. Root is the default user.** Processes run as root inside the container by default. I added a non-root `USER` line in the Dockerfile. The 2026 guidance points toward rootless mode as the default, which I still need to try for myself.

**6. Container exits immediately.** This one bites everyone: the container needs a long-running foreground process. I caught it with `docker logs <id>` and checked the exit code with `docker inspect ... --format='{{.State.ExitCode}}'`. My `CMD` was a one-shot script that exited, so the container stopped right after starting.

**7. Multi-stage builds actually matter.** I rebuilt my image with a second `FROM` stage and copied only the finished binary into a distroless base. The image dropped from a few hundred MB to tens of MB.

## Gotchas I'm still fuzzy on

I haven't touched `docker scout cves <image>` yet, but it sounds like the way to surface CVEs and auto-generate an SBOM per image build. `docker init` is also supposed to scaffold a Dockerfile, `compose.yaml`, and `.dockerignore` based on my project — I'll let it generate one next and compare to what I hand-wrote.

## What I'd try next

Run the same quickstart with `docker init` to compare its generated Dockerfile to mine, then enable rootless mode and re-run `docker build` to feel the difference. Also want to wire up a `HEALTHCHECK` + `depends_on: condition: service_healthy` in Compose so the startup-order problem stops being a problem.
