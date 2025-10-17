# KubeVirt Operator

!!! warning "Work in progress!"

The KubeVirt Operator manages virtual machines on Kubernetes clusters by bridging Viti Stack infrastructure resources with KubeVirt virtualization capabilities. It reconciles `Machine` Custom Resource Definitions to create and manage KubeVirt `VirtualMachine` and `VirtualMachineInstance` resources, providing declarative VM lifecycle management.

## Architecture

### Controller Structure

The operator implements the Kubernetes controller pattern with the following components:

- **Machine Controller**: Reconciles `vitistack.io/v1alpha1/Machine` resources
- **KubeVirt Integration**: Translates Machine specs to KubeVirt VirtualMachine resources
- **Network Management**: Configures VM networking through NetworkConfiguration CRDs
- **Storage Provisioning**: Handles persistent volume claims and storage class integration
- **Lifecycle Management**: Manages VM creation, updates, and cleanup operations

### Repository Structure

```
├── cmd/                           # Main entry point
├── controllers/v1alpha1/          # Machine controller implementation
│   └── machine_controller.go     # Primary reconciliation logic
├── config/
│   ├── crd/                      # Custom Resource Definitions
│   ├── rbac/                     # Role-based access control
│   ├── manager/                  # Operator deployment
│   ├── prometheus/               # Monitoring configuration
│   ├── network-policy/           # Network security policies
│   └── samples/                  # Example resources
├── charts/kubevirt-operator/     # Helm deployment charts
├── examples/                     # Machine resource examples
├── internal/                     # Internal implementation packages
├── pkg/                          # Public packages and utilities
├── test/                         # Test suites
└── docs/                         # Setup and configuration documentation
```

## API Reference

### Machine Resource

The primary resource managed by the KubeVirt Operator:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: string                     # Machine identifier
  namespace: string               # Kubernetes namespace
  labels:
    cluster.vitistack.io/cluster-name: string # Associated cluster
    vitistack.io/machine-template: string     # Template reference
spec:
  # Template Configuration
  template: string                 # Machine template name (small, medium, large)
  
  # Resource Overrides
  resources:
    cpu:
      cores: int                  # CPU cores override
      threads: int                # CPU threads override
      sockets: int                # CPU sockets override
    memory:
      size: string                # Memory size (e.g., "2Gi", "4Gi")
    
  # Storage Configuration
  disks:
  - name: string                  # Disk identifier
    size: string                  # Disk size (e.g., "20Gi", "100Gi")
    storageClass: string          # Kubernetes StorageClass
    accessMode: string            # Volume access mode: ReadWriteOnce, ReadWriteMany
    volumeMode: string            # Volume mode: Filesystem, Block
    
  # Network Configuration
  networks:
  - name: string                  # Network interface name
    networkName: string           # NetworkConfiguration reference
    model: string                 # NIC model: virtio, e1000, rtl8139
    macAddress: string            # MAC address (optional)
    
  # Boot Configuration
  bootOrder: []string             # Boot device order: disk, network, cdrom
  
  # Cloud-Init Configuration
  cloudInit:
    userData: string              # Cloud-init user data
    networkData: string           # Cloud-init network configuration
    secretRef:                    # Reference to secret containing cloud-init
      name: string               # Secret name
      key: string                # Secret key
      
  # Virtual Machine Settings
  domain:
    machine:
      type: string                # Machine type: pc-q35, pc-i440fx
    features:
      acpi: bool                  # Enable ACPI
      apic: bool                  # Enable APIC
      hyperv: bool                # Enable Hyper-V optimizations
    firmware:
      bootloader:
        efi: bool                 # Use EFI bootloader
        secureBoot: bool          # Enable secure boot
        
status:
  phase: string                   # Current phase: Pending, Creating, Running, Stopped, Failed
  conditions: []Condition         # Status conditions
  vmName: string                  # Created VirtualMachine name
  vmiName: string                 # Active VirtualMachineInstance name
  ipAddresses: []string           # Assigned IP addresses
  nodeName: string                # Kubernetes node hosting the VM
  lastUpdated: string             # Last reconciliation timestamp
  resourceVersion: string         # Current resource version
