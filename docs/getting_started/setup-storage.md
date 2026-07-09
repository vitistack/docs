# Setup storage

## Using Longhorn

### Prerequisites

 We need the extensions:

 ```bash
 customization:
  systemExtensions:
    officialExtensions:
      - image: ghcr.io/siderolabs/iscsi-tools
      - image: ghcr.io/siderolabs/util-linux-tools
 ```

 if installing on Talos, create the longhorn-system namespace like this:

Filename: `longhorn-system-namespace.yaml`
```bash
apiVersion: v1
kind: Namespace
metadata:
  name: longhorn-system
  labels:
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged

```

`Kubectl apply -f longhorn-system-namespace.yaml`

## Installing longhorn with helm


```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm upgrade --install longhorn longhorn/longhorn \
  --namespace longhorn-system --create-namespace \
  --set defaultSettings.createDefaultDiskLabeledNodes=true \
  --set defaultSettings.defaultDataPath="/var/mnt/longhorn" \
  --set defaultSettings.defaultReplicaCount=1 \
  --set persistence.defaultClassReplicaCount=1 \
  --set defaultSettings.storageReservedPercentageForDefaultDisk=2
```

Why both replica-count flags:
- `defaultSettings.defaultReplicaCount` — cluster-wide setting that applies to volumes created via the Longhorn UI/API directly.
- `persistence.defaultClassReplicaCount` — sets the `numberOfReplicas` parameter on the `longhorn` StorageClass itself, which is what the Kubernetes provisioner reads when a PVC requests this SC. **This is the one that matters for normal `kubectl apply -f pvc.yaml` workflows.** Setting only the first leaves the StorageClass at its chart default of `3`, producing `degraded` volumes on a single-worker cluster.

## Verify Installation

```bash
# Check all pods are running
kubectl get pods -n longhorn-system

# Check daemonsets
kubectl get daemonsets -n longhorn-system

# Check Longhorn manager logs
kubectl logs -n longhorn-system -l app=longhorn-manager --tail=50
```

## Access Longhorn UI

```bash
kubectl -n longhorn-system port-forward svc/longhorn-frontend 8080:80
```

Then open: http://localhost:8080

## Troubleshooting

### Check iSCSI is working

```bash
# On Talos worker
talosctl -n 192.168.1.133 -e 192.168.1.130 service iscsid status --talosconfig=./talosconfig

# Check if iscsiadm is available
talosctl -n 192.168.1.133 -e 192.168.1.130 read /usr/bin/iscsiadm --talosconfig=./talosconfig
```

### Check Longhorn Manager Logs

```bash
kubectl logs -n longhorn-system -l app=longhorn-manager -c longhorn-manager --tail=100
```

### Common Issues

1. **"iscsiadm: No such file or directory"** → iSCSI extension not installed (follow Step 1-4 above)
2. **Pods in CrashLoopBackOff** → Usually iSCSI related, check service status
3. **Driver deployer stuck in Init** → Waiting for manager pods to be ready
4. **Permission issues** → Ensure privileged namespace is set
