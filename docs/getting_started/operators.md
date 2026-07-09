# Setup Vitistack operators

Components:

- CRDS
    - webhook conversion
- Vitistack-operator
- Static-ip-operator
- Manual-ip-provisioning-operator
- Kubevirt-operator
- Talos-operator

## Cluster prerequisites

Cert manager helm installation if not NHN-tooling is installed:
```bash
helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.20.2 \
  --set crds.enabled=true
```

## Helm Installation

The following sections describe manual installation of each component using Helm CLI.

The objects of Vitistack

- Control Plane Virtial Shared IP
- Etcd Backup
- Kubernetes Cluster
- Kubernetes Provider
- Kubevirt Config
- Machine
- Machine Class
- Machine Provider
- Network Configuration
- Network Namespace
- Proxmox Config
- Vitistack

## Create the vitistack namespace

`kubectl create namespace vitistack`

## CRDS:

### Helm install

```bash
helm install vitistack-crds oci://ghcr.io/vitistack/helm/crds \
  --namespace vitistack \
  --create-namespace \
  --version 1.0.0-alpha07
```

Chart default values:
https://github.com/vitistack/common/blob/main/charts/vitistack-crds/values.yaml

### Helm upgrade

```bash
helm upgrade --install vitistack-crds oci://ghcr.io/vitistack/helm/crds -n vitistack --reset-then-reuse-values --version 1.0.0-alpha07
```

## Machineclasses:

### Prerequisites

create machineclasses in a machineclasses folder, e.g.:


```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: small
spec:
  displayName: Small
  description: Small instance with 4 cores and 8Gi memory
  enabled: true
  default: true
  category: Standard
  cpu:
    cores: 4
    sockets: 1
    threads: 1
  memory:
    quantity: 8Gi
  machineProviders: []
```

```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: medium
spec:
  displayName: Medium
  description: Medium instance with 4 cores and 16Gi memory
  enabled: true
  default: true
  category: Standard
  cpu:
    cores: 4
    sockets: 1
    threads: 1
  memory:
    quantity: 16Gi
  machineProviders: []
```

```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: large
spec:
  displayName: Large
  description: Large instance with 8 cores and 24Gi memory
  enabled: true
  default: true
  category: Standard
  cpu:
    cores: 8
    sockets: 1
    threads: 1
  memory:
    quantity: 24Gi
  machineProviders: []
```

Apply machineclasses

```bash
kubectl apply -f <folder with all machine classes>
```


## Vitistack-operator:

### Initial install

```bash
helm install vitistack-operator oci://ghcr.io/vitistack/helm/vitistack-operator -n vitistack \
  --create-namespace \
  --set name="no-central-az1" \
  --set description="Vitistack Availability Zone 1" \
  --set region="central" \
  --set country="no" \
  --set zone="az1" \
  --set infrastructure="test"
```

Chart default values: https://github.com/vitistack/vitistack-operator/blob/main/charts/vitistack-operator/values.yaml

### Upgrade

```bash
helm upgrade --install vitistack-operator oci://ghcr.io/vitistack/helm/vitistack-operator -n vitistack --reset-then-reuse-values
```

## Static-ip-operator:

Handles static IP allocation for NetworkNamespaces with `spec.ipAllocation.type: static`.
Chart package: https://github.com/vitistack/static-ip-operator/pkgs/container/helm%2Fstatic-ip-operator

### Initial install

```bash
helm install vitistack-static-ip-operator oci://ghcr.io/vitistack/helm/static-ip-operator \
  --create-namespace \
  --namespace vitistack \
  --version 0.1.0-alpha06

```

Chart default values: https://github.com/vitistack/static-ip-operator/blob/main/charts/static-ip-operator/values.yaml

### Upgrade

```bash
helm upgrade --install vitistack-static-ip-operator oci://ghcr.io/vitistack/helm/static-ip-operator -n vitistack --reset-then-reuse-values --version 0.1.0-alpha06
```


## Manuel-ip-provisioning-operator:

### Initial install

```bash
helm install vitistack-manual-ip-provisioning-operator oci://ghcr.io/vitistack/helm/manual-ip-provisioning-operator \
  --namespace vitistack \
  --version 0.1.0-alpha02
```

Chart default values: https://github.com/vitistack/nms-operator/blob/main/charts/nms-operator/values.yaml

### Upgrade

