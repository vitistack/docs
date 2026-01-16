# Install Vitistack CRDs

Using Helm (recommended)

First, login to GitHub Container Registry

Username: your GitHub username

Password: a Personal Access Token (PAT) with `read:packages` scope

Create a PAT at: https://github.com/settings/tokens/new?scopes=read:packages

```bash
helm registry login ghcr.io
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
  --reuse-values
```
