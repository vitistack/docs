# Kea Operator 2

!!! warning "Work in progress!"

The Kea Operator manages ISC Kea DHCP server reservations through Kubernetes Custom Resource Definitions. It reconciles `NetworkConfiguration` resources to ensure DHCP reservations match declared network interface configurations.

## Architecture

### Controller Structure

The operator implements the standard Kubernetes controller pattern with the following components:

- **NetworkConfiguration Controller**: Reconciles `vitistack.io/v1alpha1/NetworkConfiguration` resources
- **Kea Service Layer**: Abstracts DHCP server interactions
- **HTTP Client**: Manages REST API communication with Kea servers
- **Unstructured Converter**: Handles dynamic CRD access

### Repository Structure

```
├── cmd/                           # Main entry point
├── internal/
│   ├── controller/v1alpha1/       # NetworkConfiguration reconciler
│   ├── services/
│   │   ├── kea/                   # DHCP management logic
│   │   └── initialchecks/         # Startup validation
│   ├── clients/                   # HTTP client wrappers
│   ├── settings/                  # Configuration management
│   └── util/unstructuredconv/     # CRD conversion utilities
├── pkg/
│   ├── clients/keaclient/         # Kea REST API client
│   ├── interfaces/keainterface/   # Service interfaces
│   └── models/keamodels/          # Data structures
├── config/                        # Kubernetes manifests
└── charts/kea-operator/          # Helm deployment
```

## API Reference

### NetworkConfiguration Resource

The operator watches `NetworkConfiguration` resources with the following specification:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: NetworkConfiguration
metadata:
  name: string
  namespace: string
spec:
  clusterName: string        # Required
  datacenterName: string     # Required  
  supervisorName: string     # Required
  provider: string          # Required
  networkInterfaces:        # Required
  - name: string           # Interface identifier
    macAddress: string     # MAC address (normalized format)
```

### NetworkNamespace Dependency

Requires corresponding `NetworkNamespace` resource with IPv4 prefix in status:

```yaml
apiVersion: vitistack.io/v1alpha1
kind: NetworkNamespace
metadata:
  name: string
status:
  ipv4Prefix: string       # CIDR notation (e.g., "10.100.1.0/24")
