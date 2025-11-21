# Cluster Discovery


## Annotations

A cluster that is created or should be adopted by vitistack must have the following annotations or labels on at least one of its nodes

| Annotation/Label | Description | Example |
|---|---|---|
|vitistack.io/clustername|the name of the cluster|t-mgmt-001|
|vitistack.io/clusterworkspace|the workspace of the cluster|nhn-l44t|
|vitistack.io/country|the country abreviation|no|
|vitistack.io/region|the region|west|
|vitistack.io/infrastructure|the infrastructure, if omited = prod|mgmt,test|
|vitistack.io/az|the availability zone|az1|
|vitistack.io/vmprovider|the provider of the machine|kubevirt|
|vitistack.io/vmid|the name of the vm in the vm provider|t-mgmt-001-ctp01|
|vitistack.io/kubernetesprovider|the provider of kubernetes|talos|
|vitistack.io/clusterid|an unique id of the cluster|t-mgmt-001-l33t|
|vitistack.io/kubernetes-endpoint-addr|the loadbalanced api endpoint|https://10.20.30.40:6443|

## DNSnames (may be used)

|Type|Pattern|Example|
|---|---|---|
|cluster|[clusterId].[az].[region].[country].platform.nhn.no|t-mgmt-001-l33t.az1.west.no.platform.nhn.no|
|node|[hostname].[clusterId].[workspaceId].[az].[region].[country].platform.nhn.no|t-mgmt-001-cpl01.t-mgmt-001-l33t.t-nhn-l44t.az1.west.no.platform.nhn.no|


## Infrastructure

|infrastructure|dns|
|---|---|
|prod|t-mgmt-001-l33t.az1.west.no.platform.nhn.no|
|mgmt|t-mgmt-001-l33t.az1.west.no.mgmt.platform.nhn.no|
|test|t-mgmt-001-l33t.az1.west.no.test.platform.nhn.no|
