# Glossary

## Docker

- **Image** — an immutable, layered template (built from a Dockerfile) that defines a container's filesystem and start command.
- **Container** — a running instance of an image; isolated but ephemeral, so anything written inside is lost when it stops unless a volume is mounted.
- **Tag** — a label on an image (e.g. `nginx:1.25`); pulling without one defaults to `:latest`, which is why pinning a version matters for reproducibility.
- **Port mapping** — binding a host port to a container port with `-p host:container` (host port first); `docker port <container>` shows the resolved mapping.
- **Detached mode** — running a container with `-d` so it runs in the background instead of holding the terminal; view its output later with `docker logs <container>`.
- **Multi-stage build** — using several `FROM` stages in one Dockerfile to build in a heavy toolchain image and copy only the compiled artifact into a small final image.
- **Distroless image** — a minimal final image containing only the app and its runtime dependencies (no shell, package manager, or OS utilities), which shrinks attack surface.
- **Non-root runtime** — configuring the container to run as an unprivileged UID instead of root, a basic security hardening step.
- **Volume** — a persistent, host-managed storage mount that survives container restarts, used when data must outlive the container.

## Git

- **Staging area (index)** — the intermediate holding place between your working directory and a commit; `git add` moves changes here, `git commit` snapshots them.
- **Commit** — a snapshot of the staged changes with an author stamp and message; the unit of history in a repository.
- **Branch** — a movable pointer to a commit; `git switch <name>` creates the context where new commits land without touching other lines of work.
- **HEAD** — the currently checked-out commit/branch; commands like `git reset` and `git restore` resolve "here" against it.
- **Remote** — another copy of the repository (usually `origin`); `git push` sends commits to it and `git fetch`/`pull` brings theirs in.
- **Upstream tracking** — a branch's remembered remote counterpart, set with `git push -u`, so later `git push`/`git pull` need no extra arguments.
- **Stash** — a scratch holding area for uncommitted changes (`git stash`) so you can switch context and reapply them later with `git stash pop`.
- **Revert** — `git revert <commit>` makes a new commit that undoes an earlier one; safe on shared branches because it doesn't rewrite history.
- **Reset** — `git reset` moves HEAD (and optionally the index/working tree); `--soft` keeps changes staged, `--hard` discards them, so use it with care.
- **Amend** — `git commit --amend` rewrites the most recent commit (message or contents); fine locally, dangerous once pushed.
- **Patch staging** — `git add -p` stages only selected hunks of a file so unrelated edits can land in separate commits.
