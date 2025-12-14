# Install Kubevirt

## Install kubevirt
(docs with kind: https://kubevirt.io/quickstart_kind)
```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)

echo $VERSION
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml"
```

## Virtualized environment
If running in a virtualized environment

If the kind cluster runs on a virtual machine consider enabling nested virtualization. Follow the instructions described here. If for any reason nested virtualization cannot be enabled do enable KubeVirt emulation as follows:

```bash
kubectl -n kubevirt patch kubevirt kubevirt --type=merge --patch '{"spec":{"configuration":{"developerConfiguration":{"useEmulation":true}}}}'
```

## Deploy the KubeVirt custom resource definitions

```bash
kubectl create -f "https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml"
```


## Virtctl
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

## Verify kubevirt components

```bash
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
```

Check the components
```bash
kubectl get all -n kubevirtkubectl get all -n kubevirt
```

## How create a KubeVirtConfig

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

## Create the KubevirtConfig

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


## Install the Kubevirt-operator

```bash
helm registry login ghcr.io
helm install viti-kubevirt-operator oci://ghcr.io/vitistack/helm/kubevirt-operator
```