```

### Machine Templates

Predefined resource configurations for common VM sizes:

#### Small Template

```yaml
template: small
# Translates to:
resources:
  cpu:
    cores: 1
    threads: 1
    sockets: 1
  memory:
    size: "2Gi"
disks:
- name: "root"
  size: "20Gi"
  storageClass: "default"
```

#### Medium Template

```yaml
template: medium
# Translates to:
resources:
  cpu:
    cores: 2
    threads: 1
    sockets: 1
  memory:
    size: "4Gi"
disks:
- name: "root"
  size: "40Gi"
  storageClass: "default"
```

#### Large Template

```yaml
template: large
# Translates to:
resources:
  cpu:
    cores: 4
    threads: 1
    sockets: 1
  memory:
    size: "8Gi"
disks:
- name: "root"
  size: "80Gi"
  storageClass: "default"
```

### Generated KubeVirt Resources

The operator creates corresponding KubeVirt resources:

#### VirtualMachine Resource

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: string                    # Generated from Machine name
  namespace: string               # Inherited from Machine
  labels:
    vitistack.io/managed-by: kubevirt-operator
    vitistack.io/machine: string  # Reference to source Machine
  ownerReferences:
  - apiVersion: vitistack.io/v1alpha1
    kind: Machine
    name: string                  # Parent Machine name
    uid: string                   # Parent Machine UID
spec:
  running: bool                   # VM power state
  template:
    metadata:
      labels:
        vitistack.io/machine: string
    spec:
      domain:
        cpu:
          cores: int              # From Machine resources.cpu.cores
          threads: int            # From Machine resources.cpu.threads
          sockets: int            # From Machine resources.cpu.sockets
        memory:
          guest: string           # From Machine resources.memory.size
        devices:
          disks: []               # Generated from Machine disks
          interfaces: []          # Generated from Machine networks
          networkInterfaceMultiqueue: bool
        machine:
          type: string            # From Machine domain.machine.type
        features: {}              # From Machine domain.features
        firmware: {}              # From Machine domain.firmware
      networks: []                # Network configurations
      volumes: []                 # Volume configurations
```

## Configuration Reference

### Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `KUBECONFIG` | string | - | Kubernetes configuration file path |
| `RECONCILE_INTERVAL` | duration | 30s | Machine reconciliation interval |
| `MAX_CONCURRENT_RECONCILES` | int | 5 | Maximum concurrent reconciliations |
| `METRICS_BIND_ADDRESS` | string | `:8080` | Metrics server bind address |
| `HEALTH_PROBE_BIND_ADDRESS` | string | `:8081` | Health probe bind address |
| `LEADER_ELECTION` | bool | true | Enable leader election |
| `NAMESPACE` | string | - | Operator namespace |

### Machine Template Configuration

#### Template Definitions

Templates are hardcoded configurations that can be referenced by name:

| Template | CPU | Memory | Root Disk | Use Case |
|----------|-----|--------|-----------|----------|
| `small` | 1 core | 2Gi | 20Gi | Development, testing |
| `medium` | 2 cores | 4Gi | 40Gi | Light workloads |
| `large` | 4 cores | 8Gi | 80Gi | Production workloads |

#### Resource Override Behavior

When both template and resource overrides are specified:
```yaml
spec:
  template: medium              # Base: 2 cores, 4Gi memory
  resources:
    cpu:
      cores: 4                 # Override: Results in 4 cores
    memory:
      size: "8Gi"              # Override: Results in 8Gi memory
```

Final configuration: 4 cores, 8Gi memory, 40Gi disk (from template)

### Storage Configuration

#### Storage Class Integration

| Parameter | Type | Description |
|-----------|------|-------------|
| `storageClass` | string | Kubernetes StorageClass name |
| `size` | string | Volume size (e.g., "20Gi", "100Gi") |
| `accessMode` | string | Volume access mode |
| `volumeMode` | string | Volume mode: Filesystem or Block |

#### Supported Access Modes

