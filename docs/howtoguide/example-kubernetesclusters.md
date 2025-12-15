# Example KubernetesClusters

## Small simple kubernetescluster

```yaml
apiVersion: vitistack.io/v1alpha1
kind: KubernetesCluster
metadata:
  name: t-test-002-5tu8
spec:
  data:
    clusterUid: "a30fbc8d-596f-48d0-8541-dbc23bca28a1"
    clusterId: "t-test-002-5tu8"
    provider: talos
    environment: dev
    datacenter: test-south-az1
    project: simple-project
    region: south
    workorder: "simple-workorder"
    zone: "az1"
    workspace: "simple-workspace"
  topology:
    version: "1.34.1"
    controlplane:
      replicas: 1
      version: "1.34.1"
      machineClass: small
      provider: kubevirt
      storage:
        - class: "standard"
          path: "/var/lib/vitistack/kubevirt"
          size: "20Gi"
      metadata:
        annotations:
          environment: development
          region: west-trondelag
        labels:
          environment: development
          region: west-trondelag
    workers:
      nodePools:
        - name: wp
          taint: []
          version: "1.34.1"
          replicas: 1
          machineClass: large
          autoscaling:
            enabled: false
            minReplicas: 1
            maxReplicas: 5
            scalingRules:
              - "cpu"
          metadata:
            annotations:
              environment: development
              region: west-trondelag
            labels:
              environment: development
              region: west-trondelag
          provider: kubevirt
          storage:
            - class: "standard"
              path: "/var/lib/vitistack/kubevirt"
              size: "20Gi"

```