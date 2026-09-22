---
last_verified: 2026-09-22
tool_version: n/a
---

# Comparing Ansible retry strategies for unreliable targets

## Purpose

Some targets do not respond cleanly on the first try: a service that is still starting, a flaky endpoint behind a slow link, or a long download that times out halfway. This doc compares three retry patterns — `until`/`retries` loops, the `wait_for` module, and `async` polling — and records when each one is the right fit.

## When to use which

- `until` with `retries` fits a task that can fail and should simply be tried again, like polling an endpoint until it returns the expected result.
- `wait_for` fits waiting on a precondition before doing real work, like a port becoming reachable after a reboot.
- `async` with polling fits a single task that takes a long time, where holding the connection open for the whole run is wasteful or risky.

The docs also suggest combining them: `wait_for` first to gate on readiness, then `until`/`retries` around the fragile step itself. That combination is one way to do it; using only one of the three also works for simpler cases.

## Steps

1. **Retry a fragile task with `until` and `retries`.** The task runs, its result is registered, and Ansible repeats it until the `until` condition is true or the retry budget runs out.

   ```yaml
   - name: Wait for the app to answer
     uri:
       url: "{{ health_endpoint }}"
       return_content: yes
     register: health
     until: "'ok' in health.content"
     retries: 5
   ```

   Each attempt re-executes the whole module. This is the right choice when every retry is cheap and safe to repeat, such as an HTTP check or a package install against a flaky mirror.

2. **Gate on readiness with `wait_for`.** Instead of retrying the real task, wait for the precondition it needs — typically a port or a file — then proceed once.

   ```yaml
   - name: Wait for the service port after restart
     wait_for:
       host: app.internal
       port: 8080
   ```

   `wait_for` blocks on that one host until the condition holds or it times out. It keeps the playbook readable because the waiting logic lives in one dedicated step rather than being wrapped around every later task.

3. **Run long work in the background with `async` polling.** For a task that takes minutes, start it asynchronously and poll for completion instead of holding the session open.

   ```yaml
   - name: Run the slow migration
     command: /opt/app/migrate.sh
     async: 600
     poll: 15
     register: migration
   ```

   Here the task is allowed up to 600 seconds, with Ansible checking back every 15 seconds. Setting the poll interval to zero would fire-and-forget instead, which is a different pattern — useful for reboots, but then a later step has to check the result explicitly.

4. **Compare on three axes before choosing.** Repeat-safety: `until`/`retries` re-runs the module each time, so the task must be idempotent; `wait_for` never re-runs real work; `async` runs the task exactly once. Feedback: `until` shows each attempt in the output, `wait_for` shows a single wait, `async` shows poll cycles. Failure mode: `until` fails when the budget is exhausted, `wait_for` fails on timeout, `async` fails when the job itself fails or exceeds its limit.

## Verify

- Run the playbook against a stopped service and confirm the `wait_for` step blocks, then proceeds once the service is started by hand.
- Temporarily point the `until` example at a bad path and confirm it retries the configured number of times before failing, rather than failing on the first attempt.
- Run the `async` example with a short sleep command and confirm the poll messages appear and the registered result contains the job outcome.
