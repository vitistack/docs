# Custom Resource Definitions (CRDs)

!!! warning "Work in progress!"

The Viti Stack Custom Resource Definitions (CRDs) provide declarative API specifications for managing infrastructure resources in Kubernetes clusters. These CRDs define the data structures and schemas used across all Viti Stack operators to ensure consistent resource management and interoperability.

## API Overview

### API Group and Version

All Viti Stack CRDs belong to the `vitistack.io/v1alpha1` API group:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: <ResourceKind>
```

### Supported Resource Types

| Resource | Kind | Scope | Purpose |
|----------|------|-------|---------|
| Vitistack | `Vitistack` | Namespaced | Core infrastructure configuration |
| Machine | `Machine` | Namespaced | Virtual machine and compute resource |
| Machine Provider | `MachineProvider` | Namespaced | Machine provisioning backend |
| Kubernetes Cluster | `KubernetesCluster` | Namespaced | Kubernetes cluster configuration |
| Kubernetes Provider | `KubernetesProvider` | Namespaced | Kubernetes provisioning backend |
| Network Configuration | `NetworkConfiguration` | Namespaced | Network interface configuration |
| Network Namespace | `NetworkNamespace` | Namespaced | Network isolation boundary |
| Load Balancer | `LoadBalancer` | Namespaced | Load balancing configuration |
| KubeVirt Config | `KubevirtConfig` | Namespaced | KubeVirt operator configuration |
| Proxmox Config | `ProxmoxConfig` | Namespaced | Proxmox operator configuration |

## Core Resource Specifications

### Vitistack Resource

Primary configuration resource for Viti Stack infrastructure:

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

### Machine Resource

Defines virtual machine or compute resource specifications:

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

### NetworkConfiguration Resource

Defines network interface configuration and VLAN settings:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: NetworkConfiguration
metadata:
  name: string
  namespace: string
spec:
  # Network Identification
  networkId: string             # Unique network identifier
  vlan: int                     # VLAN ID (1-4094)
  
  # Layer 2 Configuration
  bridge: string                # Bridge interface name
  mtu: int                      # Maximum Transmission Unit
  
  # IP Configuration
  ipam:
    type: string                # IPAM type: static, dhcp, kea
    subnet: string              # Network subnet (CIDR)
    gateway: string             # Default gateway
    dns:
      servers: []string         # DNS server addresses
      searchDomains: []string   # DNS search domains
      
  # DHCP Configuration (when type=kea)
  dhcp:
    enabled: bool               # Enable DHCP server
    poolStart: string           # DHCP pool start address
    poolEnd: string             # DHCP pool end address
    leaseTime: string           # DHCP lease duration
    reservations:
    - macAddress: string        # MAC address for reservation
      ipAddress: string         # Reserved IP address
      hostname: string          # Reserved hostname
      
  # Security Configuration
  security:
    isolation: bool             # Enable network isolation
    firewallRules:
    - direction: string         # Rule direction: ingress, egress
      protocol: string          # Protocol: tcp, udp, icmp
      port: string              # Port or port range
      source: string            # Source CIDR or IP
      destination: string       # Destination CIDR or IP
      action: string            # Action: allow, deny
      
status:
  ready: bool                   # Network readiness status
  allocatedIPs: []string        # Currently allocated IP addresses
  connectedMachines: []string   # Connected machine references
```

### NetworkNamespace Resource

Defines network isolation boundaries and multi-tenancy:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: NetworkNamespace
metadata:
  name: string
  namespace: string
spec:
  # Isolation Configuration
  isolation:
    level: string               # Isolation level: strict, moderate, none
    allowedNamespaces: []string # Allowed namespace communication
    
  # Network Policies
  defaultPolicy:
    ingress: string             # Default ingress: allow, deny
    egress: string              # Default egress: allow, deny
    
  # Resource Limits
  limits:
    networks: int               # Maximum networks in namespace
    ipAddresses: int            # Maximum IP addresses
    bandwidth: string           # Bandwidth limit (e.g., "1Gbps")
    
  # Quality of Service
  qos:
    class: string               # QoS class: guaranteed, burstable, best-effort
    priority: int               # Network priority (0-255)
    
status:
  phase: string                 # Namespace phase: Active, Terminating
  networkCount: int             # Current network count
  ipAddressCount: int           # Current IP address usage
