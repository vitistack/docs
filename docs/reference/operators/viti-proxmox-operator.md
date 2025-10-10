# Proxmox Operator Reference

The Proxmox Operator manages Proxmox Virtual Environment (PVE) resources through Kubernetes Custom Resource Definitions. It provides declarative infrastructure management by reconciling Kubernetes resources with Proxmox clusters, nodes, and virtual machines.

## Architecture

### Controller Structure

The operator implements the Kubernetes controller pattern with the following components:

- **Machine Controller**: Reconciles `vitistack.io/v1alpha1/Machine` resources
- **ProxmoxCluster Controller**: Manages Proxmox cluster connections
- **ProxmoxNode Controller**: Handles individual node management
- **Initialize Service**: Validates Proxmox connectivity and authentication

### Repository Structure

```
├── cmd/                           # Main entry point
├── internal/
│   ├── controller/v1alpha1/       # Custom resource controllers
│   └── services/initializeservice/ # Proxmox initialization logic
├── config/
│   ├── crd/                       # Custom Resource Definitions
│   ├── rbac/                      # Role-based access control
│   ├── manager/                   # Operator deployment
│   ├── prometheus/                # Monitoring configuration
│   ├── network-policy/            # Network security policies
│   └── samples/                   # Example resources
├── charts/proxmox-operator/       # Helm deployment charts
└── test/                          # Test suites
```

## API Reference

### Machine Resource

The primary resource managed by the Proxmox Operator:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: string                     # Machine identifier
  namespace: string               # Kubernetes namespace
  labels:
    cluster.vitistack.io/cluster-name: string # Associated cluster
spec:
  # Core Configuration
  name: string                    # VM name in Proxmox
  vmid: int                      # Proxmox VM ID (100-999999999)
  node: string                   # Target Proxmox node
  template: string               # Base template/image
  
  # Resource Allocation
  cpu:
    cores: int                   # CPU cores (1-128)
    sockets: int                 # CPU sockets (1-4)
    threadsPerCore: int          # Threads per core (1-2)
  memory: int                    # RAM in bytes
  
  # Storage Configuration
  disks:
  - name: string                 # Disk identifier
    size: string                 # Size (e.g., "20G", "1T")
    storage: string              # Storage pool name
    type: string                 # Disk type: ide, sata, scsi, virtio
    cache: string                # Cache mode: none, writethrough, writeback
    format: string               # Format: raw, qcow2, vmdk
  
  # Network Configuration
  networks:
  - name: string                 # Network interface name
    bridge: string               # Proxmox bridge (vmbr0, vmbr1, etc.)
    model: string                # NIC model: e1000, virtio, rtl8139
    macAddress: string           # MAC address (optional)
    vlan: int                    # VLAN tag (1-4094)
    firewall: bool               # Enable Proxmox firewall
    
  # Proxmox-Specific Settings
  osType: string                 # OS type: linux, windows, solaris, other
  bootOrder: []string            # Boot device order: disk, network, cdrom
  agent: bool                    # Enable QEMU guest agent
  balloon: bool                  # Enable memory ballooning
  protection: bool               # Enable deletion protection
  
status:
  phase: string                  # Current phase: Pending, Creating, Running, Stopped, Error
  conditions: []Condition        # Status conditions
  vmid: int                     # Assigned VM ID
  node: string                  # Actual Proxmox node
  ipAddresses: []string         # Assigned IP addresses
  lastUpdated: string           # Last reconciliation timestamp
```

### ProxmoxCluster Resource

Represents a Proxmox cluster configuration:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: ProxmoxCluster
metadata:
  name: string
spec:
  # Connection Configuration
  endpoint: string               # Proxmox API URL (https://proxmox.example.com:8006)
  insecureSkipTLSVerify: bool   # Skip TLS certificate verification
  
  # Authentication
  credentials:
    username: string             # Proxmox username (user@pam, user@pve)
    password:                   # Password reference
      secretRef:
        name: string            # Secret name
        key: string             # Secret key
    tokenID: string             # API token ID (alternative to password)
    tokenSecret:                # API token secret
      secretRef:
        name: string
        key: string
        
  # Cluster Settings
  nodes: []string               # Available Proxmox nodes
  storages: []string            # Available storage pools
  networks: []string            # Available network bridges
  
status:
  ready: bool                   # Cluster connectivity status
  version: string               # Proxmox VE version
  nodes: []NodeStatus           # Per-node status information
  lastHealthCheck: string       # Last health check timestamp
```

