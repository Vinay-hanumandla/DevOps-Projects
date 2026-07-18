---
last_verified: 2026-07-18
tool_version: 5.2.37
sources:
  - https://oneuptime.com/blog/post/2026-01-24-bash-command-not-found/view
---

# Install Bash and run my first script

I already have Bash on this system — it's at `/usr/bin/bash`, version 5.2.37. On a fresh Ubuntu machine I'd check with `bash --version`. If missing, `sudo apt install bash` is all it takes.

Wrote a one-liner to test it works:

```bash
echo "hello from bash $BASH_VERSION"
```

Saw `hello from bash 5.2.37(1)-release`. Good.

First script: I created `test.sh` with:

```bash
#!/usr/bin/env bash
echo "Script ran OK"
```

Ran `bash test.sh`. Got "Script ran OK". Tried `./test.sh` and hit "Permission denied" — forgot `chmod +x test.sh`. Fixed that, then `./test.sh` worked.

**Got stuck on:** Forgetting to make the script executable. Every time. I'll get into the habit of `chmod +x` right after creating a `.sh` file.

**What I'd try next:** Write a script that takes a command-line argument, checks if a file exists, and prints a custom message. That'll force me to use `$1`, `-f`, and `if`.
