# Talos Operator

!!! warning "Work in progress!"

The Talos Operator manages Talos Linux Kubernetes clusters through declarative Custom Resource Definitions. It automates cluster lifecycle management by reconciling `KubernetesCluster` resources and generating the necessary `Machine` resources for cluster topology deployment.

## Architecture

### Controller Structure

The operator implements a single primary controller:

- **KubernetesCluster Controller**: Reconciles `vitistack.io/v1alpha1/KubernetesCluster` resources
- **Machine Generation**: Creates Machine resources based on cluster topology
- **File Management**: Saves machine manifests to filesystem for debugging and inspection
- **Lifecycle Management**: Handles cluster creation, updates, and deletion with proper cleanup

### Repository Structure

```
├── cmd/                           # Main entry point
├── api/controllers/v1alpha1/      # KubernetesCluster controller
│   ├── kubernetescluster_controller.go
│   └── kubernetescluster_controller_test.go
├── config/
│   ├── default/                   # Default configuration overlay
│   ├── manager/                   # Operator deployment manifests
│   ├── rbac/                      # Role-based access control
│   ├── prometheus/                # Monitoring configuration
│   └── network-policy/            # Network security policies
├── charts/talos-operator/         # Helm deployment charts
├── examples/                      # Sample KubernetesCluster resources
├── internal/                      # Internal implementation packages
├── pkg/consts/                    # Constants and configuration
├── hack/results/                  # Generated machine manifests (runtime)
└── test/                          # Test suites
```

## API Reference

### KubernetesCluster Resource

The primary resource managed by the Talos Operator:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: string                     # Cluster identifier
  namespace: string               # Kubernetes namespace
  finalizers:
    - cluster.vitistack.io/finalizer # Cleanup finalizer
spec:
  # Cluster Configuration
  clusterName: string             # Talos cluster name
  kubernetesVersion: string       # Kubernetes version (e.g., "v1.28.3")
  talosVersion: string            # Talos Linux version (e.g., "v1.5.5")
  
  # Network Configuration
  clusterEndpoint: string         # Kubernetes API server endpoint
  podSubnets: []string           # Pod CIDR ranges
  serviceSubnets: []string       # Service CIDR ranges
  
  # Node Topology
  controlPlane:
    replicas: int                 # Number of control plane nodes (1, 3, 5)
    machineTemplate:              # Template for control plane machines
      spec: MachineSpec          # Machine specification
  
  workers:
  - name: string                 # Worker group name
    replicas: int                # Number of worker nodes
    machineTemplate:             # Template for worker machines
      spec: MachineSpec          # Machine specification
  
  # Talos Configuration
  talosConfig:
    # Machine Configuration
    machine:
      type: string               # Machine type: controlplane, worker
      token: string              # Bootstrap token
      ca:                        # Certificate authority configuration
        crt: string             # CA certificate
        key: string             # CA private key
      certSANs: []string         # Certificate subject alternative names
      
    # Cluster Configuration  
    cluster:
      name: string               # Cluster name
      controlPlane:
        endpoint: string         # Control plane endpoint
      network:
        dnsDomain: string        # Cluster DNS domain (default: cluster.local)
        podSubnets: []string     # Pod CIDR ranges
        serviceSubnets: []string # Service CIDR ranges
      
    # Installation Configuration
    install:
      disk: string               # Installation disk (e.g., "/dev/sda")
      image: string              # Talos system image
      bootloader: bool           # Install bootloader
      wipe: bool                 # Wipe disk before installation
      
status:
  phase: string                  # Current phase: Pending, Provisioning, Running, Failed
  conditions: []Condition        # Status conditions
  controlPlaneReady: bool        # Control plane readiness
  workersReady: int             # Number of ready worker nodes
  machineCount: int             # Total generated machines
  observedGeneration: int       # Last observed resource generation
  lastUpdated: string           # Last reconciliation timestamp