```

## Provider Configuration Resources

### MachineProvider Resource

Configuration for machine provisioning backends:

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

### KubernetesProvider Resource

Configuration for Kubernetes cluster provisioning:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesProvider
metadata:
  name: string
  namespace: string
spec:
  # Provider Configuration
  type: string                  # Provider type: talos, kubeadm, k3s
  
  # Cluster Configuration Template
  clusterTemplate:
    kubernetesVersion: string   # Kubernetes version
    cni:
      type: string              # CNI type: calico, flannel, cilium
      config: {}                # CNI-specific configuration
    controlPlane:
      replicas: int             # Control plane node count
      machineTemplate:          # Control plane machine template
        resources: {}
    workers:
    - name: string              # Worker group name
      replicas: int             # Worker node count
      machineTemplate:          # Worker machine template
        resources: {}
        
  # Network Configuration
  networking:
    podCIDR: string             # Pod network CIDR
    serviceCIDR: string         # Service network CIDR
    dnsDomain: string           # Cluster DNS domain
    
  # Add-ons Configuration
  addons:
    dns:
      enabled: bool             # Enable CoreDNS
      config: {}                # DNS configuration
    ingress:
      enabled: bool             # Enable ingress controller
      type: string              # Ingress type: nginx, traefik, istio
    storage:
      enabled: bool             # Enable storage classes
      defaultClass: string      # Default storage class
      
status:
  ready: bool                   # Provider readiness
  supportedVersions: []string   # Supported Kubernetes versions
  activeConlusters: int         # Active cluster count
```

## Operator Configuration Resources

### KubevirtConfig Resource

Configuration for KubeVirt operator integration:

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

### ProxmoxConfig Resource

Configuration for Proxmox operator integration:

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

## Data Type Specifications

### Common Data Types

#### ResourceRequirements

```yaml
resources:
  requests:
    cpu: string                 # CPU request (e.g., "100m", "1")
    memory: string              # Memory request (e.g., "128Mi", "1Gi")
    storage: string             # Storage request (e.g., "10Gi")
  limits:
    cpu: string                 # CPU limit
    memory: string              # Memory limit
    storage: string             # Storage limit
```

#### Condition

```yaml
conditions:
- type: string                  # Condition type
  status: string                # Status: True, False, Unknown
  reason: string                # Reason code
  message: string               # Human-readable message
  lastTransitionTime: string    # Last transition timestamp
  observedGeneration: int       # Observed resource generation
```

#### SecretReference

```yaml
secretRef:
  name: string                  # Secret name
  namespace: string             # Secret namespace (optional)
  key: string                   # Secret key (optional)
```

#### ObjectReference

```yaml
objectRef:
  apiVersion: string            # Referenced object API version
  kind: string                  # Referenced object kind
  name: string                  # Referenced object name
  namespace: string             # Referenced object namespace
  uid: string                   # Referenced object UID
```

### Network Data Types

#### IPAMConfiguration

```yaml
ipam:
  type: string                  # IPAM type: static, dhcp, kea, external
  subnet: string                # Network subnet in CIDR notation
  gateway: string               # Default gateway address
  dns:
    servers: []string           # DNS server addresses
    searchDomains: []string     # DNS search domains
  dhcp:
    enabled: bool               # Enable DHCP
    poolStart: string           # DHCP pool start
    poolEnd: string             # DHCP pool end
    leaseTime: string           # DHCP lease duration
```

#### NetworkInterface

```yaml
interfaces:
- name: string                  # Interface name
  type: string                  # Interface type: bridge, macvlan, ipvlan
  macAddress: string            # MAC address
  mtu: int                      # Maximum Transmission Unit
  vlan: int                     # VLAN ID
  ipConfiguration:
    type: string                # IP config type: static, dhcp
    address: string             # Static IP address
    netmask: string             # Network mask
    gateway: string             # Gateway address
```

## Validation and Constraints

### Resource Naming Conventions

| Field | Pattern | Example | Description |
|-------|---------|---------|-------------|
| `metadata.name` | `^[a-z0-9]([-a-z0-9]*[a-z0-9])?$` | `web-server-01` | RFC 1123 compliant |
| `spec.networkId` | `^[a-z0-9]([-a-z0-9]*[a-z0-9])?$` | `prod-network` | Network identifier |
| `spec.vlan` | `1-4094` | `100` | Valid VLAN range |

### Resource Constraints

#### CPU Specifications

| Field | Minimum | Maximum | Default | Format |
|-------|---------|---------|---------|---------|
| `cpu.cores` | 1 | 128 | 1 | Integer |
| `cpu.threads` | 1 | 2 | 1 | Integer |  
| `cpu.sockets` | 1 | 4 | 1 | Integer |

#### Memory Specifications

