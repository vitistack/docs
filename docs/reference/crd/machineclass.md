# MachineClass

The MachineClass CRD defines reusable machine size templates at the cluster scope. Machine resources reference these classes to avoid repeating resource specifications.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: string                  # Cluster-scoped (no namespace)
spec:
  # Resource Specification
  resources:
    cpu:
      cores: int                # CPU cores
      threads: int              # Threads per core
      sockets: int              # CPU sockets
    memory:
      size: string              # Memory size (e.g., "4Gi")
    storage:
      rootVolume:
        size: string            # Root volume size
        storageClass: string    # Storage class

  # Description
  description: string           # Human-readable description
```

## Example

```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: medium
spec:
  description: "Medium VM: 4 cores, 8Gi RAM, 40Gi disk"
  resources:
    cpu:
      cores: 4
    memory:
      size: "8Gi"
    storage:
      rootVolume:
        size: "40Gi"
```

## Related Resources

- [Machine](machine.md) — Machines that reference a MachineClass
- [KubernetesCluster](kubernetescluster.md) — Clusters that use MachineClass for node sizing
