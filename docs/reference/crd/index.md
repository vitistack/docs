# Custom Resource Definitions (CRDs)

The Viti Stack CRDs define the declarative APIs used by all operators to manage infrastructure resources in Kubernetes.

## API Group and Versions

All CRDs belong to the **vitistack.io** API group. Most use **v1alpha1**; the network resources have been promoted to **v1alpha2**.

| Version | Applies To | Status |
|---------|-----------|--------|
| v1alpha1 | All resources except below | Current |
| v1alpha2 | NetworkNamespace, IPAllocation | Current (storage version) |

!!! info "Conversion Webhook"
    A standalone conversion webhook ships with the **vitistack-crds** Helm chart and transparently converts **NetworkNamespace** between v1alpha1 and v1alpha2. Existing v1alpha1 clients continue to work without modification.

## Resources

| API Version | Kind | Scope | Purpose |
|-------------|------|-------|---------|
| vitistack.io/v1alpha1 | [Vitistack](vitistack.md) | NS | Core infrastructure configuration |
| vitistack.io/v1alpha1 | [Machine](machine.md) | NS | Virtual machine and compute resource |
| vitistack.io/v1alpha1 | [MachineClass](machineclass.md) | C | Machine size templates |
| vitistack.io/v1alpha1 | [MachineProvider](machineprovider.md) | NS | Machine provisioning backend |
| vitistack.io/v1alpha1 | [KubernetesCluster](kubernetescluster.md) | NS | Kubernetes cluster configuration |
| vitistack.io/v1alpha1 | [KubernetesProvider](kubernetesprovider.md) | NS | Kubernetes provisioning backend |
| vitistack.io/v1alpha1 | [NetworkConfiguration](networkconfiguration.md) | NS | Network interface configuration |
| vitistack.io/**v1alpha2** | [**NetworkNamespace**](networknamespace.md) | NS | Network isolation boundary |
| vitistack.io/**v1alpha2** | [**IPAllocation**](ipallocation.md) | NS | Individual IP address allocation |
| vitistack.io/v1alpha1 | ClusterStorage | C | Storage configuration |
| vitistack.io/v1alpha1 | ClusterStorageClass | C | Storage class templates |
| vitistack.io/v1alpha1 | [EtcdBackup](etcdbackup.md) | NS | Etcd backup configuration |
| vitistack.io/v1alpha1 | [KubevirtConfig](kubevirtconfig.md) | NS | KubeVirt operator configuration |
| vitistack.io/v1alpha1 | [ProxmoxConfig](proxmoxconfig.md) | NS | Proxmox operator configuration |

## Schema Evolution

### Versioning Strategy

- **v1alpha1** — Current for most resources. Breaking changes possible.
- **v1alpha2** — Storage version for network resources. v1alpha1 still served via conversion webhook.
- **v1beta1 / v1** — Future stable versions with backward compatibility guarantees.

### Conversion Webhook

The **vitistack-crds** Helm chart deploys a standalone conversion webhook for **NetworkNamespace** and **IPAllocation**:

- TLS managed by **cert-manager** (CA auto-injected into CRD spec)
- Runs as a separate deployment, independent of any operator
- Converts between v1alpha1 ↔ v1alpha2 transparently

### Compatibility Rules

| Change Type | v1alpha | v1beta | v1 |
|-------------|---------|--------|-----|
| Add optional field | ✅ | ✅ | ✅ |
| Add required field | ⚠️ | ❌ | ❌ |
| Remove field | ⚠️ | ❌ | ❌ |
| Rename field | ⚠️ | ❌ | ❌ |
| Change field type | ⚠️ | ❌ | ❌ |

## Installation

### Helm (recommended)

```bash
helm install vitistack-crds oci://ghcr.io/vitistack/helm/vitistack-crds \
  --namespace vitistack-system --create-namespace \
  --set conversionWebhook.enabled=true
```

### Manual

```bash
kubectl apply -f crds/
```

### Verify

```bash
kubectl get crd | grep vitistack.io
```

## Go Integration

```go
import (
    v1alpha1 "github.com/vitistack/common/pkg/v1alpha1"
    v1alpha2 "github.com/vitistack/common/pkg/v1alpha2"
    "k8s.io/apimachinery/pkg/runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
)

scheme := runtime.NewScheme()
v1alpha1.AddToScheme(scheme)
v1alpha2.AddToScheme(scheme)

c, _ := client.New(config, client.Options{Scheme: scheme})

// Fetch a v1alpha2 NetworkNamespace
nn := &v1alpha2.NetworkNamespace{}
_ = c.Get(ctx, types.NamespacedName{Namespace: "dc-01", Name: "prod"}, nn)

// List IPAllocations by label
list := &v1alpha2.IPAllocationList{}
_ = c.List(ctx, list, client.MatchingLabels{
    v1alpha2.LabelNetworkNamespace: "prod",
})
```