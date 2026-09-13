---
last_verified: 2026-09-13
tool_version: n/a
sources: []
---

# Companion forgotten.txt for the Git undo notes

Problem: `git commit --amend` lets you rewrite the last commit, but you might stage more than you meant.

Fix: Before amending, run `git status` and `git diff --staged`. If you see a file you didn't intend to include, unstage it with `git restore --staged <file>` first, then amend.

Problem: Amending a commit that was already pushed rewrites shared history.

Fix: Check if the commit has been pushed. If `git log origin/<branch>..HEAD` shows nothing, the commit is local-only and safe to amend. If it shows commits, do NOT amend — create a new commit instead.

Problem: Forgetting a file in an amended commit on a shared branch causes confusion.

Fix: Always verify with `git log --oneline origin/<branch>..HEAD` before `--amend`. If the commit is public, revert the amend with `git reflog` and `git reset --hard HEAD@{1}`.