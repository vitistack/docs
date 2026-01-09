# Vitistack Operator

!!! warning "Work in progress!"

The Vitistack Operator provides a centralized API for managing and orchestrating Viti Stack infrastructure components. It acts as the core control plane operator that aggregates data from various infrastructure operators and provides a unified interface for infrastructure management and monitoring.

## Architecture

### Application Structure

The Vitistack Operator is built as a REST API service rather than a traditional Kubernetes controller-based operator:

- **HTTP Server**: RESTful API service for infrastructure data aggregation
- **Event Manager**: Event processing and distribution system
- **Repository Layer**: Data persistence and retrieval abstraction
- **Client Integrations**: Connections to various Viti Stack operators
- **Cache Layer**: Performance optimization for frequently accessed data

### Repository Structure

```
├── cmd/vitistack-operator/        # Main application entry point
├── internal/
│   ├── cache/                     # Caching implementations
│   ├── clients/                   # External service clients
│   ├── handlers/                  # HTTP request handlers
│   ├── helpers/                   # Utility functions
│   ├── httpserver/                # HTTP server configuration
│   ├── listeners/                 # Event listeners
│   ├── middlewares/               # HTTP middleware components
│   ├── repositories/              # Data repository implementations
│   ├── repositoryinterfaces/      # Repository interface definitions
│   ├── routes/                    # API route definitions
│   ├── services/                  # Business logic services
│   └── settings/                  # Configuration management
├── pkg/
│   ├── consts/                    # Application constants
│   └── eventmanager/              # Event management system
├── charts/vitistack-operator/     # Helm deployment charts
└── hack/                          # Development and build scripts
```

## API Reference

### Core Service Endpoints

The Vitistack Operator exposes a RESTful API for infrastructure management:

#### Infrastructure Data API

**Base URL**: `http://vitistack-operator:9991/api/v1`

##### Cluster Information

```http
GET /clusters
```

Retrieves information about all managed Kubernetes clusters.

**Response Schema**:

```json
{
  "clusters": [
    {
      "id": "string",
      "name": "string",
      "namespace": "string",
      "status": "string",
      "nodes": {
        "total": "integer",
        "ready": "integer"
      },
      "operators": {
        "proxmox": "boolean",
        "talos": "boolean",
        "kea": "boolean",
        "kubeVirt": "boolean"
      },
      "lastUpdated": "timestamp"
    }
  ]
}
```

##### Infrastructure Resources

```http
GET /infrastructure
```

Aggregated view of infrastructure resources across all operators.

**Response Schema**:

```json
{
  "summary": {
    "machines": {
      "total": "integer",
      "running": "integer",
      "pending": "integer",
      "failed": "integer"
    },
    "networks": {
      "total": "integer",
      "active": "integer"
    },
    "storage": {
      "total": "integer",
      "available": "integer"
    }
  },
  "operators": {
    "proxmox": {
      "status": "string",
      "version": "string",
      "resources": {}
    },
    "talos": {
      "status": "string",
      "version": "string",
      "resources": {}
    },
    "kea": {
      "status": "string",
      "version": "string",
      "resources": {}
    },
    "kubevirt": {
      "status": "string",
      "version": "string",
      "resources": {}
    }
  }
}
```

##### Resource Metrics

```http
GET /metrics
```

Prometheus-compatible metrics endpoint for monitoring.

**Metrics Format**:

```
# HELP vitistack_operator_clusters_total Total number of managed clusters
# TYPE vitistack_operator_clusters_total gauge
vitistack_operator_clusters_total{status="active"} 3

# HELP vitistack_operator_machines_total Total number of managed machines
# TYPE vitistack_operator_machines_total gauge
vitistack_operator_machines_total{operator="proxmox",status="running"} 15

# HELP vitistack_operator_api_requests_total Total API requests
# TYPE vitistack_operator_api_requests_total counter
vitistack_operator_api_requests_total{method="GET",endpoint="/clusters",status="200"} 1234
```

##### Health Endpoints

```http
GET /health
```

Service health check endpoint.