```

### Generated Machine Resources

The operator generates Machine resources with the following structure:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: string                   # Generated machine name
  namespace: string              # Inherited from KubernetesCluster
  labels:
    cluster.vitistack.io/cluster-name: string # Cluster reference
    cluster.vitistack.io/role: string        # Node role: controlplane, worker
    cluster.vitistack.io/worker-group: string # Worker group name (workers only)
  ownerReferences:
  - apiVersion: vitistack.io/v1alpha1
    kind: KubernetesCluster
    name: string                 # Parent cluster name
    uid: string                  # Parent cluster UID
spec:
  # Inherited from machineTemplate in KubernetesCluster
  # Machine-specific configuration based on role and template
  
  # Talos-specific additions
  talosConfig:
    machineType: string          # controlplane or worker
    clusterEndpoint: string      # Kubernetes API endpoint
    installDisk: string          # Target installation disk
```

## Configuration Reference

### Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `KUBEBUILDER_ASSETS` | string | - | Path to Kubebuilder test binaries |
| `RECONCILE_INTERVAL` | duration | 30s | KubernetesCluster reconciliation interval |
| `MAX_CONCURRENT_RECONCILES` | int | 1 | Maximum concurrent reconciliations |
| `METRICS_BIND_ADDRESS` | string | `:8080` | Metrics server bind address |
| `HEALTH_PROBE_BIND_ADDRESS` | string | `:8081` | Health probe bind address |
| `RESULTS_PATH` | string | `hack/results` | Path for generated machine manifests |

### Talos Configuration Parameters

#### Machine Configuration

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `machine.type` | string | Yes | Machine type: `controlplane` or `worker` |
| `machine.token` | string | Yes | Bootstrap token for cluster joining |
| `machine.ca.crt` | string | Yes | Certificate Authority certificate |
| `machine.ca.key` | string | Yes | Certificate Authority private key |
| `machine.certSANs` | []string | No | Additional certificate SANs |
| `machine.kubelet.image` | string | No | Kubelet container image |
| `machine.kubelet.extraArgs` | map[string]string | No | Additional kubelet arguments |

#### Cluster Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `cluster.name` | string | - | Cluster identifier |
| `cluster.controlPlane.endpoint` | string | - | Kubernetes API server endpoint |
| `cluster.network.dnsDomain` | string | `cluster.local` | Cluster DNS domain |
| `cluster.network.podSubnets` | []string | `["10.244.0.0/16"]` | Pod CIDR ranges |
| `cluster.network.serviceSubnets` | []string | `["10.96.0.0/12"]` | Service CIDR ranges |

#### Installation Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `install.disk` | string | `/dev/sda` | Target installation disk |
| `install.image` | string | - | Talos system image URL |
| `install.bootloader` | bool | true | Install bootloader |
| `install.wipe` | bool | false | Wipe disk before installation |
| `install.extraKernelArgs` | []string | - | Additional kernel arguments |

## Operational Reference

### Reconciliation Workflow

The KubernetesCluster controller implements the following reconciliation logic:

1. **Resource Validation**: Validates KubernetesCluster specification
2. **Finalizer Management**: Adds finalizer for cleanup handling
3. **Machine Generation**: Creates Machine resources based on topology:
   - Control plane machines: `{cluster-name}-cp-{index}`
   - Worker machines: `{cluster-name}-{worker-group}-{index}`
4. **File Generation**: Saves machine manifests to `hack/results/{cluster-name}/`
5. **Owner Reference**: Sets KubernetesCluster as owner for automatic cleanup
6. **Status Update**: Reports cluster status and machine count
7. **Deletion Handling**: Cleans up machines and generated files on deletion

### Machine Naming Conventions

| Node Type | Naming Pattern | Example |
|-----------|----------------|---------|
| Control Plane | `{cluster-name}-cp-{index}` | `prod-cluster-cp-0` |
| Worker | `{cluster-name}-{worker-group}-{index}` | `prod-cluster-workers-0` |

Index starts from 0 and increments based on replica count.

### File System Operations

#### Generated Manifest Structure

```
hack/results/{cluster-name}/
├── {cluster-name}-cp-0.yaml          # Control plane machine 0
├── {cluster-name}-cp-1.yaml          # Control plane machine 1  
├── {cluster-name}-cp-2.yaml          # Control plane machine 2
├── {cluster-name}-workers-0.yaml     # Worker group machine 0
├── {cluster-name}-workers-1.yaml     # Worker group machine 1
└── {cluster-name}-custom-0.yaml      # Custom worker group machine 0
```

