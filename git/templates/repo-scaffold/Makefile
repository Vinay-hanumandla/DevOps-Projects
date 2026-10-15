# last_verified: 2026-10-15 · git n/a
# Check targets for the repo-scaffold template. `test` runs the scaffold's
# self-tests, `lint` runs shellcheck over every script and hook, and `check`
# runs both. The pre-commit hook invokes `make test` when this Makefile is
# present, and CONTRIBUTING.md documents the same three targets, so the
# target names are part of the scaffold's contract: do not rename them.
#
# Project prerequisites:
#   test: git, bash, awk, mktemp — the same tools scripts/update-changelog.sh
#         already requires; no extra packages.
#   lint: shellcheck on PATH (lint only). Install it from the system package
#         manager, then re-run `make lint`.
#   make: any make that handles standard explicit rules; the recipes use tabs
#         and plain shell lines, no GNU extensions.
#
# Usage:
#   make        print the target list (same as `make help`)
#   make test   run scripts/run-tests.sh
#   make lint   shellcheck scripts/ and hooks/
#   make check  run test, then lint (the CI gate)

.PHONY: help test lint check

help:
	@echo "test   run the scaffold self-tests (scripts/run-tests.sh)"
	@echo "lint   shellcheck scripts/ and hooks/ (requires shellcheck)"
	@echo "check  test + lint"

test:
	./scripts/run-tests.sh

lint:
	@command -v shellcheck >/dev/null 2>&1 || { echo "lint requires shellcheck on PATH; install it from the system package manager and re-run 'make lint'." >&2; exit 1; }
	shellcheck --severity=warning scripts/*.sh hooks/pre-commit hooks/commit-msg

check: test lint
