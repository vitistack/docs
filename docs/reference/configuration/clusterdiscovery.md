# Cluster Discovery


## Annotations

A cluster that is created or should be adopted by vitistack must have the following annotations or labels on at least one of its nodes

| Annotation/Label | Description | Example |
|---|---|---|
|vitistack.io/clustername|the name of the cluster|t-mgmt-001|
|vitistack.io/clusterworkspace|the workspace of the cluster|t-nhn-l44t|
|vitistack.io/country|the country abreviation|no|
|vitistack.io/region|the region|west|
|vitistack.io/az|the availability zone|az1|
|vitistack.io/vmprovider|the provider of the machine|kubevirt|
|vitistack.io/kubernetesprovider|the provider of kubernetes|talos|
|vitistack.io/clusterid|an unique id of the cluster|t-mgmt-001-l33t|
|vitistack.io/kubernetes-endpoint-addr|the loadbalanced api endpoint|https://10.20.30.40:6443|

##dnsnames 

|Type|Pattern|Example|
|---|---|---|
|cluster|[clusterId].[workspaceId].[az].[region].[country].platform.nhn.no|t-mgmt-001-l33t.t-nhn-l44t.az1.west.no.plattform.nhn.no|
|node|[hostname].[clusterId].[workspaceId].[az].[region].[country].platform.nhn.no|t-mgmt-001-ctp01.t-mgmt-001-l33t.t-nhn-l44t.az1.west.no.plattform.nhn.no|
