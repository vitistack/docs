# Examples

## Create a NetworkNamespace


### 1. Tenant namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: vitistack
```

### 2. NetworkNamespace (static IP)

```yaml
apiVersion: vitistack.io/v1alpha2
kind: NetworkNamespace
metadata:
  name: test-networknamespace
  labels:
    app: vitistack
    network-type: static
spec:
  networkProvisioning:
    provider: manual
    manual:
      ipv4CIDR: "192.168.1.0/24"
      ipv4Gateway: "192.168.1.1"
      ipv6CIDR: "2001:4645:401a::/64"
      vlanId: 0
  ipAllocation:
    type: static
    provider: static-ip-operator
    static:
      ipv4CIDR: "192.168.1.0/24"
      ipv4Gateway: "192.168.1.1"
      ipv4RangeStart: "192.168.1.230"
      ipv4RangeEnd: "192.168.1.254"
      vlanId: 0
      dns:
        - "192.168.1.1"
        - "8.8.8.8"
      ttlSeconds: 600
```

### 3. KubernetesCluster

Reference the NetworkNamespace by name. static-ip-operator allocates an IP per
machine interface (and the control-plane VIP) from the range above; kubevirt-operator
delivers them to the VMs via cloud-init.

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: testcluster
spec:
  data:
    clusterUid: "a30fbc8d-596f-48d0-8541-dbc23bca28a1"
    clusterId: "testcluster-ads3"
    provider: talos
    environment: dev
    datacenter: no-central-az1
    project: simple-project
    region: central
    workorder: "simple-workorder"
    zone: "az1"
    workspace: "simple-workspace"
    networkNamespaceName: test-networknamespace
  topology:
    version: "1.36.2"
    controlplane:
      replicas: 1
      version: "1.36.2"
      machineClass: small
      provider: kubevirt
      storage:
        - class: "standard"
          path: "/var/lib/vitistack/kubevirt"
          size: "20Gi"
      metadata:
        annotations:
          environment: development
          region: central
        labels:
          environment: development
          region: central
    workers:
      nodePools:
        - name: wp
          taint: []
          version: "1.36.2"
          replicas: 2
          machineClass: medium
          autoscaling:
            enabled: false
            minReplicas: 1
            maxReplicas: 5
            scalingRules:
              - "cpu"
          metadata:
            annotations:
              environment: development
              region: central
            labels:
              environment: development
              region: central
          provider: kubevirt
          storage:
            - class: "standard"
              path: "/var/lib/vitistack/kubevirt"
              size: "20Gi"
```