# KubernetesCluster

The KubernetesCluster CRD defines a Kubernetes cluster managed by Viti Stack. It references a provider and specifies the desired cluster configuration.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: string
  namespace: string
spec:
  # Provider Reference
  providerRef:
    name: string                # KubernetesProvider name
    namespace: string           # Provider namespace

  # Cluster Configuration
  kubernetesVersion: string     # Desired Kubernetes version
  controlPlane:
    replicas: int               # Control plane node count
    machineClass: string        # MachineClass reference

  # Worker Node Groups
  workers:
  - name: string                # Worker group name
    replicas: int               # Node count
    machineClass: string        # MachineClass reference

  # Network Configuration
  networking:
    podCIDR: string             # Pod network CIDR
    serviceCIDR: string         # Service network CIDR

status:
  phase: string                 # Cluster phase: Provisioning, Running, Failed
  kubernetesVersion: string     # Actual running version
  conditions: []Condition       # Status conditions
  controlPlaneReady: bool       # Control plane readiness
  nodes: int                    # Total node count
```

## Related Resources

- [KubernetesProvider](kubernetesprovider.md) — Provider that provisions this cluster
- [Machine](machine.md) — Machines forming the cluster nodes
- [EtcdBackup](etcdbackup.md) — Backup configuration for this cluster
