# DevOps-Projects

> A working DevOps engineer's reference for Docker and Git — first-contact notes, runnable snippets, and configs.

> **New here?** Start at [the learning path](00_index/learning-path.md). It walks you from first-contact to confident in a sensible order — read that before this table.

## Who this is for

A working DevOps engineer's quick-reference: first-contact notes, runnable snippets, and configs for the tools I'm picking up. Use it as a shelf you grab from, not a tutorial site — each entry is something I actually built while working through a tool's quickstart, kept so I can revisit what tripped me up. It deliberately does not try to replace each tool's official docs. Right now it covers Docker and Git; more tools land as I work through them.

## What's in here

A growing kit of hands-on DevOps artifacts. Each entry is a dated note, snippet, or config built while following a tool's quickstart and kept for later. Currently it holds Docker material — first-contact notes, a minimal non-root multi-stage Dockerfile, a tagged-build variant with a Python sample app, and container run scripts — plus Git material: first-contact notes and stage/commit/push/undo walkthroughs.

---

## Quick links

- [Tagged-build non-root Dockerfile](docker/dockerfiles/2026-07-16-minimal-image-tagged-nonroot.Dockerfile) — multi-stage Python build pinned to a specific tag
- [Python HTTP server](docker/dockerfiles/2026-07-16-server.py) — the sample app served inside the tagged-build image
- [Port-mapped container script](docker/scripts/2026-07-16-run-container-port-map.sh) — run a container, map a port, verify, and tear down
- [Docker quickstart trip-ups (Jul 15)](docker/notes/2026-07-15-docker-quickstart-trip-ups.md) — a refreshed look at what trips up first-time Docker users
- [Git quickstart trip-ups (Jul 15)](git/notes/2026-07-15-git-quickstart-trip-ups.md) — what worked and where I got stuck revisiting Git

---

## Layout

- `docker/` — Docker material: notes, Dockerfiles, scripts, and sample apps.
- `git/` — Git material: first-contact notes and workflow walkthroughs.
- `00_index/` — the map: topics, quick links, glossary, and the learning path.
- `CHANGELOG.md` — a dated log of what was added and when.

---

## Coverage

| Tool | notes | dockerfiles | scripts | Last verified |
|------|-------|-------------|---------|---------------|
| Docker | 2 | 4 | 2 | 2026-07-16 |
| Git | 4 | — | — | 2026-07-15 |

---

## Status

Working through first-contact material for Docker and Git — both have notes and runnable examples now. Docker gained a tagged-build multi-stage Dockerfile and a fresh port-mapped container script this cycle. More tools land as the foundation builds.

---

_Last updated: 2026-07-16_
