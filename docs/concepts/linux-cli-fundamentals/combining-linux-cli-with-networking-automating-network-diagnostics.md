---
last_verified: 2026-08-19
tool_version: n/a
sources: []
---

# Combining Linux & CLI with Networking — automating network diagnostics in shell

> This pattern combines Linux command-line fundamentals with networking concepts so that layered, scriptable diagnostics replace the repeat-manual-probe habit.

## Purpose

When a service is unreachable, the usual reflex is a sequence of one-off commands: `ping`, then `traceroute`, then `ss`, then `dig`, each read once and forgotten. For a single host that is fine; for a fleet or mid-outage it is slow and error-prone, and nothing is left behind to compare a minute later. Automating network diagnostics in the shell turns those probes into one repeatable check that asks the same layered question — reachable? path? port? DNS? — of many hosts and emits a report.

Linux & CLI supplies the control flow: loops, exit codes, redirection, and text filters. Networking supplies the mental model: each probe answers a different layer, so a failure at one layer tells the operator where to stop looking. The two combine so that "is my service up" becomes a single script run instead of a memorised routine.

## Steps

1. **Layer the checks.** Work from the bottom of the stack up: reachability (`ping`), path (`traceroute`), local sockets (`ss`), then DNS (`dig`). Ordering matters — a name that resolves wrongly is pointless to chase before you know the host answers at the network layer.

2. **Bound the reachability probe and read its exit code.** `ping -c 3 <host>` sends three probes and then exits; a script checks `$?` (or an `if ping ...; then`) rather than counting on human eyeballs. This is the CLI's big advantage over watching a terminal: the failure becomes a boolean.

3. **Trace the path only when reachability fails.** `traceroute <host>` shows each hop; where the chain stops is where the network path breaks. It is a slower probe, so gate it behind the reachability result rather than always running it.

4. **Check what is actually listening.** `ss -tlnp` lists listening TCP ports and the owning process. This separates "host up but nothing bound" from "host unreachable" without guessing.

5. **Resolve names and confirm the address.** `dig +short <host>` returns the address(es) the resolver answers with; compare against the address the reachability probe actually used to catch stale or wrong DNS.

6. **Loop over the hosts and collect a report.** Wrap steps 2–5 in a `for` loop over a host list, write each host's result line to a report file, and print the report when the loop finishes. Exit codes feed one summary column per host.

## Verify

- Run the assembled script against a known-good host and a known-bad host; the report must distinguish them in at least one column.
- Check that the script's overall exit code is non-zero when any host fails, so it can gate a follow-up action instead of silently producing an "all up" report.
- Confirm each probe's exit code, not the piped filter's, is what drives the summary — output through `grep` masks the original result and is a common source of false "up" readings.

## How this connects to what's next

The report this script prints is a primitive health check, which is the first step toward real observability — feeding those same probes into a metrics or alerting stack. The wrapping techniques (loops, exit-code discipline, redirection) are the core of the Scripting & Automation Philosophy, so this pattern is the bridge from "I know the commands" to "I can make the commands work for me."