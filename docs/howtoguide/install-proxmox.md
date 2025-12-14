# Install Proxmox

You need one or more Proxmox instances.

To install proxmox, follow this installation guide: 
- https://proxmox.com/en/products/proxmox-virtual-environment/get-started
- https://pve.proxmox.com/pve-docs/chapter-pve-installation.html

## Install the Proxmox operator

```bash
helm registry login ghcr.io
helm install viti-proxmox-operator oci://ghcr.io/vitistack/helm/proxmox-operator
```