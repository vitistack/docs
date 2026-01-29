# Install Kubevirt and operator

## Kubevirt in kubernetes

If you are running one or more own kubevirt clusters, you have to install the vitistack crds into the kubevirt cluster(s) too: [install vitistack crds](../infrastructure/vitistack-crds.md)

(docs with kind: https://kubevirt.io/quickstart_kind)

```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

echo $VERSION
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
```

## Install the CRDS

```bash
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml"
```

### Verify kubevirt components

```bash
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
```

Check the components

```bash
kubectl get all -n kubevirt
```

Wait and see that the Kube Virt CRD object (`kubevirt`) has `Phase`: `Deployed`

```bash
$ kubectl get kubevirts.kubevirt.io -n kubevirt
NAME       AGE     PHASE
kubevirt   4m24s   Deployed
```

### Virtualized environment

If running in a virtualized environment

If the kind cluster runs on a virtual machine consider enabling nested virtualization. Follow the instructions described here. If for any reason nested virtualization cannot be enabled do enable KubeVirt emulation as follows:

```bash
kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
```

### Virtctl

KubeVirt provides an additional binary called virtctl for quick access to the serial and graphical ports of a VM and also handle start/stop operations.

Install
virtctl can be retrieved from the release page of the KubeVirt github page.

```bash
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
echo ${ARCH}
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
sudo install -m 0755 virtctl /usr/local/bin
```

### Containerized Data Importer (CDI)

Notice, this is an experimental feature from Kubevirt

Docs: https://kubevirt.io/labs/kubernetes/lab2.html

"You can experiment with this lab online at Killercoda
In this lab, you will learn how to use Containerized Data Importer (CDI) to import Virtual Machine images for use with Kubevirt. CDI simplifies the process of importing data from various sources into Kubernetes Persistent Volumes, making it easier to use that data within your virtual machines.

CDI introduces DataVolumes, custom resources meant to be used as abstractions of PVCs. A custom controller watches for DataVolumes and handles the creation of a target PVC with all the spec and annotations required for importing the data. Depending on the type of source, other specific CDI controller will start the import process and create a raw image named disk.img with the desired content into the target PVC."

To install:

```bash
export VERSION=$(basename $(curl -s -w %{redirect_url} https://github.com/kubevirt/containerized-data-importer/releases/latest))
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml
```

## Multus

The Vitistack uses Multus together with Kubevirt, so please install multus.

Docs: https://github.com/k8snetworkplumbingwg/multus-cni and https://github.com/k8snetworkplumbingwg/multus-cni/blob/master/docs/quickstart.md

## Kubevirt Operator

### How create a KubeVirtConfig

Create a k8s secret from file content (kubeconfig file to the kubevirt cluster)

```bash
kubectl create secret generic kubevirt-provider --from-file=kubeconfig=<path to kubevirt kubeconfig file>`
```

Note, if you are using the supervisor cluster as the kubevirt cluster, use the kubernetes service address in the kubeconfig

```yaml
apiVersion: v1
clusters:
- cluster:
    server: https://kubernetes.default.svc:443
....
```

### Create the KubevirtConfig

Create and modify this yaml

Filename: kubevirtconfig.yaml

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubevirtConfig
metadata:
  name: kubevirt-provider
spec:
  name: kubevirt-provider
  secretNamespace: default
  kubeconfigSecretRef: kubevirt-provider
```

And then:

`kubectl apply -f kubevirtconfig.yaml`

### Install the Kubevirt-operator

```bash
helm registry login ghcr.io
helm install vitistack-kubevirt-operator oci://ghcr.io/vitistack/helm/kubevirt-operator \
  --namespace vitistack \
  --create-namespace
```

### Upgrade to latest version

```bash
helm install vitistack-kubevirt-operator oci://ghcr.io/vitistack/helm/kubevirt-operator \
  --namespace vitistack \
  --create-namespace \
  --reuse-values
```

### Kubevirt-operator helm values

Values.yaml from Helm chart:

```yaml
# Default values for kubevirt-operator.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# This will set the replicaset count more information can be found here: https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/
replicaCount: 1

# This sets the container image more information can be found here: https://kubernetes.io/docs/concepts/containers/images/
image:
  repository: ghcr.io/vitistack/viti-kubevirt-operator
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
  fsGroup: 2000
  runAsGroup: 2000
  runAsUser: 1000
  runAsNonRoot: true

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  runAsGroup: 2000
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
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi

# This is to setup the liveness and readiness probes more information can be found here: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
livenessProbe:
  httpGet:
    path: /healthz
    port: 9992
  initialDelaySeconds: 15
  periodSeconds: 20
readinessProbe:
  httpGet:
    path: /readyz
    port: 9992
  initialDelaySeconds: 5
  periodSeconds: 10

# This section is for setting up autoscaling more information can be found here: https://kubernetes.io/docs/concepts/workloads/autoscaling/
autoscaling:
  enabled: true
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

# Operator configuration
# These settings are passed as environment variables to the operator

# Namespace the operator manages (uses Release.Namespace if empty)
namespace: ""
# CPU model for VMs: "host-model" (default for x86), "host-passthrough" (required for ARM)
cpuModel: ""
# CNI version for NetworkAttachmentDefinitions
nadCniVersion: "1.0.0"
# Where to fetch public IPs from: "vmi" (default, from KubeVirt VMI) or "networkconfiguration"
ipSource: "vmi"
# Enable Containerized Data Importer (CDI) support
kubevirtSupportCDI: true
# Name of the MachineProvider
machineProviderName: "kubevirt-provider"
# PVC volume mode: "Block" (default) or "Filesystem"
pvcVolumeMode: "Block"
# PVC access mode for DataVolumes: "ReadWriteMany" (default), "ReadWriteOnce", "ReadOnlyMany"
# Use "ReadWriteOnce" for local-path, Ceph RBD; "ReadWriteMany" for CephFS, NFS
pvcAccessMode: "ReadWriteMany"
# Storage class name for PVCs. If empty (default), uses the cluster's default storage class.
# Set this to a specific storage class name to override the default (e.g., "local-path", "ceph-rbd")
storageClassName: ""
# Optional prefix for VM names
vmNamePrefix: ""
# Vitistack name (optional)
vitistackName: "vitistack"

# Logging configuration
logging:
  # Log level: debug, info, warn, error
  level: "info"
  # Output logs as JSON
  json: true
  # Add caller information to logs
  addCaller: false
  # Disable stacktrace in logs
  disableStacktrace: true
  # Unescape multiline log messages
  unescapedMultiline: false
  # Colorize log lines (for development)
  colorizeLine: false

# Leader election for HA deployments
leaderElection:
  enabled: true

# Metrics configuration
metrics:
  # Enable metrics endpoint
  enabled: true
  # Metrics bind address (use ":8443" for HTTPS, ":8080" for HTTP, "0" to disable)
  bindAddress: ":8443"
  # Serve metrics over HTTPS
  secure: true

# Health probe configuration
healthProbe:
  # Health probe bind address
  bindAddress: ":9992"

# RBAC configuration
rbac:
  # Create ClusterRole and ClusterRoleBinding
  create: true
```
