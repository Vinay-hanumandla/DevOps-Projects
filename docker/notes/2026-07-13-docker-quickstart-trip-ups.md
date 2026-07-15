---
last_verified: 2026-07-14
tool_version: "29.2.0"
sources: []
---

# Docker quickstart — what tripped me up today

Followed the official Docker quickstart. Here's what worked and where I got stuck.

## What went fine

Installing Docker from the official repo was straightforward. `docker run hello-world` worked first try — the daemon downloaded the test image and printed the success message. Running `docker run -it ubuntu bash` dropped me into an interactive shell inside a container. Exiting the shell stopped the container, which felt weird at first — I expected it to hang around. `docker ps -a` showed it as `Exited (0)`.

## Where I got tripped up

**1. Forgetting `docker ps` only shows running containers.** Spent a minute wondering why my ubuntu container vanished after I exited. Needed `docker ps -a` to see it.

**2. `docker run --name` vs `docker rename`.** I tried `docker run myname image` expecting the first arg to be the container name. It treated `myname` as the command to run inside the container. Had to use `--name myname` explicitly.

**3. Pulling without a tag gets `:latest`.** Pulled `docker pull nginx` and got `:latest`. Later I needed a pinned version for a project and had to look up how tags work — `docker pull nginx:1.25` is the pattern. `docker tag` lets you retag locally.

**4. Port mapping syntax.** `docker run -p 8080:80 nginx` — the host port comes first, then the container port. I flipped them the first time and could reach nginx on port 80 on my host, which confused me until I checked `docker port <container>`.

**5. Detached vs foreground.** I ran nginx without `-d` and my terminal hung on the log output. Ctrl+C killed the container. `-d` (detach) fixed it. `docker logs <container>` to see the output later.

## What I'd try next

I want to build my own image with a Dockerfile and poke around the build cache behavior. Also need to figure out volumes — the "everything is ephemeral" thing is going to bite me eventually.
