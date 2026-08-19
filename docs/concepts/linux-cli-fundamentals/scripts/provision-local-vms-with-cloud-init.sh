#!/usr/bin/env bash
# last_verified: 2026-08-19 · Linux & CLI Fundamentals n/a
#
# provision-local-vms-with-cloud-init.sh — provision local VMs with cloud-init
# and libvirt.
#
# Pattern: Linux & CLI + IaC. The Linux CLI supplies the orchestration (parameter
# handling, seed-image generation, libvirt calls); the IaC mindset supplies the
# declarative part — the VM's first-boot configuration is described in a
# cloud-init user-data file, not by hand-running setup commands after boot.

set -euo pipefail

# --- Parameters ---
VM_NAME="${1:-}"
BASE_IMAGE="${2:-}"
MEMORY_MB="${3:-2048}"
VCPUS="${4:-2}"
SSH_KEY="${5:-${HOME}/.ssh/id_ed25519.pub}"

usage() {
    echo "usage: $0 <vm-name> <base-image.qcow2> [memory-mb] [vcpus] [ssh-key-path]" >&2
    exit 1
}

if [[ -z "$VM_NAME" || -z "$BASE_IMAGE" ]]; then
    usage
fi

if [[ ! -f "$BASE_IMAGE" ]]; then
    echo "error: base image not found: $BASE_IMAGE" >&2
    exit 1
fi

if [[ ! -f "$SSH_KEY" ]]; then
    echo "error: SSH public key not found: $SSH_KEY" >&2
    exit 1
fi

# --- Required tools ---
for tool in virsh virt-install cloud-localds qemu-img; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "error: required tool '$tool' not found (install libvirt-client, virt-install," \
             "cloud-image-utils, and qemu-utils as needed)" >&2
        exit 1
    fi
done

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

# --- cloud-init seed: declarative first-boot config ---
USER_DATA="${WORKDIR}/user-data"
SEED_ISO="${WORKDIR}/seed.iso"
DISK_IMG="${WORKDIR}/${VM_NAME}.qcow2"

PUBKEY="$(cat "$SSH_KEY")"
cat > "$USER_DATA" <<EOF
#cloud-config
users:
  - name: dev
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
    ssh_authorized_keys:
      - ${PUBKEY}
package_update: true
runcmd:
  - echo "provisioned via cloud-init" > /etc/provisioned
EOF

cloud-localds "$SEED_ISO" "$USER_DATA"

# --- Linked disk over the base image so cloud-init is the only host-specific bit ---
qemu-img create -f qcow2 -b "$BASE_IMAGE" -F qcow2 "$DISK_IMG" >/dev/null

# --- Provision with virt-install ---
if virsh list --all --name | grep -qx "$VM_NAME"; then
    echo "error: a domain named '$VM_NAME' already exists" >&2
    exit 1
fi

virt-install \
    --name "$VM_NAME" \
    --memory "$MEMORY_MB" \
    --vcpus "$VCPUS" \
    --import \
    --disk "path=${DISK_IMG},format=qcow2" \
    --disk "path=${SEED_ISO},device=cdrom,readonly=on" \
    --network network=default \
    --graphics none \
    --os-variant generic \
    --noautoconsole

# --- Wait for the guest to appear on the network ---
for _ in $(seq 1 15); do
    IP="$(virsh domifaddr "$VM_NAME" 2>/dev/null | awk 'NR>2 && $4 != "" {print $4}' | cut -d/ -f1 || true)"
    if [[ -n "$IP" ]]; then
        echo "provisioned: $VM_NAME -> $IP (ssh dev@$IP)"
        exit 0
    fi
    sleep 2
done

echo "warning: $VM_NAME started but no IP observed yet; retry with:" >&2
echo "  virsh domifaddr $VM_NAME" >&2