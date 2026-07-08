# Install Kubevirt

## Kubevirt in kubernetes

(docs with kind: https://kubevirt.io/quickstart_kind)

```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo $VERSION
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
```

## Install the CRDS

```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo $VERSION
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

### Containerized Data Importer (CDI)

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

## Multus

The Vitistack uses Multus together with Kubevirt, so please install multus.

Docs: https://github.com/k8snetworkplumbingwg/multus-cni and https://github.com/k8snetworkplumbingwg/multus-cni/blob/master/docs/quickstart.md

or one liner:

```bash
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset-thick.yml
```

If you are installing kubevirt in Talos, please check this site for more workarounds:

https://docs.siderolabs.com/kubernetes-guides/cni/multus#patching-the-daemonset


## :warning: If using Multus on a Talos cluster

Read this: https://docs.siderolabs.com/kubernetes-guides/cni/multus