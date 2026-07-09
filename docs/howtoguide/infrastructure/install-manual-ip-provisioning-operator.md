# Install Manual IP Provisioning operator

## Install

```bash
helm install vitistack-manual-ip-provisioning-operator oci://ghcr.io/vitistack/helm/manual-ip-provisioning-operator \
  --namespace vitistack \
  --version 0.1.0-alpha02
```

## Upgrade to latest version

```bash
helm upgrade --install vitistack-manual-ip-provisioning-operator oci://ghcr.io/vitistack/helm/manual-ip-provisioning-operator -n vitistack --reset-then-reuse-values --version 0.1.0-alpha02
```

## Uninstall 

```bash
helm uninstall -n vitistack vitistack-manual-ip-provisioning-operator
```

Values.yaml from helm chart

```yaml
# Default values for manual-ip-provisioning-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1

image:
  repository: ghcr.io/vitistack/viti-manual-ip-provisioning-operator
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

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

podAnnotations: {}
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

service:
  type: ClusterIP
  port: 9081

resources: {}
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

livenessProbe:
  httpGet:
    path: /healthz
    port: 9081
  initialDelaySeconds: 15
  periodSeconds: 20
readinessProbe:
  httpGet:
    path: /readyz
    port: 9081
  initialDelaySeconds: 5
  periodSeconds: 10

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

volumes: []
volumeMounts: []

nodeSelector: {}
tolerations: []
affinity: {}

```
