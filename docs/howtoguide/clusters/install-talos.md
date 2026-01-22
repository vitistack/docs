# Install Talos Operator

```bash
helm registry login ghcr.io
helm install vitistack-talos-operator oci://ghcr.io/vitistack/helm/talos-operator \
  --namespace vitistack \
  --create-namespace
```

## Upgrade to latest version

```bash
helm install vitistack-talos-operator oci://ghcr.io/vitistack/helm/talos-operator \
  --namespace vitistack \
  --create-namespace \
  --reuse-values
```

Values.yaml from Helm chart

```yaml
# Default values for talos-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image:
  repository: ghcr.io/vitistack/viti-talos-operator
  # This sets the pull policy for images.
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

# This is for the secrets for pulling an image from a private repository more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imagePullSecrets: []
# This is to override the chart name.
nameOverride: ""
fullnameOverride: ""

# Talos Operator Configuration
# Endpoint mode determines how the operator configures control plane endpoints.
# Valid values:
# - "none": Use control plane IPs directly (no load balancing)
# - "networkconfiguration": Use ControlPlaneVirtualSharedIP from NetworkNamespace (default)
# - "talosvip": Use Talos built-in VIP (requires additional Talos configuration)
# - "custom": Use user-provided endpoint addresses
endpointMode: "networkconfiguration"

# Custom endpoint addresses (only used when endpointMode is "custom")
# Can be a single IP/hostname or comma-separated list
customEndpoint: ""

# Boot image source configuration
# Valid values: "pxe", "bootimage"
# Default: "pxe" (uses PXE boot for machine provisioning)
bootImageSource: "pxe"

# Boot image URL (only used when bootImageSource is "bootimage")
bootImage: "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.12.2/metal-amd64.iso"

# Log configuration
logLevel: "info"
logJson: true

# Secret prefix for cluster secrets
secretPrefix: ""

# Vitistack name
vitistackName: "vitistack"

# Kubernetes provider name
kubernetesProviderName: "talos-provider"

# Tenant configuration
tenant:
  configMapName: "talos-tenant-config"
  configMapNamespace: "default"
  configMapDataKey: "config.yaml"

# Talos configuration
talos:
  version: "v1.12.2"
  defaultKubernetesVersion: "1.35.0"
  predictableNetworkNames: true
  vmInstallImage:
    kubevirt: "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.2"
    default: "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.2"

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
  fsGroup: 2000

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  seccompProfile:
    type: RuntimeDefault

# This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/
service:
  # This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  type: ClusterIP
  # This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports
  port: 9993

# This block is for setting up the ingress for more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/
ingress:
  enabled: false
  className: ""
  annotations: {}
    # kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

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
    port: 9993
readinessProbe:
  httpGet:
    path: /readyz
    port: 9993

# This section is for setting up autoscaling more information can be found here: https://kubernetes.io/docs/concepts/workloads/autoscaling/
# Note: Operators typically run as single instances with leader election enabled
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 3
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

# Extra environment variables to add to the container
# Example:
# extraEnv:
#   - name: MY_VAR
#     value: "my-value"
extraEnv: []

# Environment variables from Secrets or ConfigMaps
# Use this for sensitive data - reference existing secrets/configmaps
# Example:
# envFrom:
#   - secretRef:
#       name: my-secret
#   - configMapRef:
#       name: my-configmap
envFrom: []
```
