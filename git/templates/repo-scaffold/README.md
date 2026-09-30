---
last_verified: 2026-09-07
tool_version: n/a
sources: []
---

# Git repository scaffold

> A starter layout for a Git repository: commit hooks, branch protection
> policies, a CODEOWNERS file, and a CONTRIBUTING guide. Copy this folder into
> any repo that needs a consistent collaboration contract.

## Layout

```
repo-scaffold/
├── README.md
├── CHANGELOG.md
├── .gitignore
├── .github/
│   ├── CODEOWNERS
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       └── changelog-automation.yml
├── hooks/
│   ├── pre-commit
│   ├── commit-msg
│   └── README.md
└── CONTRIBUTING.md
```

## Changelog

`CHANGELOG.md` is append-only. New entries go under `## [Unreleased]` at the
top of the file and are moved into a versioned block when a tag is cut. The
`.github/workflows/changelog-automation.yml` job regenerates this file from
the commit history on every push to `main` and on PRs that are ready to
merge, then commits the result — so the changelog stays in sync without a
manual step.

## Install

Copy the scaffold into the root of a fresh repository:

```bash
git clone <your-repo>
cp -r /path/to/repo-scaffold/. <your-repo>/
cd <your-repo>
git add . && git commit -m "chore: add repo scaffold"
```

Then enable the hooks:

```bash
git config core.hooksPath hooks
```

## Branch protection

Apply the policy in `.github/workflows/branch-protection.yml` after the first
release tag exists. It enforces required status checks, a review before merge,
and linear history on the protected branch.

## Contributing

Point contributors at `CONTRIBUTING.md` and the pull-request template. The
CODEOWNERS file decides who gets review requests automatically.