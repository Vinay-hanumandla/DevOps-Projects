---
last_verified: 2026-07-13
tool_version: n/a
---

# Git Quickstart — what tripped me up

Following the official Git quickstart at git-scm.com was mostly smooth, but a few things caught me off guard. Here's what happened.

## Step 1: Installing Git

I already had Git installed, so `git --version` confirmed I was on a recent build. The quickstart says to configure your identity right away:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

I'd done this before, but I forgot that `--global` writes to `~/.gitconfig` — not the repo. Took me a minute to realize why my first commit used a different name (I had a project-level config overriding it).

## Step 2: Creating a repo

`git init` is straightforward. I created a test directory, ran `git init`, and got a `.git` folder. No surprises.

## Step 3: Staging and committing

This is where I tripped up. I ran:

```bash
git add .
git commit -m "first commit"
```

Then I realized `git add .` stages everything in the current directory — including a `node_modules/` folder I hadn't `.gitignore`d yet. The commit was bloated. I learned to always set up `.gitignore` before the first `git add`.

```bash
echo "node_modules/" >> .gitignore
git rm -r --cached node_modules
git commit -m "remove accidentally tracked node_modules"
```

## Step 4: Branching

Creating and switching branches worked fine, but I kept forgetting which branch I was on. `git branch` shows the current branch with an asterisk, but I wish it were more visible in the prompt. I added the branch name to my PS1 after this.

## Got stuck on

- **Detached HEAD.** I ran `git checkout <commit-hash>` to look at an old commit and ended up in detached HEAD state. I didn't realize I needed to create a branch if I wanted to make changes there. `git switch -c temp-branch` fixed it.
- **`git commit --amend`.** I amended a commit that had already been pushed (to a private test branch, luckily). Git warned me about diverging history. Safe for local-only commits, but I'll be careful not to amend pushed commits.

## What I'd try next

I want to practice undoing mistakes — `git reset`, `git revert`, and `git restore` all do different things, and I still mix them up. The git-002 task covers exactly that.
