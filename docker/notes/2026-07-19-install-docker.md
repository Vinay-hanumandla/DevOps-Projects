---
last_verified: 2026-07-19
tool_version: n/a
sources:
  - https://kodekloud.com/blog/docker-tutorial-for-beginners
  - https://dev.to/prodevopsguytech/100-common-docker-errors-solutions-4le0
  - https://forums.docker.com/t/installation-issues-on-ubuntu/150736
---

# Installing Docker and verifying the daemon — my first try

I'm on Ubuntu, so I followed Docker's official apt repo instructions instead of using the distro package. The quickest path (from the docs):

```bash
# Add Docker's official GPG key and repository
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker packages
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

The research warned me not to use `apt install docker.io` — the distro package is months behind and ships without Compose V2. The official repo gives you the latest stable.

### Verifying the daemon

After installing, I checked the daemon status:

```bash
sudo systemctl status docker
```

If it wasn't running: `sudo systemctl start docker`. To start on boot: `sudo systemctl enable docker`.

### Running without sudo

By default you need `sudo` for every `docker` command. I added my user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

Then logged out and back in (or `newgrp docker`). After that, `docker ps` worked without sudo.

### What tripped me up

- The first `systemctl status docker` showed "inactive (dead)" — I forgot to start it. Running `sudo systemctl start docker` fixed it.
- After `usermod`, I tried `docker ps` in the same terminal and got the socket permission error. Had to log out and back in for the group change to take effect.
- The research mentioned a `containerd.io` 404 bug (version 2.2.1-1 was missing from the server in mid-2026). I didn't hit it, but if I did, the fix is to pin to `containerd.io=2.2.0-2`.

Final verification: `docker run hello-world` — the daemon downloaded the image and printed the success message. Docker is working.
