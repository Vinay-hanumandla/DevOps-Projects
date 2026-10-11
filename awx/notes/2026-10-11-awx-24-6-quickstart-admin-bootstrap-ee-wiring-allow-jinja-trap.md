---
last_verified: 2026-10-11
tool_version: n/a
---

# AWX 24.6 quickstart — admin bootstrap, execution environment wiring, and the ALLOW_JINJA_IN_EXTRA_VARS trap

## What I tried

I got AWX 24.6 running on Minikube via the AWX Operator and walked the whole first-day path: create the instance, log in for the first time, wire an execution environment, and launch a job. Here is what worked, where I got stuck, and the trap I hit with extra vars.

## What worked

The Operator path was smoother than the docker-compose path I had used before. I applied a minimal AWX custom resource — `service_type: nodeport`, `ingress_type: none`, one web/task replica, and a PVC-backed projects directory — and the Operator stood the pods up without me touching a compose file. Once the web pod was Running, I opened the NodePort address and created the admin user. That first user becomes the administrator, since AWX does not seed an account.

Wiring the execution environment was the next easy step. AWX runs playbooks inside execution environments (containers), and the default one ships with AWX. Under **Execution Environments** I pointed a job template at the default image, picked a project, an inventory, and a credential, and launched. The job ran and completed, which confirmed the whole chain works.

## Got stuck on

**1. There is no default admin account.** I opened the UI expecting a `admin`/`admin` login and found a create-user screen instead. AWX genuinely does not seed one — the first user you add is the administrator. If the UI is not reachable yet, you can create the admin from inside the web pod with `awx-manage create_admin_user`.

**2. The admin password is the one you set in the UI.** I assumed there was a generated password somewhere and wasted a few minutes looking for it. There is not. The password you type when you create the user is the password. If you forget it, `awx-manage create_admin_user` from the pod resets it.

**3. The ALLOW_JINJA_IN_EXTRA_VARS trap.** When I passed an extra var through the UI containing `{{ }}`, AWX interpolated it as a Jinja2 template and mangled the value. The setting `ALLOW_JINJA_IN_EXTRA_VARS` controls this per organization:

- When **enabled** (the default in older versions), extra vars are templated. A value containing literal `{{ }}` is processed and may produce unexpected output or an error.
- When **disabled**, extra vars are passed through verbatim. This is safer for values that are not meant to be templates.

The trap is silent: nothing warns you when a value is templated. If you pass a JSON string as an extra var and see it come back broken, check this setting before debugging your playbook.

## What I'd try next

- Set `ALLOW_JINJA_IN_EXTRA_VARS` to false for the default organization and re-run the job with a JSON extra var to confirm it arrives unchanged.
- Add a second execution environment with a custom image and a playbook that uses a collection not in the default EE, to see how the EE swap feels in a template.
- Try the API path with `curl` and a bearer token, since the UI hides the templating behaviour that the API exposes directly.