```bash
helm upgrade --install vitistack-manual-ip-provisioning-operator oci://ghcr.io/vitistack/helm/manual-ip-provisioning-operator -n vitistack --reset-then-reuse-values --version 0.1.0-alpha02
```


## KubeVirt-operator:

### Prerequisites:

- kubevirtconfig
- **Static-IP node networking** on every KubeVirt node:
  - a Linux bridge named `br0` with an uplink to the L2 segment the static range
    lives on (the VLAN/segment from your `NetworkNamespace`),
  - **Multus** installed and not disabled by the primary CNI (e.g. Cilium: set
    `cni.exclusive=false`). kubevirt-operator creates a `NetworkAttachmentDefinition`
    (`bridge-br0`, or `vlan<id>` when `vlanId` is set) and attaches each VM through it.

> You do **not** create a MachineProvider by hand — kubevirt-operator registers it
> automatically from the matching `KubevirtConfig` on startup.

```bash
kubectl create secret generic kubevirt-provider -n vitistack --from-file=kubeconfig=<path to kubevirt kubeconfig file>`
```

Filename: `kubevirtconfig.yaml`

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubevirtConfig
metadata:
  name: kubevirt-provider
spec:
  name: kubevirt-provider
  secretNamespace: vitistack
  kubeconfigSecretRef: kubevirt-provider
```

```bash
kubectl apply -f kubevirtconfig.yaml -n vitistack
```

### Initial install

```bash
helm install vitistack-kubevirt-operator oci://ghcr.io/vitistack/helm/kubevirt-operator -n vitistack \
  --create-namespace \
  --set storageClassName=longhorn \
  --set storageClassNameIso=longhorn \
  --set ipSource=networkconfiguration \
  --version 0.1.0-alpha04
```

Chart default values: https://github.com/vitistack/kubevirt-operator/blob/main/charts/kubevirt-operator/values.yaml

### Upgrade

```bash
helm upgrade --install vitistack-kubevirt-operator oci://ghcr.io/vitistack/helm/kubevirt-operator -n vitistack --reset-then-reuse-values --version 0.1.0-alpha04
```

## Talos-operator

You could add an configmap talos config template for you customization, other CNI, installing extra manifests, etc

#### configmap

Filename: `talos-tenant-config.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: talos-tenant-config
data:
  config.yaml: |
    ---
    machine:
      kubelet:
        extraArgs:
          rotate-server-certificates: true
      features:
        hostDNS:
          enabled: true
          forwardKubeDNSToHost: true
        kubePrism:
          enabled: true
          port: 7445
    cluster:
      apiServer:
        admissionControl:
          - name: PodSecurity
            configuration:
              exemptions:
                namespaces:
                  - argocd
      network:
        cni:
          name: flannel
        podSubnets:
          - 100.124.0.0/16
          - 2001:db8:124::/56
        serviceSubnets:
          - 100.120.0.0/16
          - 2001:db8:120::/112
      proxy:
        disabled: true
      discovery:
        enabled: false
      extraManifests:
        - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
        - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    ---
    apiVersion: v1alpha1
    kind: LinkAliasConfig
    name: net0 # Alias for the link.
    # Selector uses CEL expression to match the physical link by its MAC address.
    # #MACADDRESS# is replaced per-node with the actual MAC from Machine.Status.NetworkInterfaces.
    selector:
      #  match: mac(link.permanent_addr) == "#MACADDRESS#"
      match: "true"
    ---
    apiVersion: v1alpha1
    kind: LinkConfig
    name: net0 # Name of the link (interface).
    mtu: 1500
    ---
    apiVersion: v1alpha1
    kind: DHCPv4Config
    name: net0
    clientIdentifier: mac
```

`kubectl apply -f talos-tenant-configmap.yaml -n vitistack`

### Initial install

```bash
helm install vitistack-talos-operator oci://ghcr.io/vitistack/helm/talos-operator -n vitistack \
  --create-namespace \
  --set tenant.configMapName=talos-tenant-config \
  --set tenant.configMapNamespace=vitistack \
  --set bootImageSource=bootimage \
  --set endpointMode=talosvip \
  --set loadBalancerProvider=static-ip-operator \
  --version 0.2.0-alpha01
```

Chart default values: https://github.com/vitistack/talos-operator/blob/main/charts/talos-operator/values.yaml

### Upgrade version:

```bash
helm upgrade --install vitistack-talos-operator oci://ghcr.io/vitistack/helm/talos-operator -n vitistack --version 0.2.0-alpha01 --reset-then-reuse-values
```
