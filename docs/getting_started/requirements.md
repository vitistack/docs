# Requirements

Vitistack runs on top of a Kubernetes cluster with KubeVirt, so the hardware requirements are driven by how many virtual machines and guest Kubernetes clusters you plan to host. Pick the profile below that matches your use case.

!!! note "Virtualization support"
    All nodes that will run virtual machines need hardware virtualization extensions enabled in BIOS/UEFI (Intel VT-x or AMD-V). If you are testing Vitistack inside virtual machines, nested virtualization must be enabled on the hypervisor.

=== "Minimal"

    Suitable for a lab or trying out Vitistack. Everything runs on a single node, and there is no redundancy — a node failure means downtime.

    | Component | Requirement |
    | --------- | ----------- |
    | Nodes     | 1 control plane & 1 worker  |
    | CPU       | 6 cores for control plane<br />8 or more for workers |
    | Memory    | 6 GB for controlplanes<br />32 GB for workers (or more) |
    | Storage   | 512 GB SSD, or more |
    | Network   | 1 GbE, single NIC |

    **Sutable for:**

    - Home lab
    - Dev setup

    Notes:

    - Local-path storage is enough.
    - Expect room for only a couple of small VMs or one small guest cluster.

    

=== "Recommended"

    Suitable for a small production or staging environment with basic redundancy for both the control plane and storage.

    | Component | Requirement |
    | --------- | ----------- |
    | Nodes     | 3 control plane + 3 workers or more |
    | CPU       | 4+ cores for control planes<br />12+ cores per worker |
    | Memory    | **8 GB** RAM per **control plane**<br />**96 GB** RAM per **worker** (or more) |
    | Storage   | 1-2 TB NVMe per worker , or dedicated storage like Rook Ceph / NFS or others |
    | Network   | 10 GbE, dual NICs (separate storage/VM traffic) |

    **Sutable for:**

    - Test setup / Small production environment
    - 5-10+ small clusters (dependent on workers)
    
    - Three storage nodes (or workers with dedicated disks) allow a replicated Ceph cluster with both RBD (block) and CephFS (shared filesystem) pools.
    - Control plane nodes can be modest: 4 cores / 8 GB RAM / 100 GB SSD each.

=== "Optimal"

    Suitable for production at scale, with dedicated node roles and full redundancy across compute, storage and network.

    | Component | Requirement |
    | --------- | ----------- |
    | Nodes     | 3 control plane + 3+ dedicated storage + 4+ workers |
    | CPU       | 32+ cores per worker |
    | Memory    | 256+ GB RAM per worker |
    | Storage   | NVMe only; dedicated Ceph nodes with separate OSD disks |
    | Network   | 25 GbE or faster, bonded NICs, separate VLANs for storage, VM and management traffic |

    - Dedicated storage nodes keep Ceph performance predictable under VM load.
    - Size worker memory for VM density — VM memory is reserved, not overcommitted by default.
    - Plan for N+1 capacity so VMs can be live-migrated during node maintenance.