| Field | Minimum | Maximum | Format | Example |
|-------|---------|---------|---------|---------|
| `memory.size` | 128Mi | 1024Gi | Kubernetes quantity | "4Gi", "512Mi" |

#### Storage Specifications

| Field | Minimum | Maximum | Format | Example |
|-------|---------|---------|---------|---------|
| `storage.size` | 1Gi | 100Ti | Kubernetes quantity | "20Gi", "1Ti" |

### Network Constraints

| Field | Validation | Description |
|-------|------------|-------------|
| `subnet` | Valid CIDR | Must be valid IPv4/IPv6 CIDR |
| `ipAddress` | Valid IP | Must be valid IPv4/IPv6 address |
| `macAddress` | Valid MAC | Must be valid MAC address format |
| `vlan` | 1-4094 | Must be in valid VLAN range |

## Schema Evolution and Compatibility

### API Version Management

The CRDs follow Kubernetes API versioning conventions:

- **v1alpha1**: Initial API version with breaking changes possible
- **v1beta1**: Stable API with backward compatibility (future)
- **v1**: Stable API with long-term compatibility (future)

### Conversion Strategy

When upgrading between API versions:

```yaml
# Conversion webhook configuration
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: machines.vitistack.io
spec:
  conversion:
    strategy: Webhook
    webhook:
      service:
        name: vitistack-conversion-webhook
        namespace: vitistack-system
        path: /convert
```

### Backward Compatibility

| Change Type | v1alpha1 | v1beta1 | v1 |
|-------------|----------|---------|-----|
| Add optional field | ✅ | ✅ | ✅ |
| Add required field | ⚠️ | ❌ | ❌ |
| Remove field | ⚠️ | ❌ | ❌ |
| Rename field | ⚠️ | ❌ | ❌ |
| Change field type | ⚠️ | ❌ | ❌ |

## Integration Patterns

### Go API Integration

```go
import (
    v1alpha1 "github.com/vitistack/crds/pkg/v1alpha1"
    "k8s.io/apimachinery/pkg/runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
)

// Create scheme with CRD types
scheme := runtime.NewScheme()
v1alpha1.AddToScheme(scheme)

// Create client
client, err := client.New(config, client.Options{
    Scheme: scheme,
})

// Use typed resources
machine := &v1alpha1.Machine{}
err = client.Get(ctx, types.NamespacedName{
    Namespace: "default",
    Name: "my-machine",
}, machine)
```

### Unstructured Conversion

```go
import (
    unstructuredutil "github.com/vitistack/crds/pkg/unstructuredutil"
    v1alpha1 "github.com/vitistack/crds/pkg/v1alpha1"
)

// Convert typed to unstructured
machine := &v1alpha1.Machine{/* ... */}
unstructured, err := unstructuredutil.MachineToUnstructured(machine)

// Convert unstructured to typed
typed, err := unstructuredutil.MachineFromUnstructured(unstructured)
```

### Dynamic Client Usage

```go
import (
    "k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
    "k8s.io/apimachinery/pkg/runtime/schema"
    "k8s.io/client-go/dynamic"
)

// Create dynamic client
dynamicClient, err := dynamic.NewForConfig(config)

// Define GVR
machineGVR := schema.GroupVersionResource{
    Group:    "vitistack.io",
    Version:  "v1alpha1", 
    Resource: "machines",
}

// Create resource
machine := &unstructured.Unstructured{
    Object: map[string]interface{}{
        "apiVersion": "vitistack.io/v1alpha1",
        "kind":       "Machine",
        // ... spec
    },
}

result, err := dynamicClient.Resource(machineGVR).
    Namespace("default").
    Create(ctx, machine, metav1.CreateOptions{})
```

## Installation and Management

### CRD Installation

```bash
# Install all CRDs
make install-crds

# Install specific CRD
kubectl apply -f crds/vitistack.io_machines.yaml

# Verify installation
kubectl get crd | grep vitistack.io
```

### CRD Generation

```bash
# Generate CRDs from Go types
make manifests

# Generate deep copy methods
make generate

# Sanitize CRDs (remove unsupported integer formats)
make sanitize-crds

# Verify sanitized CRDs
make verify-crds
```

### Development Workflow

```bash
# Full development cycle
make generate     # Generate code
make manifests   # Generate CRDs
make sanitize-crds # Clean up CRDs
make test        # Run tests
make lint        # Lint code
```

This reference documentation provides comprehensive technical specifications for all Viti Stack CRDs, assuming familiarity with Kubernetes Custom Resource Definitions, API design patterns, and infrastructure as code concepts.