```

## Configuration Reference

### Environment Variables

#### Connection Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `KEA_URL` | string | - | Primary Kea server URL (preferred) |
| `KEA_HOST` | string | - | Alternative: Kea server hostname |
| `KEA_PORT` | int | 8000 | Alternative: Kea server port |
| `KEA_BASE_URL` | string | - | Alternative: Base URL without port |
| `KEA_SECONDARY_URL` | string | - | Secondary server for HA failover |
| `KEA_TIMEOUT_SECONDS` | int | 10 | HTTP request timeout |
| `KEA_DISABLE_KEEPALIVES` | bool | false | Disable HTTP keep-alive |

#### Authentication Configuration

**Basic Authentication** (mutually exclusive with TLS certificates):

| Variable | Type | Description |
|----------|------|-------------|
| `KEA_BASIC_AUTH_USERNAME` | string | HTTP Basic Auth username |
| `KEA_BASIC_AUTH_PASSWORD` | string | HTTP Basic Auth password |

**TLS Client Certificates** (mutually exclusive with basic auth):

| Variable | Type | Description |
|----------|------|-------------|
| `KEA_TLS_CERT_FILE` | path | Client certificate file path |
| `KEA_TLS_KEY_FILE` | path | Client private key file path |
| `KEA_TLS_CA_FILE` | path | Certificate Authority file path |

#### TLS Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `KEA_TLS_ENABLED` | bool | false | Enable TLS encryption |
| `KEA_TLS_INSECURE` | bool | false | Skip certificate verification |
| `KEA_TLS_SERVER_NAME` | string | - | Override server name for verification |

## Operational Reference

### Reconciliation Logic

The controller implements the following reconciliation sequence:

1. **Resource Validation**: Validates NetworkConfiguration specification
2. **NetworkNamespace Lookup**: Retrieves IPv4 prefix from status field
3. **MAC Address Extraction**: Processes `spec.networkInterfaces[].macAddress`
4. **MAC Normalization**: Converts to lowercase, colon-separated format
5. **Subnet Resolution**: Maps IPv4 prefix to Kea subnet using `subnet4-list`
6. **Lease Discovery**: Queries existing leases via `lease4-get-by-hw-address`
7. **Reservation Management**: Creates reservations using `reservation-add`
8. **Status Updates**: Reports reconciliation results in resource status
9. **Cleanup Handling**: Removes reservations on resource deletion

### Kea REST API Integration

#### Command Structure

All Kea commands follow this JSON structure:

```json
{
  "command": "command-name",
  "service": ["dhcp4"],
  "arguments": {}
}
```

#### Core API Operations

**Subnet Discovery**:
```json
{
  "command": "subnet4-list",
  "service": ["dhcp4"]
}
```

**Lease Query**:
```json
{
  "command": "lease4-get-by-hw-address", 
  "service": ["dhcp4"],
  "arguments": {
    "hw-address": "aa:bb:cc:dd:ee:ff"
  }
}
```

**Reservation Creation**:
```json
{
  "command": "reservation-add",
  "service": ["dhcp4"], 
  "arguments": {
    "reservation": {
      "subnet-id": 1,
      "hw-address": "aa:bb:cc:dd:ee:ff",
      "ip-address": "10.100.1.50"
    }
  }
}
```

**Reservation Removal**:
```json
{
  "command": "reservation-del",
  "service": ["dhcp4"],
  "arguments": {
    "subnet-id": 1,
    "identifier-type": "hw-address", 
    "identifier": "aa:bb:cc:dd:ee:ff"
  }
}
```

### Response Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Continue processing |
| 1 | Generic error | Log error, potentially retry |
| 2 | Malformed command | Fix request format |
| 3 | Unsupported command | Check Kea version/configuration |
| 4 | Empty command | Validate request structure |

## Processing Specifications

### MAC Address Normalization

Input formats automatically converted to canonical form:

- `AA:BB:CC:DD:EE:FF` → `aa:bb:cc:dd:ee:ff`
- `aa-bb-cc-dd-ee-ff` → `aa:bb:cc:dd:ee:ff`
- `AABBCCDDEEFF` → **Rejected** (requires separators)

Validation regex: `^([0-9a-f]{2}:){5}[0-9a-f]{2}$`

### Subnet Matching Algorithm

The operator matches NetworkNamespace IPv4 prefixes to Kea subnets using network overlap detection:

```
NetworkNamespace: 10.100.1.0/24
Kea Subnet:      10.100.0.0/16
Result:          Match (namespace subnet within Kea subnet)
```

### High Availability Behavior

**Primary Server Available**:

- All operations directed to primary URL
- Health status monitored via `list-commands`

**Primary Server Failure**:

- Automatic failover to secondary URL
- Operations continue without interruption
- Primary server marked unhealthy

**Recovery Behavior**:

- Health checks every 30 seconds
- Automatic return to primary when available
- Reservation state synchronized between servers

## Error Handling Reference

### Error Classification

| Error Type | Retry Behavior | Requeue Interval |
|------------|----------------|------------------|
| Network/Timeout | Yes | 30 seconds |
| Authentication | Yes | 5 minutes |
| Permission | No | Manual intervention |
| Validation | No | Fix configuration |
| Resource | Yes | 1 minute |

### Circuit Breaker Configuration

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| Max Failures | 5 | Failures before opening circuit |
| Reset Timeout | 60 seconds | Time before retry attempt |
| Half-Open Limit | 3 | Test requests in half-open state |

### Reconciliation Backoff

Implements exponential backoff with the following parameters:

- **Initial Delay**: 100ms
- **Backoff Factor**: 2.0
- **Maximum Delay**: 30 seconds
- **Maximum Retries**: 5 attempts

## Monitoring Reference

### Prometheus Metrics

| Metric Name | Type | Labels | Description |
|-------------|------|--------|-------------|
| `kea_operator_dhcp_reservations_total` | Counter | `operation`, `status`, `subnet_id` | Total DHCP operations |
| `kea_operator_dhcp_operation_duration_seconds` | Histogram | `operation`, `server` | Operation latency |
| `kea_operator_server_health` | Gauge | `server`, `type` | Server health status |
| `kea_operator_active_network_configurations` | Gauge | - | Active resources |
| `kea_operator_reconciliation_errors_total` | Counter | `error_type`, `controller` | Error counts |

### Health Endpoints

| Endpoint | Purpose | Response Codes |
|----------|---------|----------------|
| `/healthz` | Liveness probe | 200 (healthy), 503 (unhealthy) |
| `/readyz` | Readiness probe | 200 (ready), 503 (not ready) |
| `/metrics` | Prometheus metrics | 200 (metrics data) |

## Security Specifications

### RBAC Requirements

Minimum required permissions:

```yaml
rules:
- apiGroups: ["vitistack.io"]
  resources: ["networkconfigurations"]
  verbs: ["get", "list", "watch", "update", "patch"]
