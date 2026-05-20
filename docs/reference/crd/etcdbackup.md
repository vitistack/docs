# EtcdBackup

The EtcdBackup CRD configures etcd backup schedules and retention policies for Kubernetes clusters managed by Viti Stack.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: EtcdBackup
metadata:
  name: string
  namespace: string
spec:
  # Cluster Reference
  clusterRef:
    name: string                # KubernetesCluster name

  # Schedule Configuration
  schedule:
    cron: string                # Cron expression for backup schedule
    retention:
      maxBackups: int           # Maximum number of backups to retain
      maxAge: string            # Maximum age of backups (e.g., "7d")

  # Storage Configuration
  storage:
    type: string                # Storage type: s3, local, nfs
    s3:
      bucket: string            # S3 bucket name
      prefix: string            # Key prefix
      region: string            # S3 region
      credentials:
        secretRef:
          name: string          # Secret with S3 credentials

status:
  lastBackup: timestamp         # Last successful backup time
  lastBackupSize: string        # Size of last backup
  backupCount: int              # Current number of stored backups
  conditions: []Condition       # Status conditions
```

## Related Resources

- [KubernetesCluster](kubernetescluster.md) — Cluster being backed up