### ProxmoxNode Resource

Represents individual Proxmox nodes:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: ProxmoxNode
metadata:
  name: string
spec:
  cluster: string               # Reference to ProxmoxCluster
  nodeName: string             # Proxmox node name
  maxVMs: int                  # Maximum VMs per node
  
status:
  ready: bool                  # Node availability
  resources:
    cpu:
      total: int               # Total CPU cores
      used: int                # Used CPU cores
    memory:
      total: int               # Total memory in bytes
      used: int                # Used memory in bytes
    storage:
      total: int               # Total storage in bytes
      used: int                # Used storage in bytes
  vmCount: int                 # Current VM count
```

## Configuration Reference

### Environment Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `PROXMOX_DEFAULT_CLUSTER` | string | - | Default cluster for machines without explicit cluster |
| `RECONCILE_INTERVAL` | duration | 30s | Reconciliation interval |
| `MAX_CONCURRENT_RECONCILES` | int | 5 | Maximum concurrent reconciliations |
| `METRICS_BIND_ADDRESS` | string | `:8080` | Metrics server bind address |
| `HEALTH_PROBE_BIND_ADDRESS` | string | `:8081` | Health probe bind address |

### Proxmox API Configuration

#### Authentication Methods

**Username/Password Authentication**:

```yaml
credentials:
  username: "operator@pve"
  password:
    secretRef:
      name: "proxmox-credentials"
      key: "password"
```

**API Token Authentication** (Recommended):

```yaml
credentials:
  username: "operator@pve"
  tokenID: "operator-token"
  tokenSecret:
    secretRef:
      name: "proxmox-credentials" 
      key: "token-secret"
```

#### TLS Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `insecureSkipTLSVerify` | bool | false | Skip certificate validation |
| `caCertificate` | string | - | Custom CA certificate |
| `clientCertificate` | string | - | Client certificate for mutual TLS |
| `clientKey` | string | - | Client private key |

## Operational Reference

### Reconciliation Logic

The Proxmox Operator implements the following reconciliation workflow:

1. **Resource Validation**: Validates Machine specification against Proxmox constraints
2. **Cluster Connection**: Establishes connection to target Proxmox cluster
3. **Node Selection**: Selects appropriate Proxmox node based on resources and constraints
4. **VM ID Assignment**: Allocates unique VM ID if not specified
5. **VM Creation**: Creates virtual machine with specified configuration
6. **Resource Provisioning**: Configures CPU, memory, storage, and network
7. **State Monitoring**: Monitors VM state and reports status
8. **Lifecycle Management**: Handles start, stop, restart, and deletion operations

### Proxmox API Integration

#### VM Management Operations

**VM Creation**:

```http
POST /api2/json/nodes/{node}/qemu
Content-Type: application/json

{
  "vmid": 100,
  "name": "test-vm",
  "cores": 2,
  "memory": 2048,
  "net0": "virtio,bridge=vmbr0",
  "scsi0": "local-lvm:20"
}
```

**VM Configuration Update**:

```http
PUT /api2/json/nodes/{node}/qemu/{vmid}/config
Content-Type: application/json

