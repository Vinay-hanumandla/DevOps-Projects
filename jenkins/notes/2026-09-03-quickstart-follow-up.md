---
last_verified: 2026-09-03
tool_version: n/a
sources: []
---

# Following the official Jenkins quickstart

I followed the Jenkins quickstart guide today to see how far I could get with a minimal pipeline. The primer got me through install and the web UI, so this was the next step — actually build something.

## Setting up the first pipeline

From the dashboard I clicked **New Item**, gave it a name, and picked **Pipeline**. The guide says to paste a Jenkinsfile directly into the web UI under "Pipeline script," which is the fastest way to get started. I grabbed the example declarative pipeline and dropped it in.

The example has three stages: Build, Test, and Post. The Build stage just runs `echo "Building..."`. Test runs `echo "Testing..."`. Nothing fancy, but it shows the shape of a real pipeline.

## What tripped me up

**Agent declaration:** The example uses `agent any`, which worked fine, but I spent a few minutes confused about why Jenkins didn't ask which node to run on. Turns out `agent any` means "run on whatever is available," and in a single-node setup that's always the master. I had assumed it would fail without an explicit label.

**Stages vs. steps:** I kept mixing up stages and steps. A stage is a named section (like "Build"), and steps are the actions inside it. The guide's example is small enough that this distinction seems pointless, but it matters once you have parallel stages or conditional logic.

**Post block semantics:** The `post` section runs after *every* run of the pipeline, not just on failure. The `always` block fires regardless, `success` fires only on green, and `failure` on red. I initially thought `always` was redundant — it's not, because it runs even when `success` or `failure` also fire.

**Console output location:** I expected a big green/red badge on the dashboard immediately. Jenkins showed the build in the history, but I had to click into it and then click **Console Output** to see the actual `echo` output. Not hidden, just not where I was looking.

## What worked

Once I pasted the Jenkinsfile and hit **Build Now**, the build showed up in the Build History within a few seconds. The console output showed each stage executing in order, and the whole thing finished green. The pipeline syntax validator (the link next to the script box) caught a missing closing brace before I even ran the build — useful safety net.

## What I'd try next

Wire up a real repository instead of inline script — point the pipeline at a Git URL and watch Jenkins clone, build, and test automatically. That's where pipelines start to feel useful rather than just a demo.
