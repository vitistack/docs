# Vitistack

The Vitistack CRD is the primary configuration resource for Viti Stack infrastructure. It defines global settings, provider registrations, and resource quotas for a deployment.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Vitistack
metadata:
  name: string                     # Infrastructure identifier
  namespace: string               # Kubernetes namespace
spec:
  # Infrastructure Configuration
  infrastructure:
    providers:
    - type: string                 # Provider type: proxmox, talos, kubevirt, kea
      name: string                # Provider instance name
      endpoint: string            # Provider API endpoint
      region: string              # Provider region/zone
      credentials:
        secretRef:
          name: string            # Secret containing credentials
          namespace: string       # Secret namespace

  # Global Settings
  settings:
    defaultStorageClass: string   # Default storage class for volumes
    defaultNetworkPolicy: string  # Default network policy
    monitoring:
      enabled: bool              # Enable monitoring integration
      namespace: string          # Monitoring namespace
    logging:
      enabled: bool              # Enable centralized logging
      endpoint: string           # Log aggregation endpoint

  # Resource Quotas
  quotas:
    machines:
      total: int                 # Maximum machines across providers
      perProvider: int           # Maximum machines per provider
    storage:
      total: string              # Total storage quota (e.g., "1Ti")
      perMachine: string         # Maximum storage per machine
    network:
      maxNetworks: int           # Maximum networks per namespace

status:
  phase: string                  # Current phase: Pending, Active, Failed
  conditions: []Condition        # Status conditions
  providers: []ProviderStatus    # Provider status information
  resources:
    machines: int               # Current machine count
    networks: int               # Current network count
    storage: string             # Current storage usage
```

## Usage

The Vitistack resource acts as the top-level configuration object that ties together all infrastructure components within a namespace. Operators read this resource to discover available providers and apply global policies.

## Related Resources

- [MachineProvider](machineprovider.md) — Provider backends referenced by the infrastructure block
- [KubernetesProvider](kubernetesprovider.md) — Kubernetes cluster provisioning backends
