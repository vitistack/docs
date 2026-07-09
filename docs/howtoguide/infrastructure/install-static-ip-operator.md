# Install Static IP operator

## Install

```bash
helm install vitistack-static-ip-operator oci://ghcr.io/vitistack/helm/static-ip-operator \
  --create-namespace \
  --namespace vitistack \
  --version 0.1.0-alpha06
```

## Upgrade to latest version

```bash
helm upgrade --install vitistack-static-ip-operator oci://ghcr.io/vitistack/helm/static-ip-operator -n vitistack --reset-then-reuse-values --version 0.1.0-alpha06

```

## Uninstall 

```bash
helm uninstall -n vitistack vitistack-static-ip-operator
```

Values.yaml from helm chart

```yaml
# Default values for static-ip-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# Maximum number of objects reconciled in parallel per controller (env var
# MAX_CONCURRENT_RECONCILES). The workqueue serializes by object key, so this
# only parallelizes across distinct objects, never the same one. Defaults to 5.
maxConcurrentReconciles: 5

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image:
  repository: ghcr.io/vitistack/viti-static-ip-operator
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
  # Specifies whether a service account should be created.
  create: true
  # Automatically mount a ServiceAccount's API credentials?
  automount: true
  # Annotations to add to the service account.
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template.
  name: ""

# This is for setting Kubernetes Annotations to a Pod.
# For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
podAnnotations: {}
# This is for setting Kubernetes Labels to a Pod.
# For more information checkout: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
podLabels: {}

podSecurityContext:
  runAsUser: 1000
  runAsGroup: 1000
  # fsGroup: 2000

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

# This is for setting up a service more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/
# The service exposes the controller-runtime health probe endpoint on :8081.
service:
  # This sets the service type more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
  type: ClusterIP
  # This sets the ports more information can be found here: https://kubernetes.io/docs/concepts/services-networking/service/#field-spec-ports
  port: 8081

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
    # - secretName: chart-example-tls
    #   hosts:
    #     - chart-example.local

# -- Expose the service via gateway-api HTTPRoute
# Requires Gateway API resources and suitable controller installed within the cluster
# (see: https://gateway-api.sigs.k8s.io/guides/)
httpRoute:
  # HTTPRoute enabled.
  enabled: false
  # HTTPRoute annotations.
  annotations: {}
  # Which Gateways this Route is attached to.
  parentRefs:
  - name: gateway
    sectionName: http
    # namespace: default
  # Hostnames matching HTTP header.
  hostnames:
  - chart-example.local
  # List of rules and filters applied.
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /headers
  #   filters:
  #   - type: RequestHeaderModifier
  #     requestHeaderModifier:
  #       set:
  #       - name: My-Overwrite-Header
  #         value: this-is-the-only-value
  #       remove:
  #       - User-Agent
  # - matches:
  #   - path:
  #       type: PathPrefix
  #       value: /echo
  #     headers:
  #     - name: version
  #       value: v2

resources:
  limits:
    cpu: 2000m
    memory: 256Mi
  requests:
    cpu: 250m
    memory: 64Mi

# This is to setup the liveness and readiness probes more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
# The controller-runtime health server exposes /healthz and /readyz on port 8081 (named "health").
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

```
