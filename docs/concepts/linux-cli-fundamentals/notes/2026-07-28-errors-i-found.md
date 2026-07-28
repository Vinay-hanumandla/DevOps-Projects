---
last_verified: 2026-07-28
tool_version: n/a
---

# Linux & CLI Fundamentals — errors-i-found companion notes

> Notes on what I learned running the primer's error-hunting command. First-person, scratchy — me talking to future me.

## What happened

The primer showed this command:

```bash
ls /var/log | grep -i error > errors-i-found.txt
```

I ran it on my machine and it hung for a second before spitting out a file. I was expecting something small — after all, my machine doesn't run much. But the file had about 40 lines of kernel messages and service failures from the last boot.

## Got stuck on

The first thing I noticed: the file included lines I didn't care about. Some were from my own services, others were kernel noise that changed every time I rebooted. I tried to narrow it down by chaining more greps:

```bash
ls /var/log | grep -i error | grep -v "kernel" > errors-i-found-clean.txt
```

That helped, but I realised I was just guessing at what to filter. The real skill here is knowing which log files matter in your environment — `syslog`, `auth.log`, `kern.log` — and which are noise.

Another thing: `grep -i` treats `ERROR`, `Error`, and `error` the same. That's handy for hunting, but I noticed some lines that said "Error" were actually from an `apt` update that failed, not a real service crash. Context matters — a word alone doesn't tell you if something is broken or just noisy.

## What I'd try next

I want to learn `journalctl` for filtering systemd logs instead of grepping through flat files. The primer touches on pipes and redirection, so the next step is combining `journalctl -p err` with `--since today` to get only today's errors in one shot.

I'd also like to practice writing a tiny script that checks `errors-i-found.txt` every hour and alerts me if the line count grows — that bridges the gap between CLI fundamentals and the shell scripting I'll tackle later.