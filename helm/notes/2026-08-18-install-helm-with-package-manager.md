---
last_verified: 2026-08-18
tool_version: n/a
---

# Install Helm with package manager and verify chart repository access

I set up Helm today on a fresh box and ran into a couple of small things that weren't obvious from the quickstart. Here are my scratch notes.

## What I did

First, I installed Helm by fetching the signing key with `curl`, piping it through `gpg --dearmor`, and writing it to `/usr/share/keyrings/helm.gpg`, then running `sudo apt install helm`. That pulled in the package and put `helm` on my PATH. I verified it with `helm version`, which printed both the client and an empty server side since I haven't connected a cluster yet.

Next, I added the official Bitnami repo with `helm repo add bitnami <repo-url>` and ran `helm repo update`. Then I searched for a chart to make sure the index was reachable: `helm search repo nginx`. The command returned a list of nginx charts with version numbers, which told me the repo URL and my local cache were both working.

## What tripped me up

The `helm version` output confused me at first — the "Server" section is blank until you point Helm at a Kubernetes cluster. I thought the install had failed because there was no server version. It's just that Helm can manage charts locally without a cluster; the server side only appears when you run `helm install` against one.

Also, `helm repo add` requires the exact repo URL. I tried adding just `bitnami` without the URL and got an error about a missing positional argument. The quickstart assumes you know the URL format, which isn't obvious if you've never seen a chart repository before.
