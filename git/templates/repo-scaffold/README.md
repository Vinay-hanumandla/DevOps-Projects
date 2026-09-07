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
├── .gitignore
├── .github/
│   ├── CODEOWNERS
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
├── hooks/
│   ├── pre-commit
│   ├── commit-msg
│   └── README.md
└── CONTRIBUTING.md
```

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