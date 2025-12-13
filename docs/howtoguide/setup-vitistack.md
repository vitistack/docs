# How to setup vitistack

## Prerequisites
First of all you need a Kubernetes cluster to run all the Vitistack operators.

### On prem
Create hardware nodes an install ex Talos, K0s or other kubernetes solutions

### Cloud
- Azure Kubernetes Service (AKS)
- Elastic Kubernetes Service (EKS)
- Scaleway
- Upcloud
- or others

### Locally
You could use Kind (https://kind.sigs.k8s.io/docs/user/quick-start/#installation) or Talosctl (https://docs.siderolabs.com/talos/v1.11/getting-started/talosctl) to install spin up a Kubernetes cluster locally.


## Visual cluster overview

![Vitistack cluster setup](../images/vitistack-setup.excalidraw.png "Vitistack cluster setup")

It is also possible that the supervisor cluster also has Kubevirt installed, so there is also support for only one cluster. But it is wise to spread out the risk onto multiple clusters, incause of errors.

## Install Vitistack CRDS

Using Helm (recommended)

First, login to GitHub Container Registry

Username: your GitHub username

Password: a Personal Access Token (PAT) with `read:packages` scope

Create a PAT at: https://github.com/settings/tokens/new?scopes=read:packages

```bash
helm registry login ghcr.io
helm install vitistack-crds oci://ghcr.io/vitistack/crds
```

Or using kubectl (no authentication required)

```bash
kubectl apply -f https://github.com/vitistack/common/releases/latest/download/crds.yaml
```

## Machine classes
These a example machine classes

### Small
filename: machineclass-small.yaml
```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: small
spec:
  displayName: Small
  description: Small instance with 2 cores and 8Gi memory
  enabled: true
  default: false
  category: Standard
  cpu:
    cores: 2
    sockets: 1
    threads: 1
  memory:
    quantity: 8Gi
  machineProviders: []
```

```bash
kubectl apply -f machineclass-small.yaml
```

### Medium
filename: machineclass-medium.yaml
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

```bash
kubectl apply -f machineclass-medium.yaml
```

### Large
filename: machineclass-large.yaml
```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: large
spec:
  displayName: Large
  description: Large instance with 4 cores and 32Gi memory
  enabled: true
  default: false
  category: Standard
  cpu:
    cores: 4
    sockets: 1
    threads: 1
  memory:
    quantity: 32Gi
  machineProviders: []
```

```bash
kubectl apply -f machineclass-large.yaml
```

## Kea Operator
To be continued

## Vitistack operator

The vitistack operator handles the vitistack crd object. The operator fetches information and adds it to the vitistack crd object, so other solutions could show or integrate with the vitistack. One example is ROR (Release Operate Report) found here: https://github.com/norskHelsenett/ror

Install the vitistack operator by:

```bash
helm install vitistack-operator oci://ghcr.io/vitistack/helm/vitistack-operator
```

## Kubevirt
To create machines with kubevirt we need to install kubevirt into a own cluster (or into the supervisor cluster)

### To install kubevirt 
[Guide to install Kubevirt](install-kubevirt.md)

### Verify kubevirt components

```bash
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
```

Check the components
```bash
kubectl get all -n kubevirtkubectl get all -n kubevirt
```

### How create a KubeVirtConfig

Create a k8s secret from file content (kubeconfig file to the kubevirt cluster)

```bash
kubectl create secret generic kubevirt-provider --from-file=kubeconfig=<path to kubevirt kubeconfig file>`
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
helm install viti-kubevirt-operator oci://ghcr.io/vitistack/helm/kubevirt-operator
```

## Proxmox-operator

You need one or more Proxmox instances.

To install proxmox, follow this installation guide: 
- https://proxmox.com/en/products/proxmox-virtual-environment/get-started
- https://pve.proxmox.com/pve-docs/chapter-pve-installation.html

### Install the Proxmox operator

```bash
helm registry login ghcr.io
helm install viti-proxmox-operator oci://ghcr.io/vitistack/helm/proxmox-operator
```

## Talos Operator
To be continued