- apiGroups: ["vitistack.io"]  
  resources: ["networknamespaces"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch"]
```

### TLS Configuration

**Minimum TLS Version**: 1.2  
**Supported Cipher Suites**:

- `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
- `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`  
- `TLS_RSA_WITH_AES_256_GCM_SHA384`

**Certificate Requirements**:

- Client certificates must include Extended Key Usage for client authentication
- CA certificates must be valid and trusted
- Private keys must be RSA 2048-bit minimum or ECDSA P-256

## Deployment Reference

### Helm Chart Values

| Parameter | Default | Description |
|-----------|---------|-------------|
| `image.repository` | `ghcr.io/vitistack/kea-operator` | Container image |
| `image.tag` | `latest` | Image tag |
| `replicaCount` | 1 | Number of operator pods |
| `resources.limits.cpu` | `100m` | CPU limit |
| `resources.limits.memory` | `128Mi` | Memory limit |
| `serviceAccount.create` | true | Create service account |
| `rbac.create` | true | Create RBAC resources |

### Resource Requirements

**Minimum**:
- CPU: 10m
- Memory: 64Mi

**Recommended**:
- CPU: 100m
- Memory: 128Mi

### Scaling Considerations

- **Single Instance**: Recommended for most deployments
- **High Availability**: Deploy multiple replicas with leader election
- **Resource Scaling**: Linear scaling with NetworkConfiguration count
- **Network Latency**: Performance depends on Kea server response times

## Troubleshooting Reference

### Common Error Patterns

| Error Message | Cause | Resolution |
|---------------|-------|------------|
| `no lease found for MAC` | Device hasn't obtained DHCP lease | Ensure device requests DHCP |
| `subnet not found for prefix` | NetworkNamespace prefix mismatch | Verify Kea subnet configuration |
| `connection refused` | Kea server unavailable | Check server status and connectivity |
| `unsupported command` | Kea version/build issue | Verify REST API enabled |
| `reservation already exists` | Duplicate reservation attempt | Check existing reservations |

### Debug Commands

**Check Operator Status**:

```bash
kubectl get pods -n kea-operator-system
kubectl logs -n kea-operator-system deployment/kea-operator-controller-manager
```

**Verify CRD Resources**:

```bash
kubectl get networkconfigurations -A
kubectl get networknamespaces -A -o jsonpath='{.items[*].status.ipv4Prefix}'
```

**Test Kea Connectivity**:

```bash
curl -X POST http://kea-server:8000 \
  -H "Content-Type: application/json" \
  -d '{"command": "list-commands"}'
```

This reference documentation provides comprehensive technical details for operators and developers working with the Kea Operator, assuming familiarity with Kubernetes operators, DHCP protocols, and REST APIs.

