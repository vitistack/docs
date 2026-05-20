# MachineProvider

The MachineProvider CRD configures machine provisioning backends. It defines connection details, credentials, and capacity for a specific infrastructure provider.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineProvider
metadata:
  name: string
  namespace: string
spec:
  # Provider Type and Configuration
  type: string                  # Provider type: proxmox, kubevirt, vmware

  # Connection Configuration
  endpoint:
    url: string                 # Provider API URL
    insecureSkipTLSVerify: bool # Skip TLS verification
    timeout: string             # Connection timeout

  # Authentication
  credentials:
    type: string                # Auth type: password, token, certificate
    secretRef:
      name: string              # Secret name
      namespace: string         # Secret namespace

  # Provider-Specific Configuration
  config:
    # Proxmox specific
    proxmox:
      node: string              # Default Proxmox node
      storage: string           # Default storage pool
      networkBridge: string     # Default network bridge

    # KubeVirt specific
    kubevirt:
      storageClass: string      # Default storage class
      networkPolicy: string     # Default network policy

  # Resource Templates
  templates:
  - name: string                # Template name
    resources:
      cpu: int                  # CPU cores
      memory: string            # Memory size
      storage: string           # Storage size

  # Capacity Management
  capacity:
    maxMachines: int            # Maximum concurrent machines
    reservedResources:
      cpu: int                  # Reserved CPU cores
      memory: string            # Reserved memory
      storage: string           # Reserved storage

status:
  ready: bool                   # Provider readiness
  capacity:
    total: ResourceQuota        # Total available resources
    available: ResourceQuota    # Currently available resources
    used: ResourceQuota         # Currently used resources
  machines: int                 # Active machine count
```

## Supported Provider Types

| Type | Description | Operator |
|------|-------------|----------|
| proxmox | Proxmox VE hypervisor | proxmox-operator |
| kubevirt | KubeVirt virtual machines | kubevirt-operator |

## Related Resources

- [Machine](machine.md) — Machines provisioned by this provider
- [ProxmoxConfig](proxmoxconfig.md) — Proxmox-specific operator settings
- [KubevirtConfig](kubevirtconfig.md) — KubeVirt-specific operator settings
