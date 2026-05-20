# ProxmoxConfig

The ProxmoxConfig CRD configures the Proxmox operator integration, defining cluster connection, authentication, defaults, and templates.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: ProxmoxConfig
metadata:
  name: string
  namespace: string
spec:
  # Proxmox Cluster Configuration
  cluster:
    nodes: []string             # Proxmox node list
    endpoint: string            # Cluster API endpoint

  # Authentication Configuration
  authentication:
    type: string                # Auth type: pam, pve, ad, ldap
    realm: string               # Authentication realm

  # Default Configuration
  defaults:
    storage: string             # Default storage pool
    network: string             # Default network bridge
    osType: string              # Default OS type

  # Resource Limits
  limits:
    maxVMsPerNode: int          # Maximum VMs per node
    maxCPUCores: int            # Maximum CPU cores per VM
    maxMemory: string           # Maximum memory per VM

  # Template Configuration
  templates:
  - id: string                  # Template ID
    name: string                # Template name
    osType: string              # Operating system type
    resources: {}               # Default resources

status:
  ready: bool                   # Configuration readiness
  clusterVersion: string        # Proxmox cluster version
  availableNodes: []string      # Available Proxmox nodes
```

## Related Resources

- [Machine](machine.md) — VMs managed through Proxmox
- [MachineProvider](machineprovider.md) — Provider of type proxmox