#### File Operations

| Operation | Trigger | Behavior |
|-----------|---------|----------|
| Create | New KubernetesCluster | Generate all machine manifests |
| Update | Spec change | Regenerate affected machine manifests |
| Delete | Resource deletion | Remove all cluster manifest files |

## Processing Specifications

### Cluster Topology Processing

#### Control Plane Generation

```go
for i := 0; i < spec.ControlPlane.Replicas; i++ {
    machine := &Machine{
        ObjectMeta: metav1.ObjectMeta{
            Name:      fmt.Sprintf("%s-cp-%d", clusterName, i),
            Namespace: cluster.Namespace,
            Labels: map[string]string{
                "cluster.vitistack.io/cluster-name": clusterName,
                "cluster.vitistack.io/role":         "controlplane",
            },
        },
        Spec: spec.ControlPlane.MachineTemplate.Spec,
    }
    // Set owner reference and create machine
}
```

#### Worker Group Generation

```go
for _, workerGroup := range spec.Workers {
    for i := 0; i < workerGroup.Replicas; i++ {
        machine := &Machine{
            ObjectMeta: metav1.ObjectMeta{
                Name:      fmt.Sprintf("%s-%s-%d", clusterName, workerGroup.Name, i),
                Namespace: cluster.Namespace,
                Labels: map[string]string{
                    "cluster.vitistack.io/cluster-name":    clusterName,
                    "cluster.vitistack.io/role":            "worker",
                    "cluster.vitistack.io/worker-group":    workerGroup.Name,
                },
            },
            Spec: workerGroup.MachineTemplate.Spec,
        }
        // Set owner reference and create machine
    }
}
```

### Talos Configuration Generation

#### Machine Type Mapping

| KubernetesCluster Role | Talos Machine Type | Configuration |
|------------------------|-------------------|---------------|
| `controlPlane` | `controlplane` | API server, etcd, scheduler, controller-manager |
| `workers[].name` | `worker` | Kubelet, container runtime |

#### Network Configuration Processing

```yaml
# From KubernetesCluster spec
spec:
  podSubnets: ["10.244.0.0/16"]
  serviceSubnets: ["10.96.0.0/12"]

# Generated in Machine talosConfig
cluster:
  network:
    podSubnets: ["10.244.0.0/16"]
    serviceSubnets: ["10.96.0.0/12"]
```

## Error Handling Reference

### Reconciliation Errors

| Error Type | Condition | Recovery Action |
|------------|-----------|-----------------|
| `ValidationError` | Invalid cluster specification | Fix specification and reapply |
| `MachineCreationError` | Failed to create Machine resource | Retry with exponential backoff |
| `FileSystemError` | Failed to write manifest files | Check filesystem permissions |
| `OwnerReferenceError` | Failed to set owner references | Retry operation |

### Status Conditions

| Condition Type | Status | Reason | Description |
|----------------|--------|--------|-------------|
| `Ready` | True/False | Various | Overall cluster readiness |
| `MachinesCreated` | True/False | `CreationSucceeded`/`CreationFailed` | Machine resource creation |
| `FilesGenerated` | True/False | `GenerationSucceeded`/`GenerationFailed` | Manifest file generation |
| `TopologyValid` | True/False | `ValidationSucceeded`/`ValidationFailed` | Cluster topology validation |

### Error Recovery Patterns

#### Exponential Backoff

| Attempt | Delay | Maximum Delay |
|---------|-------|---------------|
| 1 | 1 second | - |
| 2 | 2 seconds | - |
| 3 | 4 seconds | - |
| 4+ | 8 seconds | 5 minutes |

#### Cleanup Procedures

**Finalizer Handling**:

```yaml
metadata:
  finalizers:
    - cluster.vitistack.io/finalizer
```

**Cleanup Steps**:

1. Delete all owned Machine resources
2. Remove generated manifest files
3. Remove finalizer
4. Allow resource deletion

## Monitoring Reference

