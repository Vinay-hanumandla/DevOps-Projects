---
last_verified: 2026-09-06
tool_version: n/a
---

# Following the official Jenkins tutorial

I worked through the official Jenkins tutorial today to see how declarative pipelines actually behave. The primer covered install and first-run, so this was my first real attempt at writing something beyond "Hello World."

## Setting up the first pipeline

From the dashboard I created a new Pipeline item and pasted a small declarative Jenkinsfile directly into the "Pipeline script" box. The example had three stages: Build, Test, and Post. Build just echoed a message, Test did the same, and Post declared `always` and `success` blocks. Very small, but it showed the required shape — `pipeline { agent any; stages { ... } }`.

After hitting **Build Now**, the build appeared in the Build History within a few seconds. I clicked into it and opened **Console Output** to confirm each stage ran in order and the build finished green.

## What tripped me up

**Agent declaration:** The example uses `agent any`, which worked, but I spent a few minutes wondering why Jenkins didn't prompt me for a node label. Turns out `agent any` means "run on whatever executor is available," and in a single-controller setup that's always the built-in node. I had assumed it would fail without an explicit label.

**Stages vs. steps:** I kept confusing stages with steps. A stage is a named phase like "Build," and steps are the individual actions inside it. In a tiny example the distinction feels pointless, but it matters when you add `parallel` blocks or wrap stages in `when` conditions.

**Post block firing order:** The `post` section runs after every execution, not just failures. `always` fires on green, red, and aborted runs; `success` only on green. I initially thought `always` was redundant — it isn't, because both blocks fire when the build succeeds.

**Console output location:** I expected a big status badge on the dashboard. Jenkins does show green/red in Build History, but the actual `echo` output is buried one click deeper under **Console Output**. Not hidden, just not where I looked first.

## What worked

Once I pasted the Jenkinsfile and triggered the build, everything executed in order. The pipeline syntax validator (the link beside the script box) caught a missing closing brace before I even ran the build — that was a useful safety net.

## What I'd try next

Point the pipeline at a real Git repository instead of inline script. Let Jenkins clone the repo, pick up the Jenkinsfile from the default branch, and run the same stages automatically. That's where pipelines start to feel useful rather than just a guided demo.