**Response Schema**:

```json
{
  "status": "healthy|degraded|unhealthy",
  "timestamp": "timestamp",
  "checks": {
    "database": "healthy|unhealthy",
    "cache": "healthy|unhealthy",
    "operators": {
      "proxmox": "healthy|unhealthy|unreachable",
      "talos": "healthy|unhealthy|unreachable",
      "kea": "healthy|unhealthy|unreachable",
      "kubevirt": "healthy|unhealthy|unreachable"
    }
  }
}
```

```http
GET /ready
```

Readiness probe endpoint for Kubernetes.

**Response Codes**:

- `200`: Service ready to accept traffic
- `503`: Service not ready

## Configuration Reference

### Environment Variables

| Variable                | Type     | Default | Description                             |
| ----------------------- | -------- | ------- | --------------------------------------- |
| `PORT`                  | int      | 9991    | HTTP server port                        |
| `LOG_LEVEL`             | string   | info    | Logging level: debug, info, warn, error |
| `CACHE_TTL`             | duration | 300s    | Cache time-to-live                      |
| `METRICS_ENABLED`       | bool     | true    | Enable Prometheus metrics               |
| `HEALTH_CHECK_INTERVAL` | duration | 30s     | Health check interval                   |
| `API_TIMEOUT`           | duration | 30s     | API request timeout                     |
| `DATABASE_URL`          | string   | -       | Database connection string              |
| `REDIS_URL`             | string   | -       | Redis cache connection string           |

### Operator Client Configuration

#### Proxmox Operator Integration

| Parameter                    | Type     | Default | Description                   |
| ---------------------------- | -------- | ------- | ----------------------------- |
| `PROXMOX_OPERATOR_ENDPOINT`  | string   | -       | Proxmox operator API endpoint |
| `PROXMOX_OPERATOR_NAMESPACE` | string   | default | Proxmox operator namespace    |
| `PROXMOX_SYNC_INTERVAL`      | duration | 60s     | Data synchronization interval |

#### Talos Operator Integration

| Parameter                  | Type     | Default | Description                   |
| -------------------------- | -------- | ------- | ----------------------------- |
| `TALOS_OPERATOR_ENDPOINT`  | string   | -       | Talos operator API endpoint   |
| `TALOS_OPERATOR_NAMESPACE` | string   | default | Talos operator namespace      |
| `TALOS_SYNC_INTERVAL`      | duration | 60s     | Data synchronization interval |

#### Kea Operator Integration

| Parameter                | Type     | Default | Description                   |
| ------------------------ | -------- | ------- | ----------------------------- |
| `KEA_OPERATOR_ENDPOINT`  | string   | -       | Kea operator API endpoint     |
| `KEA_OPERATOR_NAMESPACE` | string   | default | Kea operator namespace        |
| `KEA_SYNC_INTERVAL`      | duration | 30s     | Data synchronization interval |

#### KubeVirt Operator Integration

| Parameter                     | Type     | Default  | Description                    |
| ----------------------------- | -------- | -------- | ------------------------------ |
| `KUBEVIRT_OPERATOR_ENDPOINT`  | string   | -        | KubeVirt operator API endpoint |
| `KUBEVIRT_OPERATOR_NAMESPACE` | string   | kubevirt | KubeVirt operator namespace    |
| `KUBEVIRT_SYNC_INTERVAL`      | duration | 45s      | Data synchronization interval  |

## Service Architecture Reference

### HTTP Server Configuration

#### Server Settings

| Parameter               | Type     | Default | Description               |
| ----------------------- | -------- | ------- | ------------------------- |
| `server.host`           | string   | 0.0.0.0 | Server bind address       |
| `server.port`           | int      | 9991    | Server port               |
| `server.readTimeout`    | duration | 30s     | Read timeout              |
| `server.writeTimeout`   | duration | 30s     | Write timeout             |
| `server.idleTimeout`    | duration | 120s    | Idle connection timeout   |
| `server.maxHeaderBytes` | int      | 1048576 | Maximum header size (1MB) |

#### Middleware Configuration

