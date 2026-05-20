# KubevirtConfig

The KubevirtConfig CRD configures the KubeVirt operator integration, defining feature gates, resource defaults, and network bindings.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubevirtConfig
metadata:
  name: string
  namespace: string
spec:
  # KubeVirt Configuration
  kubevirt:
    version: string             # KubeVirt version
    namespace: string           # KubeVirt namespace

  # Feature Gates
  featureGates:
  - name: string                # Feature gate name
    enabled: bool               # Feature enabled status

  # Resource Configuration
  resources:
    vmiCPUModel: string         # Default CPU model
    machineType: string         # Default machine type
    emulatedMachines: []string  # Supported emulated machines

  # Storage Configuration
  storage:
    defaultStorageClass: string # Default storage class
    volumeModes: []string       # Supported volume modes
    accessModes: []string       # Supported access modes

  # Network Configuration
  network:
    defaultNetworkInterface: string # Default network interface
    binding: {}                 # Network binding configuration

status:
  phase: string                 # Configuration phase
  appliedVersion: string        # Applied KubeVirt version
  conditions: []Condition       # Status conditions
```

## Related Resources

- [Machine](machine.md) — VMs managed through KubeVirt
- [MachineProvider](machineprovider.md) — Provider of type kubevirt
