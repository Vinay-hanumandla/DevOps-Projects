---
last_verified: 2026-09-14
tool_version: n/a
sources: []
---

# pyproject.toml — quick companion notes

> First-day notes on what the existing `pyproject.toml` actually does.

## What I see

I opened `2026-08-24-pyproject-toml-config.toml` and here's what each piece means to me right now.

## The build-system table

```toml
[build-system]
requires = ["setuptools"]
build-backend = "setuptools.build_meta"
```

This tells pip how to build the package. I need `setuptools` here even if I'm not uploading to PyPI — it's what makes `pip install -e .` work in development.

## The project table

```toml
[project]
name = "devops-learning-project"
version = "0.1.0"
```

This is PEP 621 — the standard metadata format. The `readme = "README.md"` line means my README gets included if I ever publish this. I added `requests` and `pydantic` as runtime deps because I know I'll need them.

## Optional dependencies

```toml
[project.optional-dependencies]
dev = ["pytest", "ruff"]
```

I split dev tools into their own group so CI can `pip install -e ".[dev]"` without pulling them into the running image. Works well for me so far.

## Tool config sections

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 88
```

These sections keep pytest and ruff config in the same file as my project metadata. One file to rule them all.

## What I'd try next

I want to add a `[project.scripts]` entry so I can run my tool from the command line without `python -m`. I'm also curious about `[tool.mypy]` for type checking — supposedly you can put it right here too.
