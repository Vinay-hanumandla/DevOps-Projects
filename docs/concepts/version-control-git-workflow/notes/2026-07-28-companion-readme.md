---
last_verified: 2026-07-28
tool_version: n/a
---

# Version Control & Git Workflow — companion README notes

> Notes on what I learned creating and maintaining a README as a first Git project. First-person, scratchy.

## What happened

The primer walked through creating a README with four commands:

```bash
git init
echo "hello" > README.md
git add README.md
git commit -m "first commit"
```

I followed along and it worked. But the interesting part wasn't the commands — it was thinking about what README.md actually is. It's the first thing someone reads when they land on a project, so it's the most visible file in the repo.

## Got stuck on

I spent more time than I expected deciding what to put in the README. The primer just says "hello", but a real README needs to explain what the project is, how to run it, and what it needs to run. I kept going back and forth between writing too little and too much.

Another issue: I forgot to add a `.gitignore` early. I committed a `__pycache__` folder by accident and had to `git rm --cached` it. Small mistake, but it taught me that the `.gitignore` is something I should set up before I even touch my first commit — not after.

The primer mentions `git diff` for showing uncommitted edits. I tried it after editing the README and couldn't tell the difference between the diff output and the file itself until I realised the diff uses `<` and `>` markers for removed and added lines. Paying attention to the format matters.

## What I'd try next

I want to practise writing a README for a real side project — not just "hello" but something with a description, install steps, and usage examples. Then I'd add a second collaborator (maybe a friend) and walk through the pull-request workflow: branch, commit, PR, review, merge. That would cement the collaboration side of version control that the primer hints at but doesn't exercise.

I'd also like to experiment with `git log --oneline --graph` to visualise how branches and merges look in the history — seeing the shape of the history helped me understand what a clean workflow feels like.