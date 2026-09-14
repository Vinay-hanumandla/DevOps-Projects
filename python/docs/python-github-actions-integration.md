---
last_verified: 2026-09-14
tool_version: n/a
sources: []
---

# Integrating Python with GitHub Actions: matrix testing, dependency caching, and release automation

> A practical guide to setting up CI/CD for Python projects using GitHub Actions — covering matrix builds across Python versions, pip caching to speed up workflows, and automating package releases.

## Why GitHub Actions for Python?

GitHub Actions is the natural CI/CD choice for Python projects hosted on GitHub. The runner images come pre-installed with Python (multiple versions via `actions/setup-python`), pip, and common build tools. The workflow syntax is YAML-based and lives in the repo, so the CI configuration version-tracks alongside the code.

For Python projects specifically, GitHub Actions gives you:
- Matrix builds to test across multiple Python versions and OS combinations.
- Built-in caching for pip dependencies, which cuts workflow time significantly.
- Marketplace actions for publishing to PyPI, creating GitHub releases, and more.

## Matrix testing

Matrix builds let you run the same workflow across multiple combinations of Python version and operating system. This catches compatibility issues early — for example, a dependency that installs fine on Python 3.11 but fails on 3.9, or a path separator issue that only manifests on Windows.

### Basic matrix setup

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        python-version: ["3.9", "3.10", "3.11", "3.12"]
      fail-fast: false

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Run tests
        run: pytest --tb=short
```

The `fail-fast: false` setting is worth calling out. By default, GitHub Actions cancels all matrix jobs as soon as one fails. For CI that's often the right behavior — why waste minutes on jobs that will fail for the same reason. But for compatibility testing, you usually want to see the full picture: which combinations pass and which fail. Setting `fail-fast: false` lets all jobs run to completion.

### Conditional matrix entries

Sometimes you only want to test certain combinations. For example, testing PyPy only on Ubuntu, or testing older Python versions only on Linux:

```yaml
strategy:
  matrix:
    os: [ubuntu-latest]
    python-version: ["3.9", "3.10", "3.11", "3.12"]
    include:
      - os: macos-latest
        python-version: "3.12"
      - os: windows-latest
        python-version: "3.12"
```

This runs the full Python version matrix on Ubuntu, and only the latest version on macOS and Windows. It keeps CI fast while still catching platform-specific issues.

## Dependency caching

pip installs can be slow, especially for projects with heavy dependencies (NumPy, pandas, PyTorch). GitHub Actions has a built-in cache mechanism, and `actions/setup-python` supports pip caching out of the box.

### Automatic pip caching

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.12"
    cache: "pip"
```

When `cache: "pip"` is set, `setup-python` looks for dependency files (`requirements*.txt`, `setup.py`, `setup.cfg`, `pyproject.toml`) and caches the pip download directory. On subsequent runs, pip skips downloading packages that are already cached.

The cache key is derived from the content of your dependency files. When you change `requirements.txt`, the cache invalidates and pip re-downloads. When you don't, it reuses the cached packages.

### Manual caching for more control

If you need more control — for example, caching a virtual environment or a custom pip cache directory — you can use `actions/cache` directly:

```yaml
- name: Cache pip
  uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements*.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-

- name: Install dependencies
  run: pip install -r requirements.txt
```

The `restore-keys` fallback is important. If the exact key doesn't match (because you changed a dependency), GitHub Actions tries the prefix match and restores the closest available cache. This means pip only downloads the delta, which is still faster than a cold install.

## Release automation

For Python packages published to PyPI, GitHub Actions can automate the entire release process: build the package, create a GitHub Release, and publish to PyPI — all triggered by a git tag.

### Publishing workflow

```yaml
name: Release

on:
  push:
    tags:
      - "v*"

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # for trusted publishing
      contents: write   # for creating GitHub releases

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Build package
        run: |
          python -m pip install --upgrade pip build
          python -m build

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: dist/*
          generate_release_notes: true

      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
```

### Trusted publishing (recommended)

The workflow above uses PyPI's trusted publishing feature. Instead of storing a PyPI API token as a GitHub secret, you configure PyPI to trust your GitHub repository and workflow directly. This is more secure because:
- No long-lived token to rotate or leak.
- The OIDC token is scoped to the specific repository and workflow.
- You can restrict publishing to specific tags or branches on the PyPI side.

To set it up, configure a "trusted publisher" on PyPI pointing to your GitHub repository, workflow filename, and optionally a specific environment name.

### Version bumping strategy

A common pattern is to derive the version from the git tag:

```yaml
- name: Get version from tag
  id: version
  run: echo "VERSION=${GITHUB_REF_NAME#v}" >> "$GITHUB_OUTPUT"

- name: Build package
  run: python -m build
  env:
    SETUPTOOLS_SCM_PRETEND_VERSION: ${{ steps.version.outputs.VERSION }}
```

This way, `git tag v1.2.3 && git push --tags` triggers a build that publishes version 1.2.3 to PyPI. The version string lives in one place (the git tag) rather than being hardcoded in `pyproject.toml` and forgotten.

## Putting it all together

A typical Python project CI/CD setup on GitHub Actions looks like this:

```
.github/
  workflows/
    ci.yml          # matrix testing + linting on push/PR
    release.yml     # build + publish on tag push
```

The CI workflow runs on every push and PR — matrix testing across Python versions, linting with ruff, type checking with mypy if applicable. The release workflow runs only on tag pushes and handles building, GitHub Release creation, and PyPI publishing.

One thing worth noting: these workflows are independent. The release workflow doesn't depend on CI passing first. If you want that guarantee (only publish if tests pass on the tag), you can either make the release job depend on a CI job in the same workflow, or use a separate workflow with `workflow_run` triggers.

## Common pitfalls

**Forgetting to install the package itself.** Many CI workflows install dependencies but forget `pip install -e .` (or `pip install .`). This means the tests run against whatever is in the Python path, not the actual package. If your tests import from the package, they'll fail with `ModuleNotFoundError`.

**Not pinning actions.** Using `actions/checkout@v4` is fine, but `actions/checkout@main` is risky — a breaking change in the action could silently break your workflow. Pin to a major version at minimum.

**Cache invalidation surprises.** If your dependency files don't change but the pip cache format changes (rare, but it happens across Python versions), cached packages can cause install failures. Adding `pip install --upgrade pip` before installing dependencies mitigates this.

**Windows path issues.** `setup-python` adds Python to `PATH` differently on Windows. If your workflow uses `python` on Linux but `py` on Windows, the matrix will fail on Windows. Stick with `python` and let `setup-python` handle the aliasing.
