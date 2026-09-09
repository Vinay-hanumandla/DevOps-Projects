---
last_verified: 2026-09-08
tool_version: n/a
sources: []
---

# Choosing between submodules, subtrees, and monorepo

> First-day notes on shared library strategies. Personal voice, plain language.

## What I tried

I needed to share a common utility library across three internal services. I spent the afternoon reading about Git submodules, subtrees, and the monorepo approach, then tried the first two on a small test repo.

## What I found

**Submodules** felt like a separate Git repo living inside another. `git submodule add` points your parent repo at a specific commit in the child. The downside is every clone needs an extra `git submodule update --init --recursive`, and forgetting that step gives you an empty directory. CI pipelines need extra steps too.

**Subtrees** merge the child repo's history into a subdirectory of the parent. `git subtree add --prefix=libs/foo` pulls the whole thing in. The parent now owns the code; contributors to the child don't need to know about the subtree. The trade-off is the parent repo's history gets bigger, and pushing changes back upstream takes more ceremony.

**Monorepo** just puts everything in one repo from the start. No submodules, no subtree commands. The downside is the repo can get large, and you need a tool like Bazel or just careful directory ownership to keep builds fast.

## What I'd use next

For our case — three services, one small library, infrequent library changes — I'd probably start with a subtree. It keeps the parent simple for contributors and doesn't force a monorepo restructuring. If the library grows and gets its own team, I'd revisit submodules.

## What I'm still fuzzy on

I haven't tried subtree merges under heavy concurrent development yet. I'm also not sure how subtrees interact with protected branches on GitHub.
