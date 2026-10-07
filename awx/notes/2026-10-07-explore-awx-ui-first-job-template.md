---
last_verified: 2026-10-07
tool_version: "24.6.1"
sources:
  - https://github.com/ansible/awx/releases/tag/24.6.1
  - https://docs.ansible.com/projects/awx-operator/en/latest/installation/basic-install.html
---
# Explore AWX UI and run first job template

> Third day with AWX (24.6.1, Operator 2.19.1 on Minikube). Launched a real job template and watched it run.

## What I did

Applied the minimal AWX CR from yesterday (`awx/configs/2026-10-07-minimal-awx-custom-resource-minikube.yaml`) to Minikube. Waited for pods to come up — `kubectl get pods -n awx -w` showed web, task, redis, postgres all running after ~3 minutes. Got the admin password from the secret:

```bash
kubectl get secret awx-demo-admin-password -n awx -o jsonpath="{.data.password}" | base64 --decode
```

Logged in at the NodePort URL (`minikube service awx-demo-service -n awx --url` gave me `http://192.168.49.2:30080` — HTTP works for local testing even though AWX prefers HTTPS).

## First job template

Created a dummy inventory with `localhost` (the AWX web pod itself), added a machine credential with a throwaway SSH key, pointed a project at a tiny Git repo with one playbook (`helloworld.yml` that just runs `debug: msg="hello from AWX"`), and wired them into a job template named "hello-world".

Clicked **Launch** — job queued, then ran, turned green. Output log showed the debug message. That's the full loop: inventory → credential → project → template → job.

## Got stuck on

- NodePort on Minikube serves HTTP, not HTTPS. Browser complains but it works. For real clusters the docs say use `service_type: clusterip` + an Ingress/Route with TLS.
- The `admin_password_secret` and `secret_key_secret` in the CR must exist before apply or the operator creates empty ones. I pre-created them with `kubectl create secret generic` so I control the values.
- Forgot `projects_persistence: true` and the PVC on first try — project sync failed because the web pod had nowhere to clone the repo. Added the PVC and it worked.

## What I'd try next

Schedule the template on a timer (Sunday 2am) and verify the scheduled job appears in the Jobs list. Then peek at the API for that job run (`/api/v2/jobs/<id>/`) and compare with the UI view.