---
last_verified: 2026-07-28
tool_version: n/a
sources: []
---

# Companion forgotten.txt for the Git undo notes

After writing the Git undo-stage-commit-push notes (2026-07-13-undo-stage-commit-push.md), I realized the `git commit --amend` section mentions a forgotten file but doesn't explain the pattern well enough. I created a companion `forgotten.txt` that distills the forgotten-file-while-amending scenario into a clear reference. The undo notes are dense — covering staging tricks, three kinds of undo, pushing, and amend — so a separate file keeps the caution about forgotten files memorable and easy to find.

## What I included in forgotten.txt

I listed the exact command sequence from the undo notes — `git add forgotten.txt && git commit --amend --no-edit` — and added a warning line beneath it explaining that this rewrites history. I also added a "check before you amend" checklist: did I stage anything I didn't mean to? Is this commit already pushed? The checklist is a quick scan, not a novel.

## Where I got stuck

I debated whether the companion should be a `.txt` file or a `.md` file. The undo notes themselves are Markdown, so a companion `.txt` would signal "this is a lightweight reference, not another essay." But I kept writing more than a text file should hold. I eventually settled on a short `.txt` with a few lines of checklist text and the command pattern — nothing more.

## What I'd try next

I want to test whether having this forgotten.txt alongside the undo notes actually helps someone avoid the accidental amend-with-forgotten-file mistake. I'll also check if the same pattern applies to `git rebase` — the undo notes mention rebase as something to practice next, and forgetting files during a rebase could be even worse.