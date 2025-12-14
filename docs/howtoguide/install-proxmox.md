# Install Proxmox

You need one or more Proxmox instances.

To install proxmox, follow this installation guide: 
- https://proxmox.com/en/products/proxmox-virtual-environment/get-started
- https://pve.proxmox.com/pve-docs/chapter-pve-installation.html

## Install the Proxmox operator

Setup the kubernetes secret for Proxmox:

Existing secret containing Proxmox credentials
The secret should contain: PROXMOX_ENDPOINT, PROXMOX_USERNAME, PROXMOX_PASSWORD
or PROXMOX_TOKEN_ID, PROXMOX_TOKEN_SECRET

### Create the secret with:
```bash
kubectl create secret generic proxmox-credentials-secret \
    --from-literal=PROXMOX_ENDPOINT=https://proxmox.example.com:8006/api2/json \
    --from-literal=PROXMOX_USERNAME=root@pam \
    --from-literal=PROXMOX_PASSWORD=yourpassword
```

### Or for token auth:
```bash
kubectl create secret generic proxmox-credentials-secret \
    --from-literal=PROXMOX_ENDPOINT=https://proxmox.example.com:8006/api2/json \
    --from-literal=PROXMOX_TOKEN_ID=root@pam!mytoken \
    --from-literal=PROXMOX_TOKEN_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### or with yaml
Filename: proxmox-credentials-secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: proxmox-credentials-secret
type: Opaque
stringData:
  PROXMOX_ENDPOINT: "https://proxmox.example.com:8006/api2/json"
  # Use username/password auth:
  PROXMOX_USERNAME: "root@pam"
  PROXMOX_PASSWORD: "yourpassword"
  # OR use token auth (comment out username/password above):
  # PROXMOX_TOKEN_ID: "root@pam!mytoken"
  # PROXMOX_TOKEN_SECRET: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Apply with

```bash
kubectl apply -f proxmox-credentials-secret.yaml
```

### Install the Vitistack Proxmox Operator
```bash
helm registry login ghcr.io
helm install vitistack-proxmox-operator oci://ghcr.io/vitistack/helm/proxmox-operator
```