# Install Vitistack operator

The vitistack operator handles the vitistack crd object. The operator fetches information and adds it to the vitistack crd object, so other solutions could show or integrate with the vitistack. One example is ROR (Release Operate Report) found here: https://github.com/norskHelsenett/ror

Install the vitistack operator by:

```bash
helm install vitistack-operator oci://ghcr.io/vitistack/helm/vitistack-operator
```

Values.yaml from helm chart:

```yaml
# Default values for vitistack-operator.

crds:
  install: true

replicaCount: 1

image:
  repository: ghcr.io/vitistack/vitistack-operator
  pullPolicy: IfNotPresent
  tag: ""

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  automount: true
  annotations: {}
  name: ""

rbac:
  create: true

vitistackCrdName: "vitistack"
configMapName: "vitistack-config"
development: false
name: "test-stack"
description: "A test vitistack deployment"
region: "central"
country: "no"
zone: "az1"
infrastructure: "test"

logging:
  jsonLogging: true
  level: "info"
  colorize: false
  addCaller: true
  disableStacktrace: false
  unescapeMultiline: false

podAnnotations: {}
podLabels: {}

podSecurityContext:
  runAsNonRoot: true
  fsGroup: 2000
  runAsUser: 1001
  runAsGroup: 1001
  seccompProfile:
    type: RuntimeDefault

securityContext:
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false

service:
  type: NodePort
  port: 9991

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls: []

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

livenessProbe:
  httpGet:
    path: /health
    port: 9991
readinessProbe:
  httpGet:
    path: /health
    port: 9991

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
