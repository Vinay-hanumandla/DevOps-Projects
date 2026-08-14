---
last_verified: 2026-08-14
tool_version: n/a
sources:
  - https://github.com/gamgi/github-actions-vanilla-monorepo-example
  - https://linuxiq.org/shell-scripting-practical-notes-from-production/
---

# Project scaffold: Git-based release workflow

A starting layout for a repository whose releases are driven by Git tags, a
committed `VERSION` file, and small shell helpers. Copy the directory into a
project, rename it, adjust the bump rules in `lib/common.sh`, and start cutting
releases. The logic lives in standalone shell scripts rather than inline CI
steps so the same commands run identically from a terminal and from a pipeline.

## Layout

```
.
├── Makefile                 # release/changelog/lint targets that delegate to scripts
├── lib/
│   └── common.sh            # sourced helpers: clean-tree guard, version bumping
└── scripts/
    ├── release.sh           # bump VERSION, commit, tag, push (major|minor|patch)
    ├── changelog.sh         # print conventional-commit summary since a tag
    └── verify-release.sh    # end-to-end proof in a throwaway repo
```

The rule of thumb: `lib/` holds functions you `source` (never executes on its
own), `scripts/` holds the executable steps, and `verify-release.sh` replaces a
manual smoke test. Nothing loads a library at the top level, so `bash -n` and
shellcheck treat every file as self-contained.

## Getting started

Prerequisites: `git` and, if you want the lint target, `shellcheck`.

```sh
git init my-project && cd my-project
cp -r /path/to/git/templates/release-workflow/* .
git add . && git commit -m "chore: add release workflow scaffold"
printf '0.1.0\n' > VERSION && git add VERSION && git commit -m "chore: start at 0.1.0"
```

From here each release is one command:

```sh
make patch     # 0.1.0 -> 0.1.1
make minor     # 0.1.1 -> 0.2.0
make major     # 0.2.0 -> 1.0.0
```

You can also bump on a specific part over an existing version, for example
`./scripts/release.sh minor` when you are on `0.4.2`.

## Conventions baked in

- `VERSION` is the single source of truth; `release.sh` reads it, computes the
  next value with `next_version`, writes it back, and creates an annotated tag
  `v<version>`.
- `release.sh` refuses to run when the working tree is dirty
  (`assert_clean_tree`), so a release never wraps up half-committed work.
- The annotated tag message records the release number, which keeps `git
  describe` and changelog tooling unambiguous.
- If an `origin` remote exists the script pushes the current branch plus the new
  tag; with no remote it finishes with local commit + tag only.
- `make lint` runs `shellcheck` over `scripts/` and `lib/`; wiring that into a
  pre-commit hook is a natural next step.

## Verify

```sh
make verify        # runs verify-release.sh (creates a temp repo only)
make lint          # shellcheck scripts/ lib/
```

`verify-release.sh` builds a throwaway repository under `mktemp -d`, drops in the
scaffold, cuts a minor release, and asserts the tag `v0.2.0` landed. It cleans up
after itself on exit, so it is safe to run repeatedly.

This is one way to wire a tag-based release loop; the docs also suggest pushing
on a dedicated `release` branch or exporting the next version from
conventional-commit messages. Both fit on top of this layout.