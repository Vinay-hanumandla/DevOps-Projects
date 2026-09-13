---
last_verified: 2026-09-13
tool_version: n/a
sources: []
---

# my-cli-tool

A Python CLI tool scaffold with Docker and GitHub Actions CI.

## Project Structure

```
├── src/cli/          # Application source
│   ├── __init__.py
│   └── main.py       # Click-based CLI entry point
├── tests/            # Pytest tests
│   └── test_cli.py
├── .github/workflows/ci.yml   # Lint, test, docker build
├── Dockerfile        # Multi-stage build, non-root user
├── pyproject.toml    # PEP 621 project metadata
└── README.md
```

## Quick Start

```bash
# Install in editable mode with dev dependencies
pip install -e ".[dev]"

# Run the CLI
my-cli --help
my-cli greet World
my-cli status

# Run tests
pytest

# Lint
ruff check src/ tests/
ruff format --check src/ tests/
mypy src/
```

## Docker

```bash
docker build -t my-cli-tool .
docker run --rm my-cli-tool status
docker run --rm my-cli-tool greet Docker
```

## CI Pipeline

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs three jobs:

1. **lint** — ruff check, ruff format, mypy
2. **test** — pytest
3. **docker** — builds and smoke-tests the container (runs after lint+test pass)

## Customizing

- Rename `my-cli-tool` in `pyproject.toml` and the CLI module
- Add commands to `src/cli/main.py` using Click groups
- Extend the Dockerfile for additional runtime dependencies
