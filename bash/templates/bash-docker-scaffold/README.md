---
last_verified: 2026-08-13
tool_version: n/a
sources:
  - https://libredevops.org/docs/documents/bash-standards/
  - https://devrail.dev/docs/standards/bash/
  - https://www.commandinline.com/shell-script-version-control-git/
  - https://zerowidth.com/2024/scripts-to-rule-them-all-with-containers/
  - https://blog.daryledesilva.com/docker-build-time-vs-runtime-the-post-install-hook-pattern/
  - https://docs.docker.com/build/building/best-practices/
---

# Project scaffold: Bash + Docker integration

A starting layout for a Bash project that leans on Docker for its toolchain.
Borrowed the conventions from the LibreDevOS Bash standards, the dev-toolchain
container pattern, and the deterministic-tag idea — links are in the
front-matter. Copy the directory, rename it, and start filling in real logic.

## Layout

```
.
├── Makefile                 # delegates lint/format/test to the toolchain container
├── Dockerfile               # dev image: shellcheck, shfmt, bats, coreutils
├── docker-entrypoint.sh     # runs docker-entrypoint.d/*.sh in order, then execs "$@"
├── docker-entrypoint.d/     # single-purpose start hooks, run before the main command
├── scripts/
│   └── app-env              # builds the toolchain image once, then docker run "$@"
├── bin/
│   └── app                  # executable entry point (no extension)
├── lib/
│   └── common.sh            # sourced helpers; never executes code on its own
└── tests/
    └── common_test.bats     # bats tests, mock external commands via PATH
```

The rule of thumb: `bin/` holds entry points, `lib/` holds functions you
`source`, `tests/` holds bats tests. A library file must not run anything at
the top level beyond defining functions and readonly constants.

## Getting started

Prerequisites: Docker only. Nothing bash-related needs installing on the host —
that is the whole point of the toolchain image.

```sh
make shell     # drop into the dev image interactively
make lint      # shellcheck everything, zero warnings expected
make format    # shfmt diff check (uses -d, never -w, in this pipeline)
make test      # run the bats suite
```

`scripts/app-env` tags the image from a hash of the Dockerfile and dependency
files, so the image is rebuilt only when those change. That keeps the host
clean and makes CI use exactly the same environment as local dev.

## Conventions baked in

- Every entry point starts with `#!/usr/bin/env bash` and `set -Eeuo pipefail`.
- `main()` is called only when the file is executed, not when it is sourced —
  this is what lets bats tests load `lib/common.sh` without running it.
- In a Dockerfile, `RUN` uses `/bin/sh -c` and only sees the exit code of the
  last command in a pipe; prefix `set -o pipefail` (or use exec form) so a
  failing `wget | wc -l` actually fails the build.
- Start hooks live in `docker-entrypoint.d/` and the entrypoint runs them in
  order before `exec "$@"`, so the real process becomes PID 1. This mirrors
  what the official nginx/postgres images do with their `*-initdb.d` dirs.

This is one way to wire the pieces together; the docs also suggest a pre-commit
hook running shellcheck on every commit, and tagging releases with semantic
versions before deploy. Both fit neatly on top of this layout.