| Mode | Description | Multi-Node | Use Case |
|------|-------------|------------|----------|
| `ReadWriteOnce` | Single node read-write | No | Standard VM disks |
| `ReadWriteMany` | Multi-node read-write | Yes | Shared storage |
| `ReadOnlyMany` | Multi-node read-only | Yes | Read-only data |

### Network Configuration

#### NetworkConfiguration CRD Integration

The operator integrates with Viti Stack NetworkConfiguration resources:

```yaml
networks:
- name: "eth0"
  networkName: "prod-network"    # References NetworkConfiguration
  model: "virtio"
  macAddress: "52:54:00:12:34:56"
```

#### Network Interface Models

| Model | Description | Performance | Compatibility |
|-------|-------------|-------------|---------------|
| `virtio` | Paravirtualized NIC | High | Modern OS |
| `e1000` | Intel E1000 emulation | Medium | Legacy OS |
| `rtl8139` | Realtek RTL8139 | Low | Very old OS |

## Operational Reference

### Reconciliation Workflow

The Machine controller implements the following reconciliation logic:

1. **Resource Validation**: Validates Machine specification and template references
2. **Template Resolution**: Applies machine template and processes overrides
3. **Network Preparation**: Ensures NetworkConfiguration resources exist
4. **Storage Provisioning**: Creates PersistentVolumeClaims for disks
5. **VirtualMachine Creation**: Generates KubeVirt VirtualMachine resource
6. **Status Monitoring**: Watches VirtualMachineInstance status
7. **Network Configuration**: Applies network settings and IP assignments
8. **Cleanup Management**: Handles resource deletion and finalizers

### Machine Lifecycle States

| Phase | Description | Next States |
|-------|-------------|-------------|
| `Pending` | Machine created, awaiting reconciliation | Creating, Failed |
| `Creating` | Resources being provisioned | Running, Failed |
| `Running` | VM successfully running | Stopped, Failed |
| `Stopped` | VM powered off | Running, Failed |
| `Failed` | Unrecoverable error | - |

### KubeVirt Resource Mapping

#### CPU Configuration Mapping

| Machine Spec | KubeVirt VirtualMachine | Description |
|--------------|------------------------|-------------|
| `resources.cpu.cores: 2` | `domain.cpu.cores: 2` | Total CPU cores |
| `resources.cpu.threads: 1` | `domain.cpu.threads: 1` | Threads per core |
| `resources.cpu.sockets: 1` | `domain.cpu.sockets: 1` | CPU sockets |

#### Memory Configuration Mapping

| Machine Spec | KubeVirt VirtualMachine | Description |
|--------------|------------------------|-------------|
| `resources.memory.size: "4Gi"` | `domain.memory.guest: "4Gi"` | Guest memory allocation |

#### Disk Configuration Mapping

```yaml
# Machine specification
disks:
- name: "root"
  size: "20Gi"
  storageClass: "fast-ssd"
  accessMode: "ReadWriteOnce"

# Generated PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: "{machine-name}-root"
spec:
  storageClassName: "fast-ssd"
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: "20Gi"

# Generated VirtualMachine disk reference
volumes:
- name: "root"
  persistentVolumeClaim:
    claimName: "{machine-name}-root"
disks:
- name: "root"
  disk:
    bus: "virtio"
```

## Processing Specifications

### Template Processing Algorithm

```go
func ProcessMachineSpec(machine *Machine) *ProcessedSpec {
    spec := &ProcessedSpec{}
    
    // 1. Apply base template
    if template := GetTemplate(machine.Spec.Template); template != nil {
        spec.CPU = template.CPU
        spec.Memory = template.Memory
        spec.Disks = template.Disks
    }
    
    // 2. Apply resource overrides
    if machine.Spec.Resources.CPU != nil {
        spec.CPU = machine.Spec.Resources.CPU
    }
    if machine.Spec.Resources.Memory != nil {
        spec.Memory = machine.Spec.Resources.Memory
    }
    
    // 3. Merge disk configurations
    if len(machine.Spec.Disks) > 0 {
        spec.Disks = mergeDiskConfigs(spec.Disks, machine.Spec.Disks)
    }
    
    return spec
}
```

### Network Configuration Processing