{
  "cores": 4,
  "memory": 4096
}
```

**VM State Control**:

```http
POST /api2/json/nodes/{node}/qemu/{vmid}/status/{action}
# Actions: start, stop, shutdown, reset, suspend, resume
```

**VM Status Query**:

```http
GET /api2/json/nodes/{node}/qemu/{vmid}/status/current
```

#### Resource Queries

**Cluster Status**:

```http
GET /api2/json/cluster/status
```

**Node Resources**:

```http
GET /api2/json/nodes/{node}/status
```

**Storage Information**:

```http
GET /api2/json/nodes/{node}/storage
```

**Network Configuration**:

```http
GET /api2/json/nodes/{node}/network
```

### VM ID Management

| Range | Purpose | Auto-Assignment |
|-------|---------|-----------------|
| 100-999 | System templates | No |
| 1000-9999 | Manual assignment | No |
| 10000-99999 | Operator managed | Yes |
| 100000+ | Reserved | No |

Auto-assignment algorithm:

1. Query existing VMs to identify used IDs
2. Find lowest available ID in operator range (10000+)
3. Reserve ID during VM creation
4. Handle conflicts with retry logic

## Processing Specifications

### Resource Allocation

#### CPU Configuration

| Specification | Proxmox Mapping | Validation |
|--------------|-----------------|------------|
| `cpu.cores` | `cores` parameter | 1-128 cores per VM |
| `cpu.sockets` | `sockets` parameter | 1-4 sockets per VM |
| `cpu.threadsPerCore` | Calculated as `cores/(sockets*threads)` | 1-2 threads per core |

#### Memory Management

- **Specification**: Bytes (e.g., 2147483648 for 2GB)
- **Proxmox Format**: Megabytes (e.g., 2048)
- **Conversion**: `proxmox_mb = bytes / 1048576`
- **Constraints**: Minimum 64MB, maximum node memory limit

#### Storage Configuration

**Disk Naming Convention**:

```
{type}{index}: {storage}:{size}[,format={format}][,cache={cache}]
Example: scsi0: local-lvm:20,format=raw,cache=writeback
```

**Supported Storage Types**:

| Type | Interface | Use Case |
|------|-----------|----------|
| `ide` | IDE | Legacy systems, CD-ROM |
| `sata` | SATA | Standard storage |
| `scsi` | SCSI | High-performance storage |
| `virtio` | VirtIO | Paravirtualized storage (recommended) |

### Network Configuration

#### Bridge Mapping

| Specification | Proxmox Format | Example |
|--------------|----------------|---------|
| `bridge: vmbr0` | `bridge=vmbr0` | `virtio,bridge=vmbr0` |
| `model: virtio` | `virtio` model prefix | `virtio,bridge=vmbr0` |
| `macAddress: aa:bb:cc:dd:ee:ff` | `,macaddr=aa:bb:cc:dd:ee:ff` | `virtio,bridge=vmbr0,macaddr=aa:bb:cc:dd:ee:ff` |

#### VLAN Configuration

```yaml
networks:
- name: eth0
  bridge: vmbr0
  vlan: 100        # Results in: virtio,bridge=vmbr0,tag=100
```

## Error Handling Reference

### Error Classification

| Error Type | HTTP Status | Retry Behavior | Resolution |
|------------|-------------|----------------|------------|
| Authentication | 401 | No | Update credentials |
| Authorization | 403 | No | Check user permissions |
| Resource Not Found | 404 | No | Verify cluster/node exists |
| Conflict | 409 | Yes | Retry with backoff |
| Server Error | 500 | Yes | Check Proxmox status |
| Network Error | - | Yes | Verify connectivity |

### Reconciliation Backoff

| Attempt | Delay | Maximum Delay |
|---------|-------|---------------|
| 1 | 1 second | - |
| 2 | 2 seconds | - |
| 3 | 4 seconds | - |
| 4+ | 8 seconds | 5 minutes |

### Common Error Patterns

| Error Message | Cause | Resolution |
|---------------|-------|------------|
| `VM {vmid} already exists` | VM ID conflict | Use different VM ID or delete existing VM |
| `insufficient resources on node` | Resource exhaustion | Select different node or increase resources |
| `storage '{storage}' not found` | Invalid storage pool | Verify storage pool exists and is accessible |
| `bridge '{bridge}' not found` | Invalid network bridge | Check network configuration on target node |
| `template '{template}' not found` | Missing VM template | Create or upload required template |

## Monitoring Reference

### Prometheus Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `proxmox_operator_machines_total` | Gauge | `phase`, `node` | Total machines by phase |
| `proxmox_operator_reconciliation_duration_seconds` | Histogram | `controller` | Reconciliation duration |
| `proxmox_operator_api_requests_total` | Counter | `method`, `endpoint`, `status` | Proxmox API requests |
| `proxmox_operator_errors_total` | Counter | `error_type`, `controller` | Error occurrences |
| `proxmox_cluster_nodes_available` | Gauge | `cluster` | Available nodes per cluster |
| `proxmox_cluster_connection_status` | Gauge | `cluster` | Cluster connectivity status |

### Health Endpoints

| Endpoint | Purpose | Status Codes |
|----------|---------|--------------|
| `/healthz` | Liveness probe | 200 (healthy), 500 (unhealthy) |
| `/readyz` | Readiness probe | 200 (ready), 500 (not ready) |
| `/metrics` | Prometheus metrics | 200 (metrics available) |

### Status Conditions

| Condition Type | Status | Reason | Description |
|----------------|--------|--------|-------------|
| `Ready` | True/False | Various | Overall machine readiness |
| `VMCreated` | True/False | `CreationSucceeded`/`CreationFailed` | VM creation status |
| `ResourcesAllocated` | True/False | `AllocationSucceeded`/`InsufficientResources` | Resource allocation |
| `NetworkConfigured` | True/False | `NetworkReady`/`NetworkError` | Network configuration |

## Security Reference

### RBAC Requirements

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: proxmox-operator
rules:
- apiGroups: ["vitistack.io"]
  resources: ["machines", "proxmoxclusters", "proxmoxnodes"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["secrets", "events"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
```

