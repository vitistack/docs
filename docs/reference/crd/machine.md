# Machine

The Machine CRD defines a virtual machine or compute resource managed by Viti Stack. It specifies hardware resources, networking, storage, and OS configuration.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: string
  namespace: string
  labels:
    cluster.vitistack.io/cluster-name: string
    vitistack.io/provider: string
spec:
  # Provider Configuration
  providerRef:
    apiVersion: string           # Provider API version
    kind: string                # Provider kind: MachineProvider
    name: string                # Provider instance name
    namespace: string           # Provider namespace

  # Resource Specification
  resources:
    cpu:
      cores: int                # CPU cores (1-128)
      threads: int              # Threads per core (1-2)
      sockets: int              # CPU sockets (1-4)
    memory:
      size: string              # Memory size (e.g., "4Gi", "8Gi")
    gpu:
      type: string              # GPU type: nvidia, amd, intel
      count: int                # GPU count
      model: string             # Specific GPU model

  # Storage Configuration
  storage:
    rootVolume:
      size: string              # Root volume size
      storageClass: string      # Storage class name
      type: string              # Volume type: ssd, hdd, nvme
    dataVolumes:
    - name: string              # Volume identifier
      size: string              # Volume size
      storageClass: string      # Storage class
      mountPath: string         # Mount path in VM

  # Network Configuration
  networking:
    interfaces:
    - name: string              # Interface name
      networkRef:
        name: string            # NetworkConfiguration name
        namespace: string       # Network namespace
      ipAddress: string         # Static IP (optional)
      macAddress: string        # MAC address (optional)

  # Operating System
  operatingSystem:
    type: string                # OS type: linux, windows, freebsd
    distribution: string        # Distribution: ubuntu, centos, windows-server
    version: string             # OS version
    image:
      source: string            # Image source: iso, template, cloud-image
      url: string               # Image URL or template name

  # Boot Configuration
  boot:
    order: []string             # Boot order: disk, network, cdrom
    firmware:
      type: string              # Firmware: bios, uefi
      secureBoot: bool          # Enable secure boot

  # Cloud-Init Configuration
  cloudInit:
    enabled: bool               # Enable cloud-init
    userData: string            # Cloud-init user data
    metaData: string            # Cloud-init metadata
    networkData: string         # Cloud-init network data

status:
  phase: string                 # Machine lifecycle phase
  conditions: []Condition       # Detailed conditions
  providerStatus: {}            # Provider-specific status
  networkStatus:
    interfaces: []InterfaceStatus
  addresses:
    internal: []string          # Internal IP addresses
    external: []string          # External IP addresses
```

## Lifecycle Phases

| Phase | Description |
|-------|-------------|
| Pending | Machine creation requested but not yet started |
| Provisioning | Machine is being created by the provider |
| Running | Machine is running and accessible |
| Stopping | Machine is shutting down |
| Stopped | Machine is stopped |
| Failed | Machine provisioning or operation failed |
| Deleting | Machine is being destroyed |

## Related Resources

- [MachineProvider](machineprovider.md) — Backend that provisions the machine
- [NetworkConfiguration](networkconfiguration.md) — Network interfaces attached to the machine
- [KubernetesCluster](kubernetescluster.md) — Cluster that the machine may belong to
