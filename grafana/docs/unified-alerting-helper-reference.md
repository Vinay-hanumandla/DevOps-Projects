---
last_verified: 2026-10-05
tool_version: n/a
---

# Grafana unified alerting helper reference: rules, contact points, and notification policies

## Purpose

Grafana's unified alerting splits every alert into three pieces — a rule that decides *when* something is wrong, a contact point that decides *where* the message goes, and a notification policy that decides *which* messages reach *which* contact point. This doc records a small reusable helper convention for keeping those three pieces together: one folder with three files, one naming scheme, and one review checklist, so each new alert reuses the same shape instead of being invented from scratch in the UI.

## When to use

Use this helper when a team owns more than a couple of alerts and wants them reviewable as files — adding a second service, onboarding a second on-call rotation, or auditing what pages whom. Skip it for a single throwaway experiment; entering one rule directly in the UI is faster and there is nothing to reuse yet.

## Prerequisites

- Access to a Grafana instance with permission to manage alerting rules, contact points, and notification policies.
- At least one data source already returning data for the panels being alerted on.
- A throwaway destination for test notifications (a personal mailbox or a test channel), so the first dry run does not page anyone real.

## Steps

### 1. Create the helper folder

Keep three files side by side so a reviewer sees the whole alert path in one place:

```text
grafana/alerting/
  alert-rules.md          # one entry per rule: what fires, and how bad it is
  contact-points.md       # one entry per destination: who gets messaged
  notification-policies.md  # the routing tree: which alerts reach which destination
```

The files are plain notes, not imports — their job is to make the UI entries reproducible and reviewable. Each entry uses the naming scheme from step 2.

### 2. Name everything the same way

Give every rule a name of the form `<team>-<service>-<symptom>`, for example `payments-api-high-error-rate`. Use the same prefix for the policy matcher that routes it and note the owning team on the contact point. When an alert fires at night, the name alone tells the responder which team, which service, and which symptom — no lookup needed.

### 3. Write the rule entry first

Each rule entry records five things: the query or panel it watches, the threshold that means trouble, how often it is evaluated, a severity label (for example `warning` or `critical`), and where the runbook lives. Writing the runbook location before creating the rule forces the question "what would the responder actually do?" while the alert is still cheap to change.

### 4. Write the contact point entry next

Each contact point entry records the destination type (mail, chat channel, or webhook), the address, and which team owns it. Keep one entry per team-level destination rather than one per rule — five rules that all page the same rotation share one contact point, so a rotation change edits one entry instead of five.

### 5. Write the policy entry last

The policy file is a small routing tree: matchers on labels (team, severity, service) point at contact points, plus one default policy that catches anything no matcher claims. Keep the tree shallow — team first, then severity. A tree more than two levels deep becomes hard to predict, and an alert whose route cannot be predicted at review time will surprise someone later.

### 6. Enter the three pieces in the UI and link them

Create the contact points first, then the rules with the agreed names and severity labels, then the policies whose matchers select those labels. Creating them in this order means every dropdown the later step needs already exists, and a typo in a label shows up immediately as a matcher that selects nothing.

### 7. Run the review checklist before enabling

- Every rule has a severity label that some policy matcher selects.
- Every matcher selects at least one rule (no dead branches).
- The default policy points at a staffed destination, not an unmonitored mailbox.
- Every rule names its runbook location.

## Verify

1. Add one temporary rule whose threshold is already breached (for example, alert when a counter that is always positive exceeds zero).
2. Confirm the rule shows a firing state within one evaluation cycle.
3. Confirm the test notification arrives at the expected destination and carries the `<team>-<service>-<symptom>` name.
4. Delete the temporary rule and confirm the routing tree is back to exactly the reviewed entries — no leftover test artifacts.

## Common errors

- **Severity label missing on a new rule.** The rule fires but no matcher selects it, so it falls through to the default policy and pages the wrong team. Caught by checklist item 1 in step 7.
- **Matcher selects nothing after a rename.** Renaming a rule's team or severity label without updating the policy entry orphans the alert. Re-running the verify step after any rename catches this.
- **Test rule left enabled.** The temporary breached-threshold rule from the verify step keeps firing and spams the test destination. Step 4 of Verify (delete the temporary rule) exists because this happened on the first dry run.
