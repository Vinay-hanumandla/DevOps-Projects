# last_verified: 2026-09-10 · Git n/a

Git quick primer companion: key points for quick reference.

What is it?
- Version control system, like save-points for code/documents.
- Stores full history locally in .git folder; works offline.

What does it do?
- Tracks changes over time with who/when/what.
- Branches for parallel development; merges combine work.
- Push/pull to remote servers (GitHub/GitLab) for collaboration.

Why does it exist?
- Replaces manual file copying and email zip exchanges.
- Makes history first-class; merges are automated, conflicts explicit.

Key terminology:
- Repository: folder Git tracks plus .git database.
- Commit: single snapshot with a message.
- Branch: parallel line of development.
- Working tree: files on disk you edit.
- Staging area: middle ground before commit.
- Clone: full copy of remote repo.
- Remote: named pointer to another repo copy.
- HEAD: pointer to current position in history.

Tiny example:
  git init my-project
  cd my-project
  echo "hello world" > readme.txt
  git add readme.txt
  git commit -m "first commit"
  git status

Next steps: install Git, set up identity, walk through first repo lifecycle.