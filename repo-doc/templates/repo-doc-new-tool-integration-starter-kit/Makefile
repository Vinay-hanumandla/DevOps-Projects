# last_verified: 2026-10-20
# Repo: task integration starter kit Makefile
.PHONY: help check lint

help:
	@echo "Available targets: check, lint"

check:
	@bash -n scripts/*.sh && echo "Shell syntax check passed"

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
	  shellcheck scripts/*.sh && echo "Shellcheck passed"; \
	else \
	  echo "shellcheck not installed, skipping"; \
	fi
