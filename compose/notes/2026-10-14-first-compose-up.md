---
last_verified: 2026-10-14
tool_version: n/a
---

# My first compose up — what tripped me up

I wrote a tiny two-service file and ran `docker compose up`. The web page came up but my browser showed nothing on the port I guessed. Turns out I mixed up which side of the port mapping is mine and which is the container's.

## What I did

- I put a `web` service and a `db` service in one file.
- I ran `docker compose up` and watched both logs stream together, which was neat.
- I opened the browser at the wrong port first, then rechecked my mapping and hit the right one.

## Got stuck on

- Port order. `8080:80` means my laptop uses 8080 and the container listens on 80. I had it backwards in my head at first.
- Service names as hostnames. I tried `localhost` from inside the web side to reach the database; that failed. Using the service name `db` worked.
- Stopping. I closed the terminal and everything kept running in the background. I had to run `docker compose down` to actually clean up.

## What I'd try next

I want to retry with a fresh file of my own and add one shared folder so I can see what sticks around after a restart.
