# Install Proxmox and operator

You need one or more Proxmox instances.

To install proxmox, follow this installation guide:

- https://proxmox.com/en/products/proxmox-virtual-environment/get-started
- https://pve.proxmox.com/pve-docs/chapter-pve-installation.html

## Install the Proxmox operator

Setup the kubernetes secret for Proxmox:

Existing secret containing Proxmox credentials
The secret should contain: PROXMOX_ENDPOINT, PROXMOX_USERNAME, PROXMOX_PASSWORD
or PROXMOX_TOKEN_ID, PROXMOX_TOKEN_SECRET

### Create the secret with:

```bash
kubectl create secret generic proxmox-credentials \
    --from-literal=PROXMOX_ENDPOINT=https://proxmox.example.com:8006/api2/json \
    --from-literal=PROXMOX_USERNAME=root@pam \
    --from-literal=PROXMOX_PASSWORD=yourpassword
```

### Or for token auth:

```bash
kubectl create secret generic proxmox-credentials \
    --from-literal=PROXMOX_ENDPOINT=https://proxmox.example.com:8006/api2/json \
    --from-literal=PROXMOX_TOKEN_ID=root@pam!mytoken \
    --from-literal=PROXMOX_TOKEN_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### or with yaml

Filename: proxmox-credentials.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: proxmox-credentials
type: Opaque
stringData:
  PROXMOX_ENDPOINT: "https://proxmox.example.com:8006/api2/json"
  # Use username/password auth:
  PROXMOX_USERNAME: "root@pam"
  PROXMOX_PASSWORD: "yourpassword"
  # OR use token auth (comment out username/password above):
  # PROXMOX_TOKEN_ID: "root@pam!mytoken"
  # PROXMOX_TOKEN_SECRET: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Apply with

```bash
kubectl apply -f proxmox-credentials.yaml
```

## Proxmox Operator

```bash
helm registry login ghcr.io
helm install vitistack-proxmox-operator oci://ghcr.io/vitistack/helm/proxmox-operator \
  --namespace vitistack \
  --create-namespace
```

## Upgrade to latest version

```bash
helm install vitistack-proxmox-operator oci://ghcr.io/vitistack/helm/proxmox-operator \
  --namespace vitistack \
  --create-namespace \
  --reuse-values
```

### Operator helm values

Values.yaml from helm chart:

```yaml
# Default values for proxmox-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image:
  repository: ghcr.io/vitistack/viti-proxmox-operator
  # This sets the pull policy for images.
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

# This is for the secrets for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imagePullSecrets: []
# This is to override the chart name.
nameOverride: ""
fullnameOverride: ""

# This section builds out the service account more information can be found here: https://kubernetes.io/docs/concepts/security/service-accounts/
serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Automatically mount a ServiceAccount's API credentials?
  automount: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: ""

# This is for setting Kubernetes Annotations to a Pod.
# For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
podAnnotations: {}
# This is for setting Kubernetes Labels to a Pod.
# For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
podLabels: {}

podSecurityContext:
  runAsNonRoot: true
  fsGroup: 65532

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 65532
  runAsGroup: 65532
  seccompProfile:
    type: RuntimeDefault

# This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/
service:
  # This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  type: ClusterIP
  # This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports
  port: 8081

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

# This is to setup the liveness and readiness probes more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
livenessProbe:
  httpGet:
    path: /healthz
    port: 8081
  initialDelaySeconds: 15
  periodSeconds: 20
readinessProbe:
  httpGet:
    path: /readyz
    port: 8081
  initialDelaySeconds: 5
  periodSeconds: 10

# This section is for setting up autoscaling more information can be found here: https://kubernetes.io/docs/concepts/workloads/autoscaling/
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

# Additional volumes on the output Deployment definition.
volumes: []
# - name: foo
#   secret:
#     secretName: mysecret
#     optional: false

# Additional volumeMounts on the output Deployment definition.
volumeMounts: []
# - name: foo
#   mountPath: "/etc/foo"
#   readOnly: true

nodeSelector: {}

tolerations: []

affinity: {}

# Existing secret containing Proxmox credentials
# The secret should contain: PROXMOX_ENDPOINT, PROXMOX_USERNAME, PROXMOX_PASSWORD
# or PROXMOX_TOKEN_ID, PROXMOX_TOKEN_SECRET
# Create the secret with:
#   kubectl create secret generic proxmox-credentials \
#     --from-literal=PROXMOX_ENDPOINT=https://proxmox.example.com:8006/api2/json \
#     --from-literal=PROXMOX_USERNAME=root@pam \
#     --from-literal=PROXMOX_PASSWORD=yourpassword
# Or for token auth:
#   kubectl create secret generic proxmox-credentials \
#     --from-literal=PROXMOX_ENDPOINT=https://proxmox.example.com:8006/api2/json \
#     --from-literal=PROXMOX_TOKEN_ID=root@pam!mytoken \
#     --from-literal=PROXMOX_TOKEN_SECRET=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
existingSecret: "proxmox-credentials"

# Logging configuration
logging:
  # Log level (debug, info, warn, error)
  level: "info"
  # Output logs in JSON format
  json: true

# Proxmox connection settings (required)
proxmox:
  # Proxmox API endpoint URL (e.g., https://proxmox.example.com:8006/api2/json)
  endpoint: ""
  # Authentication - use either username/password OR token
  # Username authentication (e.g., root@pam)
  username: ""
  password: ""
  # Token authentication (alternative to username/password)
  tokenId: ""
  tokenSecret: ""
  # Skip TLS certificate verification (not recommended for production)
  insecureTLS: false

# VM management settings
vm:
  # Starting VM ID for new machines
  idStart: 2000
  # Node selection strategy: first, random, round-robin
  nodeSelection: "first"
  # Comma-separated list of allowed nodes (empty means all nodes)
  allowedNodes: ""
  # Default storage pool for VM disks
  defaultStorage: "local-lvm"
  # Default network bridge for VMs
  defaultNetwork: "vmbr0"
  # Network model for VM interfaces (virtio, e1000, e1000e, rtl8139, vmxnet3)
  # virtio = VirtIO paravirtualized (best performance)
  networkModel: "virtio"
  # Default VLAN tag for VM network interfaces (0 = no VLAN tagging)
  defaultVlan: 0
  # Default MTU for VM network interfaces (0 = use Proxmox default of 1500)
  # Common values: 1500 (standard), 9000 (jumbo frames)
  defaultMtu: 0
  # Default CPU type (e.g., host, kvm64, x86-64-v2-AES)
  defaultCpuType: "x86-64-v2-AES"
  # Enable NUMA for VMs
  enableNuma: true
  # SCSI controller type
  scsiController: "virtio-scsi-single"
  # Enable QEMU Guest Agent (required for network status)
  enableQemuAgent: true
  # Start VM immediately after creation
  startOnCreate: true

# Network configuration settings
network:
  # IP address source for VMs:
  # - "proxmox": Get IP from Proxmox/QEMU Guest Agent (default)
  # - "networkconfiguration": Get IP from NetworkConfiguration CRD (Kea DHCP reservation)
  ipSource: "proxmox"
  # Second octet for MAC address generation (format: 02:XX:RR:RR:RR:RR where XX is this value)
  # Default is 24 (0x18 in hex), resulting in MAC addresses like 02:18:XX:XX:XX:XX
  macSet: "24"
```
