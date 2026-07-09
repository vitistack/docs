# Install Kubernetes

We are using Talos on this getting started guide, but you could use whatever kubernetes provider you want (nice to know about the network setup though).

In this example we have used 

- Networking: Ubiquity Unify setup (:warning: setting fixed ip for vm and worker, it is also possible to set static ip, see talos for more details)
- Proxmox to create control plane vm
- One physical machine for worker (ASUS NUC 15 Pro Tall Kit - Core Ultra 7 255H, with 96 GB memory, 1 TB nvme disk)


## Install Talos

For more details and more configuration details from talos, please have a look at the Talos production cluster setup: https://docs.siderolabs.com/talos/v1.13/getting-started/prodnotes

## Setup VM and hardware

You need to setup a VM for the control plane, we have setup a Proxmox VM (6 GB memory, 4 cores CPU, 100 GB disk). And we have have made the ASUS NUC ready, and connected to the network. Since we have a Ubiquity Unify setup, there is set fixed ip (reservation of ip )

### Setup control plane ips:

#### Set environment variables

```bash
export CONTROL_PLANE_IP=("192.168.1.130")
export YOUR_ENDPOINT=192.168.1.130
export YOUR_ENDPOINT_PORT=6443
export CLUSTER_NAME=vitistack
```

#### Generate secret bundle

`talosctl gen secrets -o secrets.yaml`

#### Generate machine configs

```bash
talosctl gen config --with-secrets secrets.yaml $CLUSTER_NAME https://$YOUR_ENDPOINT:$YOUR_ENDPOINT_PORT
```

:warning: and remove the `hostnameconfig`, we will set this later

#### Get links/network cards

```bash
talosctl get links --insecure -n 192.168.1.130
talosctl get links --insecure -n 192.168.1.133
```

(useful to see the name of the network cards, but we are using alias right now)

#### Get disks

`talosctl get disks --insecure -n 192.168.1.130`

using `/dev/sda` for control plane from proxmox

`talosctl get disks --insecure -n 192.168.1.133`

using `/dev/nvme0n1` on physical worker

#### Create a `controlplane-patch.yaml` file

Used this image setup for the proxmox vm from https://factory.talos.dev: https://factory.talos.dev/?arch=amd64&bootloader=auto&cmdline-set=true&extensions=-&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Fqemu-guest-agent&extensions=siderolabs%2Futil-linux-tools&platform=nocloud&target=cloud&version=1.13.6

```yaml
# controlplane-patch-1 file
machine:
    certSANs:
        - 192.168.1.130
    sysctls:
        user.max_user_namespaces: '11255'
    kubelet:
        extraArgs:
            rotate-server-certificates: true
    install:
        disk: /dev/sda
        image: factory.talos.dev/nocloud-installer/88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b:v1.13.6
cluster:
    network:
        podSubnets:
            - 100.124.0.0/16
            # IPv6 disabled — Talos default Flannel is IPv4-only.
            # See ipv6-activation.md to enable later (requires CNI swap).
            # - 2001:db8:124::/56
        serviceSubnets:
            - 100.120.0.0/16
            # - 2001:db8:120::/112
    discovery:
        enabled: false
    extraManifests:
        - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
        - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### Create a `worker-patch.yaml` file

The worker is a single-disk physical node (1 TB NVMe). Talos would otherwise grow `EPHEMERAL` across the whole disk, so we cap it at 100 GB and carve a `longhorn` user volume out of the rest. The user volume is automatically mounted at `/var/mnt/longhorn`.

Using this image setup for the worker node: https://factory.talos.dev/?arch=amd64&platform=metal&schematic-id=613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245&target=metal&version=1.13.6

```yaml
# worker-patch-1 file
machine:
    certSANs:
        - 192.168.1.130
    sysctls:
        user.max_user_namespaces: '11255'
    kubelet:
        extraArgs:
            rotate-server-certificates: true
    install:
        disk: /dev/nvme0n1
        image: factory.talos.dev/metal-installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.13.6
cluster:
    network:
        podSubnets:
            - 100.124.0.0/16
            # IPv6 disabled — Talos default Flannel is IPv4-only.
            # See ipv6-activation.md to enable later (requires CNI swap).
            # - 2001:db8:124::/56
        serviceSubnets:
            - 100.120.0.0/16
            # - 2001:db8:120::/112
    discovery:
        enabled: false
    extraManifests:
        - https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
        - https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
---
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
    diskSelector:
        match: system_disk
    maxSize: 100GB
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: longhorn
provisioning:
    diskSelector:
        match: system_disk
    minSize: 100GB
    grow: true
filesystem:
    type: xfs
---
apiVersion: v1alpha1
kind: LinkAliasConfig
name: eth0 # Alias for the link.
selector:
  match: "true"
---
apiVersion: v1alpha1
kind: BondConfig
name: bond1
links:
    - eth0
mtu: 1500
bondMode: active-backup
up: true
---
apiVersion: v1alpha1
kind: BridgeConfig
name: br0
links:
    - bond1
stp:
    enabled: false
vlan:
    filtering: true
```

- auto approve kubelet CSRs: https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml
- metrics server installation: https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
- worker-only: `VolumeConfig`/`UserVolumeConfig` partition the 1 TB NVMe — 100 GB cap on `EPHEMERAL`, the rest becomes a dedicated XFS partition for Longhorn at `/var/mnt/longhorn`
- worker-only: `LinkConfig` (physical NIC `eth0` using alias) + `BondConfig` (`bond1`, active-backup) + `BridgeConfig` (`br0`) — required by KubeVirt so VMs can attach to the LAN. The host IP `192.168.1.133` lives on `br0`.

#### merge the `controlplane.yaml` file

1. `talosctl machineconfig patch controlplane.yaml --patch @controlplane-patch.yaml --output controlplane-final.yaml`
1. `talosctl machineconfig patch worker.yaml --patch @worker-patch.yaml --output worker-final.yaml`

### Applying of talos config

#### Controlplanes

```bash
talosctl apply-config --insecure \
  --nodes 192.168.1.130 \
  -e 192.168.1.130 \
  --file controlplane-final.yaml \
  --config-patch '
---
apiVersion: v1alpha1
kind: HostnameConfig
hostname: viti-ctp1
'
```

#### Bootstrap first control plane

Bootstrap direct to node (simpler and avoids any HAProxy timing issues):

```bash
talosctl bootstrap --nodes 192.168.1.130 --endpoints 192.168.1.130 --talosconfig=./talosconfig
```

### Set endpoint in talosconfig

```bash
talosctl config endpoint 192.168.1.130
```

### Fetch Kubeconfig

```bash
talosctl kubeconfig kubeconfig --nodes 192.168.1.130 --endpoints 192.168.1.130 --talosconfig=./talosconfig
```

wait:
```bash
talosctl health --nodes 192.168.1.130 --endpoints 192.168.1.130 --talosconfig=./talosconfig
kubectl --kubeconfig=./kubeconfig get nodes
kubectl --kubeconfig=./kubeconfig get pods -n kube-system
```

#### Apply config to workers:

```bash
talosctl apply-config --insecure \
  --nodes 192.168.1.133 \
  -e 192.168.1.130 \
  --file worker-final.yaml \
  --config-patch '
---
apiVersion: v1alpha1
kind: HostnameConfig
hostname: viti-wrk1
'
```
