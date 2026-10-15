---
last_verified: 2026-10-11
tool_version: n/a
sources: []
---

# Running the kit conformance checker in CI

> How I wired `repo-doc/scripts/kit-conformance-checker.py` into a GitHub Actions
> workflow so every PR is checked against the task list, the manifest snapshot,
> and the kit tree before it lands.

## Purpose

The checker already exists as a local tool — point it at a kit root, a task
list, and a manifest and it reports whether the three agree. This doc is about
the integration step: turning that manual run into a CI gate that fails a PR
when the ACTIVE task entries are malformed, when the manifest queue snapshot is
out of sync with the task list, or when an open task's id prefix has no
matching folder under the kit root.

## When to use this

Any PR that touches the task list, the manifest, or the kit tree should run this
check. It is cheap (pure Python, stdlib only, a few hundred milliseconds on the
real repo) and it catches the class of error that is otherwise invisible until
a human eyeballs the diff: a stale queue entry, a dropped required field, a
task id whose folder was renamed.

## Prerequisites

- Python 3.9 or newer on the runner (the script uses `pathlib` and
  `argparse` only).
- The task list and the manifest are both committed in the repo, so the workflow
  can check them out as part of the clone.
- The checker script itself is present at
  `repo-doc/scripts/kit-conformance-checker.py`.

## Steps

1. Create a workflow file under `gha/workflows/`, for example
   `kit-conformance.yml`.

2. Set the trigger to `pull_request` so the check runs on every opened or
   updated PR. A `push` trigger to the default branch is optional — it keeps
   the baseline green after a merge.

3. Add a job that checks out the repo and runs Python. Keep the job minimal;
   no extra setup step is needed because the script has no dependencies.

4. Invoke the checker with the three inputs it needs:

   ```yaml
   - name: Run kit conformance checker
     run: |
       python3 repo-doc/scripts/kit-conformance-checker.py \
         --kit-root . \
         --tasks-file TASKS.md \
         --manifest MANIFEST.json
   ```

5. The workflow step inherits the shell, so a non-zero exit from the checker
   fails the job. That is the whole gate — the script prints `FAIL:` lines to
   stderr and exits 1 when it finds a problem.

## Verify

After adding the workflow, open a draft PR and confirm two things:

- A clean PR shows `ok: tasks, manifest, and kit tree agree` (or only `notice:`
  lines) and the job passes.
- To confirm the gate actually bites, temporarily delete a required field from
  one ACTIVE entry in the task list. The job should fail with a `FAIL:` line
   naming the task id and the missing field. Revert the change before
   merging.

## Gotchas to watch for

These are the failure modes that show up when this check is wired into a real
CI run. They are not errors anyone reported to me; they are the ones that are
most likely to bite, listed here so the wiring does not have to rediscover
them.

- **The script must be invoked from its committed path.** If the workflow
  references a path that only exists on the default branch, every PR shows a
  false failure. Use the path the script has in the repo so the checked-out PR
  copy is the one that runs.
- **A missing input silently skips checks.** The checker treats a missing
  `--tasks-file` or `--manifest` as a notice rather than an error, so a typo'd
  path makes the job go green while skipping the check it exists to perform.
  Pass both explicitly and treat a notice-only run as "not actually verified"
  until the notices are gone.
- **Out-of-scope prefixes are notices, not failures.** Task ids whose prefix has
  no kit folder (platform-integrated tools such as `hchart`, `tfc`, `compose`)
  are reported as notices. That is expected, not a misconfiguration.

## What to try next

The gate is now in place and it runs on every PR. The next step is to make the
notices actionable — have the workflow attach a summary comment on the PR
listing the notices alongside the failures, so a human does not have to open
the run log to see what was skipped.