```go
func ProcessNetworkConfiguration(machine *Machine) []NetworkConfig {
    var configs []NetworkConfig
    
    for _, network := range machine.Spec.Networks {
        // Lookup NetworkConfiguration CRD
        netConfig := GetNetworkConfiguration(network.NetworkName)
        
        config := NetworkConfig{
            Name:       network.Name,
            Model:      network.Model,
            MacAddress: network.MacAddress,
            VLAN:       netConfig.Spec.VLAN,
            Bridge:     netConfig.Spec.Bridge,
        }
        configs = append(configs, config)
    }
    
    return configs
}
```

### Cloud-Init Processing

```yaml
# Machine specification with cloud-init
spec:
  cloudInit:
    userData: |
      #cloud-config
      users:
      - name: admin
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
        - ssh-rsa AAAAB3...
    secretRef:
      name: "machine-secrets"
      key: "userdata"

# Generated VirtualMachine volume
volumes:
- name: "cloudinitdisk"
  cloudInitNoCloud:
    userData: |
      #cloud-config
      users: ...
```

## Error Handling Reference

### Reconciliation Error Types

| Error Type | Condition | Recovery Action |
|------------|-----------|-----------------|
| `TemplateNotFound` | Invalid template reference | Fix template name in Machine spec |
| `NetworkConfigurationNotFound` | Missing NetworkConfiguration CRD | Create required NetworkConfiguration |
| `StorageClassNotFound` | Invalid StorageClass | Update storageClass or create StorageClass |
| `InsufficientResources` | Node resource exhaustion | Scale cluster or reduce resource requests |
| `KubeVirtApiError` | KubeVirt API failure | Check KubeVirt installation and permissions |

### Status Conditions

| Condition Type | Status | Reason | Description |
|----------------|--------|--------|-------------|
| `Ready` | True/False | Various | Overall machine readiness |
| `VirtualMachineReady` | True/False | `VMCreated`/`VMFailed` | VirtualMachine resource status |
| `StorageReady` | True/False | `PVCBound`/`PVCPending` | Storage provisioning status |
| `NetworkReady` | True/False | `NetworkConfigured`/`NetworkFailed` | Network configuration status |

### Finalizer Management

The operator uses finalizers for proper cleanup:

```yaml
metadata:
  finalizers:
  - machine.vitistack.io/cleanup
```

**Cleanup Process**:

1. Delete VirtualMachine and VirtualMachineInstance
2. Delete PersistentVolumeClaims
3. Clean up NetworkConfiguration references
4. Remove finalizer

## Monitoring Reference

### Prometheus Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `kubevirt_operator_machines_total` | Gauge | `phase`, `template` | Total machines by phase |
| `kubevirt_operator_reconciliation_duration_seconds` | Histogram | `controller` | Reconciliation duration |
| `kubevirt_operator_reconciliation_errors_total` | Counter | `controller`, `error_type` | Reconciliation errors |
| `kubevirt_operator_virtual_machines_total` | Gauge | `status` | Created VirtualMachine resources |
| `kubevirt_operator_storage_provisioning_duration_seconds` | Histogram | `storage_class` | Storage provisioning time |
| `kubevirt_operator_network_configuration_errors_total` | Counter | `network_name` | Network configuration errors |

### Health Endpoints

| Endpoint | Purpose | Status Codes |
|----------|---------|--------------|
| `/healthz` | Liveness probe | 200 (healthy), 500 (unhealthy) |
| `/readyz` | Readiness probe | 200 (ready), 500 (not ready) |
| `/metrics` | Prometheus metrics | 200 (metrics available) |

### Logging Reference

#### Structured Logging Fields

```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "level": "info",
  "controller": "Machine",
  "machine": "test-vm",
  "namespace": "default",
  "phase": "Creating",
  "message": "Creating VirtualMachine resource"
}
```

## Security Reference

