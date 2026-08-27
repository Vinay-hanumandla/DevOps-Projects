---
last_verified: 2026-08-27
tool_version: n/a
---

# Comparing kubectl imperative vs declarative approaches for Kubernetes deployments

> Two ways to manage Kubernetes resources: telling kubectl what to do now vs telling it what you want.

## Why this matters

When I started with Kubernetes, I used `kubectl` commands directly — create this pod, expose that service, scale this deployment. It felt natural because it was like using any other CLI tool. But as my deployments grew, I realized this approach has real limits. The declarative approach — writing YAML manifests and applying them — is the one the Kubernetes docs recommend, but understanding *why* took some trial and error.

## Imperative: telling kubectl what to do

Imperative commands execute an action immediately:

```bash
kubectl create deployment nginx --image=nginx:1.25 --replicas=3
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl scale deployment nginx --replicas=5
```

This works well for:
- Quick experimentation and prototyping
- Debugging — spinning up a temporary pod to test something
- One-off tasks that don't need to be repeated

The problem is that there's no record of what you did. If someone asks "how is nginx deployed?", you can't answer from the cluster state alone — you'd have to guess what commands were run. And if the cluster gets recreated, you have to remember and re-run every command.

## Declarative: telling kubectl what you want

Declarative manifests describe the desired state:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

Applied with:

```bash
kubectl apply -f nginx-deployment.yaml
```

The key difference: `kubectl apply` compares what's in the file to what's in the cluster and makes only the changes needed to reach the desired state. If you change `replicas: 3` to `replicas: 5` in the file and re-apply, Kubernetes scales the deployment — you don't need a separate `scale` command.

## Where each approach breaks down

Imperative gets messy when:
- You have more than a handful of resources to manage
- Multiple people need to deploy the same thing consistently
- You need to track changes over time (git history becomes your audit trail)
- You want to use tools like Helm or Kustomize that work with manifests

Declarative gets tricky when:
- You're learning and don't know all the manifest fields yet
- You need to do something quick for debugging
- The resource has many optional fields and you just want to set one thing

## The workflow that clicked for me

I settled on this pattern: use imperative commands to explore and learn what fields are available (`kubectl create deployment nginx --image=nginx:1.25 --dry-run=client -o yaml`), then save that output as a starting manifest. From there, I edit the YAML directly and use `kubectl apply` to manage it. The `--dry-run=client -o yaml` flag is the bridge between imperative exploration and declarative management.

For day-to-day work, I use `kubectl diff -f manifest.yaml` before applying to preview what will change. It's like a dry run that shows exactly what Kubernetes will do.

## How this connects to what's next

This comparison leads naturally into Helm charts (templated declarative manifests), Kustomize (layered declarative configs), and GitOps workflows where the declarative manifests live in git and a controller reconciles cluster state automatically.
