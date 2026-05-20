# KubernetesProvider

The KubernetesProvider CRD configures Kubernetes cluster provisioning backends. It defines cluster templates, networking, and add-on configuration.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesProvider
metadata:
  name: string
  namespace: string
spec:
  # Provider Configuration
  type: string                  # Provider type: talos, kubeadm, k3s

  # Cluster Configuration Template
  clusterTemplate:
    kubernetesVersion: string   # Kubernetes version
    cni:
      type: string              # CNI type: calico, flannel, cilium
      config: {}                # CNI-specific configuration
    controlPlane:
      replicas: int             # Control plane node count
      machineTemplate:          # Control plane machine template
        resources: {}
    workers:
    - name: string              # Worker group name
      replicas: int             # Worker node count
      machineTemplate:          # Worker machine template
        resources: {}

  # Network Configuration
  networking:
    podCIDR: string             # Pod network CIDR
    serviceCIDR: string         # Service network CIDR
    dnsDomain: string           # Cluster DNS domain

  # Add-ons Configuration
  addons:
    dns:
      enabled: bool             # Enable CoreDNS
      config: {}                # DNS configuration
    ingress:
      enabled: bool             # Enable ingress controller
      type: string              # Ingress type: nginx, traefik, istio
    storage:
      enabled: bool             # Enable storage classes
      defaultClass: string      # Default storage class

status:
  ready: bool                   # Provider readiness
  supportedVersions: []string   # Supported Kubernetes versions
  activeClusters: int           # Active cluster count
```

## Supported Provider Types

| Type | Description | Operator |
|------|-------------|----------|
| talos | Talos Linux clusters | talos-operator |

## Related Resources

- [KubernetesCluster](kubernetescluster.md) — Clusters provisioned by this provider
- [Machine](machine.md) — Machines that form cluster nodes
