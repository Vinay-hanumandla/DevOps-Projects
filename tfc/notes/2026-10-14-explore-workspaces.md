---
last_verified: 2026-10-14
tool_version: "n/a"
---

# Poking around Terraform Cloud workspaces

I signed up for a trial org and clicked through the workspaces list to see what's there.

## What I did

- Made an org called `example-org` and created a workspace named `example-ws` with the UI flow.
- Opened the workspace and found tabs for Runs, States, Variables, and Settings.
- Added a dummy variable `demo_name = "hello"` under Variables.
- Queued a plan from the UI with my sample config pointed at the workspace.

## Got stuck on

- The plan sat in "needs confirmation" and I wasn't sure whether closing the tab cancels it. Turns out the run just waits — nothing applies until I confirm or discard.
- I first set my variable as the wrong category (env vs workspace value) and the plan complained the input was missing. Flipping the category fixed it.

## What I'd try next

I want to connect a repo so pushes queue plans on their own, and try locking a workspace while a teammate's run is queued.
