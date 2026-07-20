#!/usr/bin/env bash
# last_verified: 2026-07-20 · Git

# My first Git repo lifecycle: init, add, commit, status.
# Minimal working example — no flags, no defensive boilerplate.

PROJECT="first-git-repo"
mkdir -p "$PROJECT"
cd "$PROJECT"
git init
echo "hello world" > readme.txt
git add readme.txt
git commit -m "first commit"
git status
