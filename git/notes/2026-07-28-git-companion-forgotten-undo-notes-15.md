---
last_verified: 2026-07-28
tool_version: n/a
sources: []
---

# Companion forgotten.txt for the Git undo notes (2026-07-15)

After writing the Git undo-stage-commit-push notes (2026-07-15-undo-stage-commit-push.md), I noticed the `git commit --amend` section warns about a forgotten file but the explanation lives inside the narrative flow. I created a companion `forgotten.txt` that pulls that warning out into a standalone reference card. The undo notes cover staging tricks, three kinds of undo, pushing, and amend — a companion keeps the "don't forget forgotten files" note easy to spot.

## What I included in forgotten.txt

I extracted the command sequence from the undo notes — `git add forgotten.txt && git commit --amend --no-edit` — and wrote a one-line warning that this rewrites history. I added a "check before you amend" checklist: unstage any unintended files with `git restore --staged <file>`, and verify this commit hasn't been pushed to a shared branch yet. The checklist is terse by design — just enough to catch the mistake before it happens.

## Where I got stuck

I kept wanting to expand the forgotten.txt into a full explanation of `git commit --amend` mechanics. That's what the undo notes are for — the companion should stay focused on the forgotten-file pattern specifically. I also struggled with naming: calling it `forgotten.txt` is explicit but a bit odd as a filename. I stuck with it because the original undo notes use `forgotten.txt` as the example文件名, so the companion should match.

## What I'd try next

I want to see if the same forgotten-file pattern shows up when practicing `git rebase` — the undo notes mention rebase as the next thing to learn. I also want to check whether the companion works better as a `.md` file for readability or `.txt` for "this is a quick reference, don't overread" signal. I'll compare both and see which gets used more.