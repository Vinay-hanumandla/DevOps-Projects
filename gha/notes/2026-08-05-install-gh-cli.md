---
last_verified: 2026-08-05
tool_version: n/a
sources:
  - https://www.clouddevopshub.com/blog/15-ci-cd-concepts-every-devops-engineer-must-master-in-2026-complete-guide
---

# Installing `gh` and exploring the Actions UI

I installed the GitHub CLI (`gh`) so I could interact with GitHub Actions from the terminal instead of only using the web UI.

## What I did

I ran `brew install gh` on my Mac (the docs also support `apt install gh` on Linux and `winget install gh` on Windows). After installing, I authenticated with `gh auth login` and followed the prompts — it asked for my GitHub host, preferred protocol (HTTPS), and whether to trust TLS certificates.

## What tripped me up

I forgot to set `gh auth login` before trying `gh workflow list` — I got a "not authenticated" error. Once I logged in, the commands worked. I also didn't realize `gh` has subcommands for workflows, runs, and runs, so I kept guessing the right one.

## What I saw in the UI

The GitHub Actions tab in a repo shows a list of workflow runs, their status (success, failure, in progress), and the commit that triggered them. Clicking a run shows each job and step, plus the log output. I noticed the UI makes it easy to re-run a failed job or download artifacts, but the logs can get long and scrolling through them is slower than using `gh run view` in the terminal.