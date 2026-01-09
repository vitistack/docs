# Install Kea DHCP and operator

You need a instance of Kea DHCP, please read this doc for installation and configuration: https://kea.readthedocs.io/en/stable

## Install Kea-operator

```bash
helm registry login ghcr.io
helm install vitistack-kea-operator oci://ghcr.io/vitistack/helm/kea-operator \
  --namespace vitistack \
  --create-namespace
```

## Upgrade to latest version

```bash
helm install vitistack-kea-operator oci://ghcr.io/vitistack/helm/kea-operator \
  --namespace vitistack \
  --create-namespace \
  --reuse-values
```

Values.yaml from helm chart

```yaml
# Default values for kea-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image:
  repository: ghcr.io/vitistack/kea-operator
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
  port: 80

# This block is for setting up the ingress for more information can be found here: https://kubernetes.io/docs/concepts/services-networking/ingress/
ingress:
  enabled: false
  className: ""
  annotations:
    {}
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
    port: 9995
  initialDelaySeconds: 15
  periodSeconds: 20
readinessProbe:
  httpGet:
    path: /readyz
    port: 9995
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

# KEA DHCP server configuration
kea:
  # Primary KEA server URL (e.g., https://kea-dhcp.example.com:8000)
  url: ""
  # Secondary KEA server URL for HA failover (optional)
  secondaryUrl: ""
  # KEA server port (used if url doesn't include port)
  port: "8000"
  # Timeout in seconds for KEA API requests
  timeoutSeconds: "10"
  # Disable HTTP keep-alive connections
  disableKeepalives: "true"
  # Comma-separated list of required client classes for pools
  requireClientClasses: "biosclients,ueficlients,ipxeclients"

  # Basic authentication credentials
  # These should be overridden in your ArgoCD app or values override
  auth:
    username: ""
    password: ""
    # Reference to an existing secret containing credentials
    # If set, username/password above are ignored
    existingSecret: ""
    # Key in the secret for username
    usernameKey: "username"
    # Key in the secret for password
    passwordKey: "password"

  # TLS configuration
  tls:
    enabled: "false"
    insecure: "false"
    serverName: ""
    # Path to CA certificate file (mounted via volumes)
    caFile: ""
    # Path to client certificate file (for mTLS)
    certFile: ""
    # Path to client key file (for mTLS)
    keyFile: ""
    # Reference to an existing secret containing TLS certificates
    secretName: ""
    secretNamespace: ""

# Logging configuration
logging:
  level: "info"
  jsonLogging: "true"
  colorize: "false"
  addCaller: "true"
  disableStacktrace: "false"
  unescapeMultiline: "false"

# Development mode
development: "false"
```
