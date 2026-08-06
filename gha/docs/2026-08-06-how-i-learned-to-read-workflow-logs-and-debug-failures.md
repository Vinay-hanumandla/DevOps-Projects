---
last_verified: 2026-08-06
tool_version: n/a
---

# How I learned to read workflow logs and debug failures

> Following the GitHub Actions quickstart, here's what worked and where it broke.

## What I did

After setting up my first workflow, it failed. The Actions tab showed a red X but the error message was cryptic. I spent a while learning how to read the logs and diagnose the problem.

## Steps I took

1. Opened the Actions tab in my GitHub repo and clicked on the failed workflow run.
2. Expanded the failed job to see the list of steps and their status.
3. Clicked on the step that failed to view its log output.
4. Looked for the error message at the bottom of the log — usually a non-zero exit code or a command not found error.
5. Fixed the issue in my workflow file, committed, and pushed to trigger a new run.

## Got stuck on

- The first time I looked at the logs, I didn't realize I needed to expand the individual step to see its output. The job-level summary only shows pass/fail, not the actual error.
- I kept getting confused about whether a failure in one step stops the entire job or just that step. By default, a failure in any step stops the job. I had to read the docs to confirm this.
- I didn't know about the `debug` logging option (`ACTIONS_STEP_DEBUG`) that shows more verbose output for troubleshooting.

## What I'd try next

I want to set up a workflow that runs a linter and a test suite, so I can practice reading logs when those fail. Then I'd explore using the GitHub CLI (`gh run view`) to pull logs from the command line instead of the web UI.