---
last_verified: 2026-09-07
tool_version: n/a
sources: []
---

# Contributing

Thanks for taking the time to contribute. This document describes how to work
in this repository so everyone's pull requests follow the same contract.

## Getting started

1. Fork the repository and clone your fork.
2. Create a feature branch from `main`:

   ```bash
   git checkout -b fix/your-change main
   ```

3. Make your change. Keep commits small and focused — one logical change per
   commit.

## Commit messages

We use the conventional commit format. Each commit message starts with a
type, an optional scope, a colon, and a short description:

```
feat(api): add GET /health endpoint
fix(auth): refresh token before it expires
docs(readme): document the branch-protection workflow
```

The `commit-msg` hook enforces this format locally. If your editor does not
run hooks, install them manually:

```bash
git config core.hooksPath hooks
```

## Pull requests

- Open one PR per change. Keep it reviewable.
- Fill in the pull-request template that ships with this scaffold.
- Link any issues the PR closes.
- Wait for at least one review and for required status checks to pass before
  merging.

## Code review

Reviewers focus on correctness first, style second. If a change is small and
self-evident, a quick "LGTM" is enough. If a change touches shared infrastructure
(hooks, CI, the build), expect a longer discussion.

## Running the checks

This repository ships a `Makefile` with the common targets:

```bash
make test      # run the test suite
make lint      # run shellcheck on every script
make check     # run both
```

Run `make` with no arguments to see the full list.

## Questions

Open an issue. Do not use pull requests for questions about how the repository
works — they are not tracked the same way and will be closed.