---
last_verified: 2026-09-30
tool_version: n/a
sources: []
---

# Git repository scaffold

> A starter layout for a Git repository: commit hooks, a CODEOWNERS file, a
> pull-request template, a contributing guide, an append-only changelog with a
> generator behind it, and a version-controlled branch-protection policy. Copy
> the folder into any repository that needs a consistent collaboration
> contract.

## Layout

```
repo-scaffold/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── .gitignore
├── .github/
│   ├── CODEOWNERS
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── changelog-automation.yml
│       └── branch-protection.yml
├── hooks/
│   ├── pre-commit
│   ├── commit-msg
│   └── README.md
└── scripts/
    └── update-changelog.sh
```

## Install

Copy the scaffold into the root of a fresh repository and enable the hooks:

```bash
cp -r /path/to/repo-scaffold/. <your-repo>/
cd <your-repo>
git config core.hooksPath hooks
chmod +x hooks/pre-commit hooks/commit-msg
git add . && git commit -m "chore: add repo scaffold"
```

Nothing in the scaffold depends on a language runtime, a package manager, or
another template directory. `scripts/update-changelog.sh` is bash, `git` and
`awk`, so it behaves the same in a runner and in a terminal.

## Changelog

`CHANGELOG.md` is append-only. Released entries live under a versioned heading
and are never rewritten, because release-notes tooling keys off line order.
`scripts/update-changelog.sh` owns exactly one region of the file — the block
under `## [Unreleased]` — and rebuilds it from the conventional commits landed
since the last release tag:

- commits are grouped into `### Added` / `### Changed` / `### Fixed` from their
  conventional-commit type; subjects that do not follow the convention land
  under `### Changed`;
- `chore`, `ci` and `build` are dropped by default (`SKIP_TYPES` overrides);
- the block is replaced, never appended to, so re-running the script over an
  unchanged commit range leaves the file byte-identical;
- an empty range is reported and exits 0 without touching the file;
- a changelog with no `## [Unreleased]` heading is an error, because silently
  adding a second one is how changelogs grow duplicate sections.

`.github/workflows/changelog-automation.yml` runs it from two jobs: a
`regenerate` job on pushes to the default branch that commits the result back,
and a `verify` job on every pull request that runs the same script and fails
if the generator breaks. The verify job never writes to the repository, so a
generator change is caught on the branch that introduced it rather than on the
default branch afterwards.

If the default branch is protected by `branch-protection.yml`, the push the
`regenerate` job makes is subject to that policy. Either let the workflow's own
token bypass it, or leave the regenerated file for a maintainer to land.

## Branch protection

`.github/workflows/branch-protection.yml` applies a policy to the default
branch through the REST API, on the first `v*` tag push or on demand. The
policy requires listed status checks, an approving review with stale approvals
dismissed on push, linear history, and no force pushes or branch deletion.
Verified signed commits are opt-in through the `require_signatures` input.

Two things to know before enabling it:

- the PUT needs admin on the repository, and `GITHUB_TOKEN` is not sufficient
  for it, so the credential comes from an `ADMIN_TOKEN` repository secret;
- `required_checks` defaults to an empty list, because a freshly scaffolded
  repository has no checks yet. Set it to the job names your CI workflow
  actually reports before treating the policy as meaningful.

## Contributing

`CONTRIBUTING.md` describes the commit format, the branch workflow, and how to
run the checks. `.github/CODEOWNERS` decides who gets review requests
automatically — the last matching pattern wins, so put the broad `*` rule
first and the specific paths after it.
