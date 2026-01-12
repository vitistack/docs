# Install AKS Operator

To run and install the aks-operator, you need to use or create a service principal in Azure.

## Login to Azure via azurecli

(Install azurecli: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

```bash
az login
```

Then pick the subscription you have access to, or select the relevant subscription if you have access to many subscriptions

## Get AppId and TentantId from existing Service Principal

```bash
az ad sp list --display-name "vitistack-sp" --query "[].{appId:appId, tenant:appOwnerOrganizationId}"
[
  {
    "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
]
```

:exclamation: If you want to create a new secret (only if you have access to this):

```bash
az ad sp credential reset --id "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" --query "{appId:appId, password:password, tenant:tenant}"
```

Output:

```bash
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

## Create Service Principal in Azure

```bash
# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "vitistack-sp" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID
```

Output

```json
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "vitistack-sp",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```

## Environment Variables

| Output Field   | Environment Variable    | Description                      |
| -------------- | ----------------------- | -------------------------------- |
| `appId`        | `AZURE_CLIENT_ID`       | Application (client) ID          |
| `password`     | `AZURE_CLIENT_SECRET`   | Client secret (shown only once!) |
| `tenant`       | `AZURE_TENANT_ID`       | Azure AD tenant ID               |
| (from account) | `AZURE_SUBSCRIPTION_ID` | Subscription ID                  |

## Log into ghcr.io to fetch oci helm package

```bash
helm registry login ghcr.io
```

## Create kubernetes secret for the helm chart

Filename: vitistack-aks-credentials.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: vitistack-aks-credentials
type: Opaque
data:
  subscriptionId: <BASE64_SUBSCRIPTION_ID>
  tenantId: <BASE64_TENANT_ID>
  clientId: <BASE64_CLIENT_ID>
  clientSecret: <BASE64_CLIENT_SECRET>
```

```bash
kubectl apply -f vitistack-aks-credentials.yaml -n vitistack
```

or via terminal:

```bash
kubectl create secret generic vitistack-aks-credentials \
  --from-literal=AZURE_SUBSCRIPTION_ID=<your azure subscription id> \
  --from-literal=AZURE_TENANT_ID=<your tenant id here> \
  --from-literal=AZURE_CLIENT_ID=<your client id here> \
  --from-literal=AZURE_CLIENT_SECRET='<you secret here>' \
  -n vitistack
```

## Install the operator

```bash
helm install vitistack-aks-operator oci://ghcr.io/vitistack/helm/aks-operator \
  --namespace vitistack \
  --set azure.existingSecret=vitistack-aks-credentials \
  --create-namespace
```

### Upgrade the operator to latest version

```bash
helm install vitistack-aks-operator oci://ghcr.io/vitistack/helm/aks-operator \
  --namespace vitistack \
  --create-namespace \
  --reuse-values
```

# Default values for the helm chart

Values.yaml from Helm chart

```yaml
# Default values for aks-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image:
  repository: ghcr.io/vitistack/viti-aks-operator
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

# RBAC configuration
rbac:
  # Specifies whether RBAC resources should be created.
  create: true

# Leader election configuration
leaderElection:
  # Enable leader election for controller manager.
  # Enabling this will ensure there is only one active controller manager.
  enabled: false

# Azure credentials configuration
# You can either set the credentials directly or use an existing secret
azure:
  # Use an existing secret containing Azure credentials
  # The secret should contain: AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET
  existingSecret: ""
  # Or set credentials directly (not recommended for production)
  subscriptionId: ""
  tenantId: ""
  clientId: ""
  clientSecret: ""

# Additional environment variables to set on the container
# Example:
# env:
#   - name: LOG_LEVEL
#     value: "debug"
#   - name: MY_VAR
#     valueFrom:
#       secretKeyRef:
#         name: my-secret
#         key: my-key
env: []

# Additional envFrom sources to set on the container
# Example:
# envFrom:
#   - secretRef:
#       name: my-secret
#   - configMapRef:
#       name: my-configmap
envFrom: []

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
  tls:
    []
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
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
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
readinessProbe:
  httpGet:
    path: /readyz
    port: 9995

# This section is for setting up autoscaling more information can be found here: https://kubernetes.io/docs/concepts/workloads/autoscaling/
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

# Additional volumes on the output Deployment definition.
volumes:
  []
  # - name: foo
  #   secret:
  #     secretName: mysecret
  #     optional: false

# Additional volumeMounts on the output Deployment definition.
volumeMounts:
  []
  # - name: foo
  #   mountPath: "/etc/foo"
  #   readOnly: true

nodeSelector: {}

tolerations: []

affinity: {}
```
