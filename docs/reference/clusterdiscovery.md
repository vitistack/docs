# Cluster discovery

A cluster that is created or should be adopted by vitistack must have the following annotations or labels on at least one of its nodes:

| Annotation/Label | Description | Example |
|---|---|---|
|vitistack.io/clustername||t-per-et-401|
|vitistack.io/clusterworkspace||t-per|
|vitistack.io/region||west|
|vitistack.io/az||bgo|
|vitistack.io/vmprovider||kubevirt|
|vitistack.io/kubernetesprovider||talos|
|vitistack.io/clusterid||8875ca15-abed-46f3-8c0f-8a73a2423baa|
|vitistack.io/kubernetes-endpoint-addr||https://10.204.150.5:6443|