### Secret Management

**Credential Storage**:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: proxmox-credentials
type: Opaque
stringData:
  username: "operator@pve"
  password: "secure-password"
  # OR for token authentication:
  token-id: "operator-token"
  token-secret: "token-secret-value"
```

### Network Security

**Proxmox API Access Requirements**:

- **Port**: 8006 (HTTPS) or 8007 (SPICE proxy)
- **Protocol**: HTTPS (TLS 1.2+)
- **Firewall**: Allow operator pods to reach Proxmox nodes

## Deployment Reference

### Helm Chart Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `image.repository` | `ghcr.io/vitistack/proxmox-operator` | Container image |
| `image.tag` | Chart version | Image tag |
| `replicaCount` | 1 | Operator replicas |
| `resources.limits.cpu` | `200m` | CPU limit |
| `resources.limits.memory` | `256Mi` | Memory limit |
| `nodeSelector` | `{}` | Node selection constraints |
| `tolerations` | `[]` | Pod tolerations |
| `affinity` | `{}` | Pod affinity rules |

### Resource Requirements

**Minimum**:

- CPU: 50m
- Memory: 128Mi

**Recommended**:

- CPU: 200m  
- Memory: 256Mi

**Scaling Guidelines**:

- CPU scales with number of managed VMs
- Memory scales with cluster size and reconciliation frequency
- Network bandwidth depends on Proxmox API call frequency

## Troubleshooting Reference

### Debug Commands

**Check Operator Status**:

```bash
kubectl get pods -n proxmox-operator-system
kubectl logs -n proxmox-operator-system deployment/proxmox-operator-controller-manager
```

**Verify CRD Resources**:

```bash
kubectl get machines -A
kubectl get proxmoxclusters -A  
kubectl describe machine <machine-name>
```

**Test Proxmox Connectivity**:

```bash
# Test API endpoint
curl -k https://proxmox.example.com:8006/api2/json/version

# Validate credentials
curl -k -d "username=operator@pve&password=password" \
  https://proxmox.example.com:8006/api2/json/access/ticket
```

### Log Analysis

**Common Log Patterns**:

```
# Successful VM creation
"Successfully created VM" vmid=10001 node=pve-node1

# Authentication failure  
"Authentication failed" error="invalid credentials"

# Resource allocation error
"Insufficient resources" node=pve-node1 requested_memory=4096 available=2048

# Network configuration error
"Bridge not found" bridge=vmbr0 node=pve-node1
```

This reference documentation provides comprehensive technical details for system administrators and developers working with the Proxmox Operator, assuming familiarity with Kubernetes operators, Proxmox VE, and virtualization concepts.

