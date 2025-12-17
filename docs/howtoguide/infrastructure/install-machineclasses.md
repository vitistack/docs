# Install Machine Classes

These a example machine classes

### Small
filename: machineclass-small.yaml
```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: small
spec:
  displayName: Small
  description: Small instance with 2 cores and 8Gi memory
  enabled: true
  default: false
  category: Standard
  cpu:
    cores: 2
    sockets: 1
    threads: 1
  memory:
    quantity: 8Gi
  machineProviders: []
```

```bash
kubectl apply -f machineclass-small.yaml
```

### Medium
filename: machineclass-medium.yaml
```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: medium
spec:
  displayName: Medium
  description: Medium instance with 4 cores and 16Gi memory
  enabled: true
  default: true
  category: Standard
  cpu:
    cores: 4
    sockets: 1
    threads: 1
  memory:
    quantity: 16Gi
  machineProviders: []

```

```bash
kubectl apply -f machineclass-medium.yaml
```

### Large
filename: machineclass-large.yaml
```yaml
apiVersion: vitistack.io/v1alpha1
kind: MachineClass
metadata:
  name: large
spec:
  displayName: Large
  description: Large instance with 4 cores and 32Gi memory
  enabled: true
  default: false
  category: Standard
  cpu:
    cores: 4
    sockets: 1
    threads: 1
  memory:
    quantity: 32Gi
  machineProviders: []
```

```bash
kubectl apply -f machineclass-large.yaml
```