# Install Vitistack CRDs

Using Helm (recommended)

```bash
helm install vitistack-crds oci://ghcr.io/vitistack/helm/crds \
  --namespace vitistack \
  --create-namespace
```

Or using kubectl (no authentication required)

```bash
kubectl apply -f https://github.com/vitistack/common/releases/latest/download/crds.yaml
```

## Upgrade to latest version

```bash
helm upgrade vitistack-crds oci://ghcr.io/vitistack/helm/crds \
  --namespace vitistack \
  --create-namespace \
  --reset-then-reuse-values
```