### RBAC Requirements

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kubevirt-operator
rules:
- apiGroups: ["vitistack.io"]
  resources: ["machines", "networkconfigurations"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: ["kubevirt.io"]
  resources: ["virtualmachines", "virtualmachineinstances"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["persistentvolumeclaims", "secrets", "configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
```

### Service Account Configuration

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubevirt-operator-controller-manager
  namespace: kubevirt-operator-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubevirt-operator-manager-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubevirt-operator
subjects:
- kind: ServiceAccount
  name: kubevirt-operator-controller-manager
  namespace: kubevirt-operator-system
```

## Deployment Reference

### Helm Chart Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `image.repository` | `ghcr.io/vitistack/kubevirt-operator` | Container image |
| `image.tag` | Chart version | Image tag |
| `image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `replicaCount` | 1 | Operator replicas |
| `resources.limits.cpu` | `500m` | CPU limit |
| `resources.limits.memory` | `512Mi` | Memory limit |
| `resources.requests.cpu` | `100m` | CPU request |
| `resources.requests.memory` | `256Mi` | Memory request |
| `nodeSelector` | `{}` | Node selection constraints |
| `tolerations` | `[]` | Pod tolerations |
| `affinity` | `{}` | Pod affinity rules |

### Prerequisites

#### KubeVirt Installation

The operator requires KubeVirt to be installed in the cluster:

```bash
# Install KubeVirt operator
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v0.59.0/kubevirt-operator.yaml

# Create KubeVirt custom resource
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v0.59.0/kubevirt-cr.yaml

# Verify installation
kubectl get pods -n kubevirt
```

#### Storage Requirements

- At least one StorageClass with dynamic provisioning
- RWO (ReadWriteOnce) access mode support
- Sufficient storage capacity for VM disks

### Installation Methods

#### Helm Installation

```bash
# Add Helm repository
helm repo add vitistack oci://ghcr.io/vitistack/helm

# Install operator
helm install kubevirt-operator vitistack/kubevirt-operator \
  --namespace kubevirt-operator-system \
  --create-namespace
```

#### Manual Installation

```bash
# Apply CRDs and operator
kubectl apply -f config/crd/
kubectl apply -f config/rbac/
kubectl apply -f config/manager/
```

## Example Configurations

### Basic Virtual Machine

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: basic-vm
  namespace: default
spec:
  template: medium
```

### Virtual Machine with Overrides

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: custom-vm
  namespace: default
spec:
  template: small
  resources:
    cpu:
      cores: 4
    memory:
      size: "8Gi"
  disks:
  - name: "data"
    size: "100Gi"
    storageClass: "fast-ssd"
```

### Virtual Machine with Networking

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: networked-vm
  namespace: default
spec:
  template: medium
  networks:
  - name: "eth0"
    networkName: "prod-network"
    model: "virtio"
  - name: "eth1" 
    networkName: "storage-network"
    model: "virtio"
```

### Virtual Machine with Cloud-Init

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: cloud-init-vm
  namespace: default
spec:
  template: large
  cloudInit:
    userData: |
      #cloud-config
      users:
      - name: admin
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
        - ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB...
      packages:
      - curl
      - vim
      runcmd:
      - systemctl enable docker
      - systemctl start docker
```

## Troubleshooting Reference

### Common Issues

| Issue | Symptom | Resolution |
|-------|---------|------------|
| VM not starting | Machine stuck in Creating phase | Check KubeVirt installation and node resources |
| Storage provisioning failure | PVC in Pending state | Verify StorageClass exists and has available capacity |
| Network configuration error | VM created but no network access | Check NetworkConfiguration CRD and multus installation |
| Template not found | Machine validation error | Use valid template name: small, medium, or large |

### Debug Commands

**Check Machine Status**:

```bash
kubectl get machines -A
kubectl describe machine <machine-name>
```

**Check Generated Resources**:

```bash
kubectl get vm,vmi,pvc -l vitistack.io/machine=<machine-name>
```

**View Operator Logs**:

```bash
kubectl logs -n kubevirt-operator-system deployment/kubevirt-operator-controller-manager -f
```

**Check KubeVirt Status**:

```bash
kubectl get pods -n kubevirt
kubectl get vmi -A
```

This reference documentation provides comprehensive technical details for system administrators and developers working with the KubeVirt Operator, assuming familiarity with Kubernetes, KubeVirt, and virtualization concepts.

