---
last_verified: 2026-07-15
tool_version: "29.2.0"
sources:
  - https://kodekloud.com/blog/docker-tutorial-for-beginners/
  - https://dev.to/_d7eb1c1703182e3ce1782/docker-complete-guide-for-beginners-containerize-your-app-in-2026-57j9
  - https://www.xda-developers.com/docker-mistakes-beginners-make-in-their-first-month/
---

# Docker quickstart — what tripped me up today

Followed the official Docker quickstart. Here's what worked and where I got stuck.

## What went fine

Installing Docker from the official repo went smoothly. `docker run hello-world` worked first try — the daemon downloaded the test image and printed the success message. Running `docker run -it ubuntu bash` dropped me into an interactive shell inside a container. Exiting the shell stopped the container, which felt weird at first. `docker ps -a` showed it as `Exited (0)`.

## Where I got tripped up

**1. `docker ps` only shows running containers.** I started a container, exited it, and couldn't find it. Spent a minute thinking it was deleted. `docker ps -a` was what I needed. The `-a` flag shows everything — running and stopped.

**2. Port mapping syntax is easy to flip.** `docker run -p 8080:80 nginx` — host port first, container port second. I did it backwards the first time and got confused when nginx was reachable on port 80 on my host. `docker port <container>` helped me verify the mapping.

**3. Container exits immediately if the process finishes.** I ran a container without a foreground process and it stopped right away. Had to check `docker logs <container>` and the exit code with `docker inspect ... --format='{{.State.ExitCode}}'` to understand why. Exit code 0 means it ran fine and finished; 137 means OOM.

**4. Detached vs foreground mode.** I ran nginx without `-d` and my terminal hung on the log output. Ctrl+C killed the container. Adding `-d` (detach) let it run in the background. `docker logs <container>` to see the output later.

**5. Pulling without a tag gets `:latest`.** I pulled `docker pull nginx` and got the `latest` tag. For reproducibility I should be pinning versions like `nginx:1.25-alpine`. I also learned `docker tag` lets you retag images locally.

**6. `docker run --name` vs positional arg.** I tried `docker run myname image` expecting the first arg to be the container name. Docker treated `myname` as the command to run inside the container. The correct syntax is `--name myname` before the image name.

## What I'd try next

I want to build my own image with a Dockerfile and understand the build cache. Also need to figure out volumes — the "everything is ephemeral" nature of containers is going to bite me eventually when I try to persist data.
