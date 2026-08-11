---
last_verified: 2026-08-11
tool_version: n/a
sources: []
---

# Installing Jenkins and opening the web UI for the first time

I installed Jenkins locally today and finally saw the dashboard. I've only ever read about it as "the automation server," so the goal was simple: get it running and click around.

## Getting it installed

I grabbed the pre-built Jenkins package rather than building from source. The installer set up Jenkins to run as a service, which means it stays alive in the background instead of me having to keep a terminal open.

One thing that tripped me up: after install, Jenkins doesn't give you a one-line "it's ready" message. I assumed it was broken, but the service had actually started — I just hadn't looked in the right place yet.

## Opening the web UI

The UI shows up on port 8080 by default, so browsing to the local address on that port got me to the setup screen. It asked for an initial admin password, which Jenkins wrote to a file on disk during install. I opened that file, pasted the password in, and it walked me through creating my admin user and suggesting plugins to install.

## Got stuck on

- The initial password: I looked for it in the install output first, but it's on the filesystem, not in the terminal. That cost me a few minutes.
- The first page felt slow, and I worried I'd done something wrong. It was just Jenkins installing the suggested plugins — patience, not a problem.

## What I'd try next

Create a first pipeline job from the primer example and hit **Build Now** to see a run appear in the build history.