### Prometheus Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `talos_operator_clusters_total` | Gauge | `phase` | Total clusters by phase |
| `talos_operator_machines_generated` | Counter | `cluster`, `role` | Generated machines count |
| `talos_operator_reconciliation_duration_seconds` | Histogram | `controller` | Reconciliation duration |
| `talos_operator_reconciliation_errors_total` | Counter | `controller`, `error_type` | Reconciliation errors |
| `talos_operator_file_operations_total` | Counter | `operation`, `status` | File operations |

### Health Endpoints

| Endpoint | Purpose | Response Codes |
|----------|---------|----------------|
| `/healthz` | Liveness probe | 200 (healthy), 500 (unhealthy) |
| `/readyz` | Readiness probe | 200 (ready), 500 (not ready) |
| `/metrics` | Prometheus metrics | 200 (metrics available) |

### Logging Reference

#### Log Levels

| Level | Usage | Example |
|-------|-------|---------|
| `INFO` | Normal operations | `"Successfully created machine"` |
| `WARN` | Non-fatal issues | `"Machine already exists, skipping"` |
| `ERROR` | Reconciliation failures | `"Failed to create machine resource"` |
| `DEBUG` | Detailed tracing | `"Processing worker group: workers"` |

#### Structured Logging Fields

```json
{
  "level": "info",
  "timestamp": "2024-01-01T12:00:00Z",
  "controller": "KubernetesCluster",
  "cluster": "prod-cluster",
  "namespace": "default",
  "message": "Successfully reconciled cluster"
}
```

## Security Reference

### RBAC Requirements

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: talos-operator
rules:
- apiGroups: ["vitistack.io"]
  resources: ["kubernetesclusters", "machines"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

### Service Account Configuration

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: talos-operator-controller-manager
  namespace: talos-operator-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: talos-operator-manager-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: talos-operator
subjects:
- kind: ServiceAccount
  name: talos-operator-controller-manager
  namespace: talos-operator-system
```

## Deployment Reference

### Helm Chart Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `image.repository` | `ghcr.io/vitistack/talos-operator` | Container image |
| `image.tag` | Chart version | Image tag |
| `image.pullPolicy` | `IfNotPresent` | Image pull policy |
| `replicaCount` | 1 | Operator replicas |
| `resources.limits.cpu` | `500m` | CPU limit |
| `resources.limits.memory` | `128Mi` | Memory limit |
| `resources.requests.cpu` | `10m` | CPU request |
| `resources.requests.memory` | `64Mi` | Memory request |

### Installation Methods

#### Helm Installation

```bash
# Add Helm repository
helm repo add vitistack oci://ghcr.io/vitistack/helm

# Install operator
helm install talos-operator vitistack/talos-operator \
  --namespace talos-operator-system \
  --create-namespace
```

#### Direct Deployment

```bash
# Deploy using Makefile
make deploy IMG=ghcr.io/vitistack/talos-operator:latest
```

## Example Configurations

### Simple Cluster

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: simple-cluster
spec:
  clusterName: simple-cluster
  kubernetesVersion: v1.28.3
  talosVersion: v1.5.5
  clusterEndpoint: https://192.168.1.100:6443
  
  controlPlane:
    replicas: 3
    machineTemplate:
      spec:
        # Machine specification for control plane nodes
        
  workers:
  - name: workers
    replicas: 2
    machineTemplate:
      spec:
        # Machine specification for worker nodes
```

### Multi-Worker Group Cluster

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: complex-cluster
spec:
  clusterName: complex-cluster
  kubernetesVersion: v1.28.3
  talosVersion: v1.5.5
  clusterEndpoint: https://192.168.1.100:6443
  
  controlPlane:
    replicas: 3
    machineTemplate:
      spec: {} # Control plane machine spec
        
  workers:
  - name: general-workers
    replicas: 3
    machineTemplate:
      spec: {} # General worker spec
      
  - name: gpu-workers
    replicas: 2
    machineTemplate:
      spec: {} # GPU worker spec
      
  - name: storage-workers
    replicas: 1
    machineTemplate:
      spec: {} # Storage worker spec
```

This reference documentation provides comprehensive technical details for system administrators and developers working with the Talos Operator, assuming familiarity with Kubernetes operators, Talos Linux, and cluster-api concepts.