**Logging Middleware**:

```json
{
  "enabled": true,
  "format": "json",
  "includeHeaders": false,
  "excludePaths": ["/health", "/ready"]
}
```

**CORS Middleware**:

```json
{
  "enabled": true,
  "allowedOrigins": ["*"],
  "allowedMethods": ["GET", "POST", "PUT", "DELETE"],
  "allowedHeaders": ["Content-Type", "Authorization"],
  "exposedHeaders": ["X-Total-Count"],
  "maxAge": 86400
}
```

**Rate Limiting**:

```json
{
  "enabled": true,
  "requestsPerMinute": 60,
  "burstSize": 10,
  "keyGenerator": "ip"
}
```

### Repository Layer

#### Database Configuration

**Supported Databases**:

- PostgreSQL (recommended)
- MySQL
- SQLite (development only)

**Connection Pool Settings**:

| Parameter            | Type     | Default | Description                  |
| -------------------- | -------- | ------- | ---------------------------- |
| `db.maxOpenConns`    | int      | 25      | Maximum open connections     |
| `db.maxIdleConns`    | int      | 5       | Maximum idle connections     |
| `db.connMaxLifetime` | duration | 300s    | Connection maximum lifetime  |
| `db.connMaxIdleTime` | duration | 60s     | Connection maximum idle time |

#### Cache Configuration

**Redis Settings**:

| Parameter                | Type   | Default   | Description            |
| ------------------------ | ------ | --------- | ---------------------- |
| `cache.redis.host`       | string | localhost | Redis host             |
| `cache.redis.port`       | int    | 6379      | Redis port             |
| `cache.redis.db`         | int    | 0         | Redis database number  |
| `cache.redis.password`   | string | -         | Redis password         |
| `cache.redis.maxRetries` | int    | 3         | Maximum retry attempts |
| `cache.redis.poolSize`   | int    | 10        | Connection pool size   |

### Event Management System

#### Event Types

| Event Type                          | Description                   | Data Schema                     |
| ----------------------------------- | ----------------------------- | ------------------------------- |
| `infrastructure.machine.created`    | New machine provisioned       | Machine resource details        |
| `infrastructure.machine.deleted`    | Machine deprovisioned         | Machine identifier and metadata |
| `infrastructure.cluster.updated`    | Cluster configuration changed | Cluster diff information        |
| `infrastructure.operator.status`    | Operator status change        | Operator name and new status    |
| `infrastructure.network.configured` | Network configuration applied | Network configuration details   |

#### Event Processing

**Event Handler Configuration**:

```json
{
  "handlers": {
    "database": {
      "enabled": true,
      "batchSize": 100,
      "flushInterval": "10s"
    },
    "webhook": {
      "enabled": false,
      "endpoints": [
        {
          "url": "https://webhook.example.com/events",
          "timeout": "30s",
          "retries": 3
        }
      ]
    },
    "metrics": {
      "enabled": true,
      "updateInterval": "5s"
    }
  }
}
```

## Data Models Reference

### Infrastructure Resource Model

```json
{
  "id": "string",
  "type": "machine|cluster|network|storage",
  "name": "string",
  "namespace": "string",
  "operator": "proxmox|talos|kea|kubevirt",
  "status": "pending|running|failed|unknown",
  "metadata": {
    "labels": {},
    "annotations": {},
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },
  "spec": {},
  "status": {}
}
```

### Operator Status Model

```json
{
  "operator": "string",
  "version": "string",
  "status": "healthy|degraded|unhealthy|unreachable",
  "lastSeen": "timestamp",
  "resources": {
    "total": "integer",
    "healthy": "integer",
    "failed": "integer"
  },
  "capabilities": ["string"],
  "endpoints": {
    "api": "string",
    "metrics": "string",
    "health": "string"
  }
}
```

### Cluster Resource Model

