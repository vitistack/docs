

## multidoc
```
---
apiVersion: v1alpha1
kind: HostnameConfig
auto: "off"
hostname: demo-kv-wrk0
---
apiVersion: v1alpha1
kind: ResolverConfig
nameservers:
    - address: 192.168.2.1
---
apiVersion: v1alpha1
kind: LinkConfig
mtu: 1500
name: enp86s0
---
apiVersion: v1alpha1
kind: VolumeConfig
name: EPHEMERAL
provisioning:
  minSize: 200GiB
  maxSize: 200GiB
---
apiVersion: v1alpha1
kind: UserVolumeConfig
name: local-path-provisioner
provisioning:
  diskSelector:
    match: disk.transport == 'nvme'
  minSize: 200GB
  maxSize: 4000GB
---
apiVersion: v1alpha1
kind: BondConfig
name: bond1
links:
    - enp86s0
mtu: 1500
bondMode: active-backup
up: true
---
apiVersion: v1alpha1
kind: BridgeConfig
name: br0
links:
    - bond1
addresses:
    - address: 192.168.2.34/24
routes:
    - gateway: 192.168.2.1
stp:
    enabled: false
vlan:
    filtering: true
```