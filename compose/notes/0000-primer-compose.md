---
last_verified: 2026-10-14
tool_version: n/a
---

# Docker Compose — quick primer

> First-day notes for someone who's never used Docker Compose. Personal voice, plain language.

## What is it?

I just learned Docker Compose is basically a shortcut for running several containers together. I already knew `docker run` starts one container at a time, and that got old fast once I needed a web app plus a database talking to each other. Compose lets me describe all of that in one file and bring the whole bunch up or down with a single command.

It sits in the same space as plain container commands, but one level up. If a single container is like one musician, a Compose file is the set list that tells the whole band what to play and when to come in.

## What does it do?

It lets me list my services in a file, wire them to the same network so they can reach each other by name, and start or stop everything together. I ran one command and got a web page and a database running side by side, logs streaming in one place.

## Why does it exist?

Before Compose, people strung together long `docker run` commands or little shell scripts with flags for ports, volumes, and links, and every teammate ran them slightly differently. I can see why that broke down fast. Compose gives the whole setup one shared file, so my laptop and my teammate's laptop run the same thing. Folks who build and test multi-container apps day to day seem to be the main users.

## Key terminology

- **Service** — one container role in the file, like the web page or the database. Example: a service named `web` serving pages on port 8080.
- **Image** — the packaged snapshot a service starts from. Example: starting my `web` service from an `nginx` image.
- **Compose file** — the single file where I list services and how they connect. Example: my two-service file with `web` plus `db`.
- **Network** — the shared lane services use to talk to each other by name. Example: `web` reaching the database at hostname `db`.
- **Volume** — a folder that survives container restarts so data is kept. Example: keeping database rows safe when I restart `db`.
- **Port mapping** — the link between a port on my laptop and a port inside a container. Example: opening my browser at `localhost:8080` to reach the `web` service.
- **Up / down** — the two commands that start everything and then stop and remove it. Example: I ran up to try things, then down to clean up.

## A tiny example

The smallest thing I got working was two services, a web page and a database:

```yaml
services:
  web:
    image: nginx
    ports:
      - "8080:80"
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: example
```

This starts a web page I can open at `localhost:8080` and a database the web side can reach as `db`.

## What I'll cover next

Next I want to actually run my first `up` and write down everything that trips me up, then try a minimal file of my own from scratch with a web page plus a database so I have a starting point I understand.