```json
{
  "id": "string",
  "name": "string",
  "namespace": "string",
  "type": "kubernetes|proxmox|talos",
  "status": "active|inactive|failed",
  "nodes": {
    "total": "integer",
    "ready": "integer",
    "unready": "integer"
  },
  "networking": {
    "podCIDR": "string",
    "serviceCIDR": "string",
    "dnsName": "string"
  },
  "operators": {
    "installed": ["string"],
    "healthy": ["string"]
  },
  "metadata": {
    "createdAt": "timestamp",
    "updatedAt": "timestamp",
    "version": "string"
  }
}
```

## Monitoring Reference

### Prometheus Metrics

| Metric Name                                       | Type      | Labels                          | Description                |
| ------------------------------------------------- | --------- | ------------------------------- | -------------------------- |
| `vitistack_operator_info`                         | Gauge     | `version`                       | Operator information       |
| `vitistack_operator_clusters_total`               | Gauge     | `status`, `type`                | Total clusters by status   |
| `vitistack_operator_machines_total`               | Gauge     | `operator`, `status`, `cluster` | Total machines by operator |
| `vitistack_operator_api_requests_total`           | Counter   | `method`, `endpoint`, `status`  | API request count          |
| `vitistack_operator_api_request_duration_seconds` | Histogram | `method`, `endpoint`            | API request duration       |
| `vitistack_operator_cache_hits_total`             | Counter   | `cache_type`                    | Cache hit count            |
| `vitistack_operator_cache_misses_total`           | Counter   | `cache_type`                    | Cache miss count           |
| `vitistack_operator_operator_status`              | Gauge     | `operator`, `status`            | Operator health status     |
| `vitistack_operator_events_processed_total`       | Counter   | `event_type`, `status`          | Processed event count      |
| `vitistack_operator_database_connections`         | Gauge     | `state`                         | Database connection count  |

### Health Check Endpoints

| Endpoint            | Method | Description           | Response Codes |
| ------------------- | ------ | --------------------- | -------------- |
| `/health`           | GET    | Overall health status | 200, 503       |
| `/health/live`      | GET    | Liveness check        | 200, 503       |
| `/ready`            | GET    | Readiness check       | 200, 503       |
| `/health/operators` | GET    | Operator connectivity | 200, 503       |
| `/health/database`  | GET    | Database connectivity | 200, 503       |
| `/health/cache`     | GET    | Cache connectivity    | 200, 503       |

### Logging Configuration

#### Log Levels

| Level   | Usage               | Example                                          |
| ------- | ------------------- | ------------------------------------------------ |
| `DEBUG` | Detailed tracing    | `"Processing request for cluster: prod-cluster"` |
| `INFO`  | Normal operations   | `"Successfully synchronized operator data"`      |
| `WARN`  | Non-critical issues | `"Operator connection timeout, retrying"`        |
| `ERROR` | Critical errors     | `"Failed to update cluster status"`              |

#### Structured Logging Format

```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "level": "info",
  "component": "httpserver",
  "requestId": "req-123456",
  "method": "GET",
  "path": "/api/v1/clusters",
  "statusCode": 200,
  "duration": "150ms",
  "userAgent": "kubectl/v1.28.0",
  "message": "Request completed successfully"
}
```

## Security Reference

### Authentication & Authorization

#### API Key Authentication

**Header Format**:

```http
Authorization: Bearer <api-key>
```

**API Key Management**:

| Parameter        | Type     | Description                   |
| ---------------- | -------- | ----------------------------- |
| `auth.enabled`   | bool     | Enable API key authentication |
| `auth.keyHeader` | string   | Authorization header name     |
| `auth.keyPrefix` | string   | Authorization header prefix   |
| `auth.keys`      | []string | Valid API keys                |

#### RBAC Integration

**Kubernetes Service Account**:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vitistack-operator
  namespace: vitistack-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vitistack-operator
rules:
  - apiGroups: ["vitistack.io"]
    resources: ["*"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "patch"]
