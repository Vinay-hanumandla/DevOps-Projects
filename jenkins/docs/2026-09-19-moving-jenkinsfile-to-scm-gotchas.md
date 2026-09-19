---
last_verified: 2026-09-19
tool_version: n/a
---

# Moving my Jenkinsfile from inline script to SCM — what tripped me up

Last session I ran the declarative pipeline tutorial with the Jenkinsfile pasted straight into the "Pipeline script" box. That worked, so this time I tried the grown-up version: same three stages, but with the Jenkinsfile living in a Git repo and the job set to "Pipeline script from SCM". I expected a five-minute change. It took me most of the evening, and every detour taught me something the tutorial never spelled out.

## The job could not find my Jenkinsfile

Under job configuration I switched the Definition dropdown to "Pipeline script from SCM", picked Git, and pasted my repo URL. First build failed immediately saying no Jenkinsfile was found. My mistake: I had committed it as `jenkins/Jenkinsfile` in a subfolder, but the "Script Path" field defaults to `Jenkinsfile` at the repo root. I fixed it by moving the file to the root rather than fighting the default — one less custom path to remember.

## Branch specifier pointed at the wrong default branch

Next failure: the checkout step kept complaining it could not find the revision. The "Branch Specifier" field ships prefilled with `*/master`, and my repo's default branch is `main`. The job was faithfully looking for a branch that does not exist. Changing it to `*/main` turned the red build green. I now check that field first whenever a checkout fails, before suspecting anything fancier.

## Lightweight checkout left my workspace empty

I ticked "Lightweight checkout" because it sounded faster, and it is — Jenkins fetches only the Jenkinsfile to start. What I did not realize is that the rest of the repo never lands in the workspace, so my `sh 'ls'` step showed nothing and a later step that needed a script from the repo failed. Adding an explicit `checkout scm` stage right after my Build stage fixed it: the Jenkinsfile still loads fast, and the full repo is there when the steps need it.

## Credentials for the repo took two attempts

My repo needs authentication, so I created a username/password credential in Jenkins and selected it in the job. First attempt failed with an auth error because I had typed the credential ID from memory and gotten one character wrong. Recreating it by copying the ID straight from the credentials page fixed the checkout. Lesson learned: credential IDs are opaque strings, never retype them.

## What worked

Once the checkout was right, the pipeline itself needed zero changes from the inline version — same `agent any`, same three stages, same `post { always }` block. That was the pleasant surprise: the Jenkinsfile is portable between inline and SCM modes, and all my pain was in the job configuration around it, not the pipeline syntax.

## What I'd try next

Add a `parameters` block with a choice parameter for the deploy target, then gate the last stage with a `when` condition on it. That is the first thing the inline tutorial cannot show me, since parameters only make sense once the job is a real, repeatable thing rather than a paste-and-run demo.
