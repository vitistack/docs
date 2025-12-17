# Example Machines

## Network namespace

First we need the NetworkNamespace object

Filename: networknamespace.yaml

```yaml
apiVersion: vitistack.io/v1alpha1
kind: NetworkNamespace
metadata:
  name: t-test01
spec:
  datacenterIdentifier: test-north-az1
  supervisorIdentifier: test-viti
```

Apply with:

```bash
kubectl create namespace t-test01
kubectl apply -f networknamespace.yaml -n t-test01
```

## Debian iso

Dependent on the experimental feature CDI (https://kubevirt.io/user-guide/storage/containerized_data_importer)

Filename: machine-iso-debian.yaml

```yaml
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: example-machine-iso-debian
  annotations:
    # Annotation to indicate we want to use a DataVolume for the boot source
    kubevirt.io/boot-source: "datavolume"
    kubevirt.io/boot-source-type: "http"
spec:
  machineClass: "medium"
  name: "debian-iso-vm"
  provider: kubevirt

  # Operating system configuration
  os:
    family: linux
    distribution: debian
    version: "13.2"
    architecture: amd64
    # HTTP URL to the debian ISO image
    # This will be used to create a DataVolume with CDI
    imageID: "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.2.0-amd64-netinst.iso"

  # Define disks - the ISO will be attached as a cdrom
  disks:
    - name: "root"
      sizeGB: 50
      boot: true
      type: "virtio"
      encrypted: false
```

Apply with:

```bash
kubectl apply -f machine-iso-debian.yaml -n t-test01
```

## Talos iso

Dependent on the experimental feature CDI (https://kubevirt.io/user-guide/storage/containerized_data_importer)

Filename: machine-iso-talos.yaml

```yaml
---
apiVersion: vitistack.io/v1alpha1
kind: Machine
metadata:
  name: example-machine-iso-talos
  annotations:
    # Annotation to indicate we want to use a DataVolume for the boot source
    kubevirt.io/boot-source: "datavolume"
    kubevirt.io/boot-source-type: "http"
spec:
  machineClass: "medium"
  name: "talos-iso-vm"
  provider: kubevirt

  # Operating system configuration
  os:
    family: linux
    distribution: talos
    version: "1.11.5"
    architecture: amd64
    # HTTP URL to the Talos ISO image
    # This will be used to create a DataVolume with CDI
    imageID: "https://github.com/siderolabs/talos/releases/download/v1.11.5/metal-amd64.iso"

  # Define disks - the ISO will be attached as a cdrom
  disks:
    - name: "root"
      sizeGB: 50
      boot: true
      type: "virtio"
      encrypted: false
```

Apply with:

```bash
kubectl apply -f machine-iso-talos.yaml -n t-test01
```
