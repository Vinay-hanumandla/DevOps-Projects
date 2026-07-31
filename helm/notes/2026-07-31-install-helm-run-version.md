---
last_verified: 2026-07-31
tool_version: n/a
---

# Install Helm and run `helm version`

I just set up Helm on my machine for the first time. The install process was straightforward — I grabbed the official install script and let it handle the download.

I ran the install command and then checked the version right away with `helm version`. Seeing the client and server versions printed confirmed everything was connected. I noticed the server version showed "not installed" at first because I hadn't deployed Helm to a cluster yet — that's expected since Helm's client can run standalone without Tiller or the server component on newer Helm 3.

Here's what I did step by step:
1. Downloaded the install script from the official Helm repo.
2. Ran the script to install the Helm binary locally.
3. Ran `helm version` to verify the installation.
4. Added the stable chart repository so I'd have charts available to try.

The `helm version` output showed the client version clearly, and I was able to add repos and list available charts without any issues. Next I want to try `helm install` with a simple chart to see how a real deployment works.