```

### Network Security

**TLS Configuration**:

| Parameter        | Type   | Default | Description             |
| ---------------- | ------ | ------- | ----------------------- |
| `tls.enabled`    | bool   | false   | Enable TLS              |
| `tls.certFile`   | string | -       | TLS certificate file    |
| `tls.keyFile`    | string | -       | TLS private key file    |
| `tls.caFile`     | string | -       | TLS CA certificate file |
| `tls.minVersion` | string | 1.2     | Minimum TLS version     |

## Deployment Reference

### Helm Chart Configuration

| Parameter                   | Default                                | Description             |
| --------------------------- | -------------------------------------- | ----------------------- |
| `image.repository`          | `ghcr.io/vitistack/vitistack-operator` | Container image         |
| `image.tag`                 | Chart version                          | Image tag               |
| `image.pullPolicy`          | `IfNotPresent`                         | Image pull policy       |
| `replicaCount`              | 1                                      | Number of replicas      |
| `service.type`              | `ClusterIP`                            | Kubernetes service type |
| `service.port`              | 9991                                   | Service port            |
| `resources.limits.cpu`      | `500m`                                 | CPU limit               |
| `resources.limits.memory`   | `512Mi`                                | Memory limit            |
| `resources.requests.cpu`    | `100m`                                 | CPU request             |
| `resources.requests.memory` | `256Mi`                                | Memory request          |

### Installation Methods

#### Helm Installation

```bash
# Add Helm repository
helm repo add vitistack oci://ghcr.io/vitistack/helm

# Install operator
helm install vitistack-operator vitistack/vitistack-operator \
  --namespace vitistack \
  --create-namespace \
  --set config.logLevel=info \
  --set service.port=9991
```

#### Upgrade to latest version

```bash
helm install vitistack-operator vitistack/vitistack-operator \
  --namespace vitistack \
  --create-namespace \
  --reuse-values
```

#### Direct Deployment

```bash
# Build and run locally
go run cmd/vitistack-operator/main.go

# Build container image
CGO_ENABLED=0 go build -o dist/vitistack-operator \
  -ldflags '-w -extldflags "-static"' \
  cmd/vitistack-operator/main.go
docker build -t vitistack-operator:latest .
```

## Troubleshooting Reference

### Common Issues

| Issue                         | Symptom                                 | Resolution                                         |
| ----------------------------- | --------------------------------------- | -------------------------------------------------- |
| Operator connectivity failure | 503 errors from `/health/operators`     | Verify operator endpoints and network connectivity |
| Database connection timeout   | 500 errors, database health check fails | Check database connectivity and credentials        |
| High memory usage             | OOM kills, performance degradation      | Tune cache settings and connection pools           |
| Cache performance issues      | Slow API responses                      | Verify Redis connectivity and tune cache TTL       |

### Debug Commands

**Health Status Check**:

```bash
kubectl exec -n vitistack-system deployment/vitistack-operator -- \
  curl localhost:9991/health
```

**Operator Connectivity**:

```bash
kubectl exec -n vitistack-system deployment/vitistack-operator -- \
  curl localhost:9991/health/operators
```

**View Logs**:

```bash
kubectl logs -n vitistack-system deployment/vitistack-operator -f
```

**Metrics Inspection**:

```bash
kubectl exec -n vitistack-system deployment/vitistack-operator -- \
  curl localhost:9991/metrics
```

### Performance Tuning

#### Database Optimization

| Parameter            | Recommended Value  | Description                      |
| -------------------- | ------------------ | -------------------------------- |
| `db.maxOpenConns`    | CPU cores × 4      | Balance concurrency vs resources |
| `db.maxIdleConns`    | `maxOpenConns / 5` | Reduce idle connection overhead  |
| `db.connMaxLifetime` | 300s               | Prevent stale connections        |

#### Cache Optimization

| Parameter                | Recommended Value | Description                         |
| ------------------------ | ----------------- | ----------------------------------- |
| `cache.redis.poolSize`   | 20                | Handle concurrent requests          |
| `cache.ttl`              | 300s              | Balance freshness vs performance    |
| `cache.redis.maxRetries` | 3                 | Resilience without excessive delays |

This reference documentation provides comprehensive technical details for system administrators and developers working with the Vitistack Operator, assuming familiarity with Kubernetes, REST APIs, and microservice architecture patterns.
