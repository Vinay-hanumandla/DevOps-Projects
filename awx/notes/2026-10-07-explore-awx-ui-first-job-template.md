---
last_verified: 2026-10-07
tool_version: "24.6.1"
sources:
  - https://github.com/ansible/awx/releases/tag/24.6.1
  - https://docs.ansible.com/projects/awx-operator/en/latest/installation/basic-install.html
---
# Explore AWX UI and run first job template

> Third day with AWX (24.6.1, Operator 2.19.1 on Minikube). Launched a real job template.

## What I did

Applied the minimal AWX CR to Minikube. Pods (web, task, redis, postgres) ready in ~3 min. Got admin password:

```bash
kubectl get secret awx-demo-admin-password -n awx -o jsonpath="{.data.password}" | base64 --decode
```

Logged in via NodePort (`minikube service awx-demo-service -n awx --url` → HTTP, works for local testing).

## First job template

Created inventory with `localhost`, machine credential with throwaway SSH key, project pointing at a tiny repo with `helloworld.yml` (`debug: msg="hello"`), wired into template "hello-world". Clicked **Launch** — job queued, ran, turned green. Full loop: inventory → credential → project → template → job.

## Got stuck on

- NodePort serves HTTP, not HTTPS. Browser complains but works. Real clusters need `service_type: clusterip` + Ingress/Route with TLS.
- `admin_password_secret` and `secret_key_secret` in CR must pre-exist or operator creates empty ones. Pre-created with `kubectl create secret generic`.
- Forgot `projects_persistence: true` + PVC — project sync failed. Added PVC, worked.

## What I'd try next

Schedule template on a timer, verify scheduled job appears. Peek at API (`/api/v2/jobs/<id>/`) and compare with UI.