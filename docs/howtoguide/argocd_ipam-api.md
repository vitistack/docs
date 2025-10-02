# Deploy IPAM-API w/ Argo CD

Please replace parameter keys with valid secrets!

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ipam-api
  namespace: argocd
spec:
  project: default
  source:
    path: .
    repoURL: oci://ghcr.io/vitistack/helm/ipam-api
    targetRevision: 1.*.*
    helm:
      valueFiles:
          - values.prod.yaml
      parameters:
      - name: secrets.mongodb
        value: dc87572kdmfh48djak9375629jsnehj478292
      - name: secrets.netbox
        value: dc87572kdmfh48djak9375629jsnehj478292
      - name: secrets.splunk
        value: 022847f6a2b4b22877e45ca72345fsa1e4c05
      - name: encryption.encKey
        value: 1674361290ebdied
      - name: encryption.encIv
        value: tghdavghyjmlmnoi
  destination:
    server: "https://kubernetes.default.svc"
    namespace: ipam-system
  syncPolicy:
      automated:
          selfHeal: true
          prune: true
      syncOptions:
      - CreateNamespace=true
```