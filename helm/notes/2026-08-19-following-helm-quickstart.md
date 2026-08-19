---
last_verified: 2026-08-19
tool_version: n/a
---

# Following the Helm quickstart

I walked through the official Helm quickstart today and got a chart deployed for the first time. Here's what worked and where I got tangled up.

## Steps that worked

The quickstart starts with a Docker Desktop cluster, so I made sure one was running and reachable with kubectl before anything else.

Then the core of it:

```bash
helm create mychart
helm install my-release ./mychart
kubectl get all
```

`helm create mychart` scaffolds a whole chart directory with `Chart.yaml`, `values.yaml`, `templates/`, and a handful of demo manifests. Installing it with `helm install my-release ./mychart/` deployed the example nginx chart, and I could see the pod, service, and deployment come up.

`helm list` and `helm uninstall my-release` were the bookends that made it feel like a lifecycle rather than a one-shot command.

## Got stuck on

The biggest confusion was that the quickstart's chart occupies its own namespace. After the install, `kubectl get all` with no flags showed nothing, and I assumed the release had failed. It hadn't — the chart defaulted to the `default` service account but nothing I expected was in my current namespace because the quickstart chart actually ends up visible once you pass the right flags. `helm status my-release` was the thing that told me the release was actually healthy. I should lead with that instead of guessing from kubectl.

Second snag: I changed `service.type` in `values.yaml` to `ClusterIP` because I didn't want to deal with a NodePort on my laptop, and then hit the classic issue of not re-applying. Editing the file on disk does nothing until you run `helm upgrade`:

```bash
helm upgrade my-release ./mychart
```

I kept checking `kubectl get svc` expecting the change to be live, when the whole point of Helm is that the release state, not the file, is what matters.

## What I'd try next

I want to render templates without installing, so I understand how values flow into each manifest. The parts I'm least sure about are `Chart.yaml` metadata and how `templates/NOTES.txt` gets compiled during an install. After that, setting the image via `--set image.tag=...` on the command line and watching how it merges with the values file feels like the natural next step.