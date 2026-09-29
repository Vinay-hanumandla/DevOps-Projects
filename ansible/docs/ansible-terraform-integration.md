---
last_verified: 2026-09-29
tool_version: n/a
---

# Ansible + Terraform integration: when to use each for provisioning vs configuration

## Purpose

Terraform and Ansible overlap enough that teams often reach for one to do the other's job: Terraform runs remote commands to configure a host, or Ansible creates cloud resources with modules. Both can work, but each fights the tool's strengths. This doc records the boundary that has held up best so far — Terraform provisions the infrastructure, Ansible configures what runs on it — and two small patterns for passing data between them.

## When to use which

- **Terraform** fits anything the cloud provider (or virtualization platform) owns: networks, subnets, virtual machines, managed databases, DNS records. Its state file is the argument for keeping this work there — it tracks what exists and plans the difference before changing anything.
- **Ansible** fits everything that happens *inside* a reachable machine: installing packages, rendering config files, enabling services, deploying an app build. It connects over SSH or WinRM and each task describes a desired end state on that host.
- The grey area is one-off bootstrapping (a package install right after a VM boots). This is one way to draw the line: if the step needs the provider API, it belongs in Terraform; if it needs a shell or config file on the host, it belongs in Ansible. The docs also describe provisioners inside Terraform for the bootstrap case, but keeping even that step in Ansible makes reruns easier to reason about.

## Steps

1. **Provision the infrastructure with Terraform and expose connection details as outputs.** The Terraform side creates the machines and emits whatever Ansible needs to reach them — addresses, hostnames, groups.

   ```hcl
   output "app_hosts" {
     description = "Addresses Ansible should configure"
     value       = aws_instance.app[*].public_dns
   }
   ```

   Keeping these outputs small and deliberate matters: every value here becomes part of the contract between the two tools, so outputting whole resource objects makes later refactors harder.

2. **Generate the Ansible inventory from Terraform outputs, not by hand.** After a successful apply, render the outputs into an inventory file (a small wrapper script or `terraform output` piped through a template works). Hand-maintained inventories drift from what Terraform actually created the first time a machine is replaced.

   ```ini
   [app]
   app-01.example.internal
   app-02.example.internal
   ```

   Regenerating the inventory on every apply is the pattern to aim for; a static file that someone edits after each scaling event is the failure mode to avoid.

3. **Configure the hosts with an Ansible playbook that assumes the machines already exist.** The playbook does no provisioning — no instance creation, no network changes — only packages, files, and services.

   ```yaml
   - name: Configure application hosts
     hosts: app
     become: true
     tasks:
       - name: Install the app package
         package:
           name: myapp
           state: present
       - name: Render the app config
         template:
           src: myapp.conf.j2
           dest: /etc/myapp/myapp.conf
         notify: Restart myapp
     handlers:
       - name: Restart myapp
         service:
           name: myapp
           state: restarted
   ```

4. **Order the run as two stages: `terraform apply` first, playbook second.** Run them as separate commands in that order rather than wiring one tool to call the other. Terraform calling Ansible through a provisioner couples a successful apply to a successful configuration run, which makes retries confusing — a failed config step can leave the state updated but the host half-configured. Two stages keep each tool's retry story intact: re-run the playbook freely (it is idempotent over the hosts), and re-run apply only when the infrastructure definition changes.

## Verify

- Run a plan after the apply and confirm it reports no further infrastructure changes; drift at this layer means the boundary leaked somewhere.
- Run the playbook a second time and confirm every task reports no change — that second clean run is the check that the configuration side is idempotent.
- Run the playbook in check mode against the generated inventory first when touching shared hosts, and diff the rendered inventory against the previous one after any scaling event to catch machines that were added but never configured.
- One open question I would still test: for teardown, whether to run a drained-remove playbook before destroying the infrastructure, or to let the destroy go first. Either order works for stateless hosts; stateful ones probably want the graceful step first.
