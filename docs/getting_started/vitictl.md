# Vitictl

## One-liner (Linux / macOS)

Downloads the latest release, verifies the SHA-256 checksum and (if cosign is installed) the Sigstore keyless signature, then installs viti to /usr/local/bin (or $HOME/.local/bin when not root):

```bash
curl -fsSL https://raw.githubusercontent.com/vitistack/vitictl/main/install.sh | bash
```

### Pin a specific version

```bash
curl -fsSL https://raw.githubusercontent.com/vitistack/vitictl/main/install.sh | bash -s -- --version v0.2.0
```

### Install the viti-gui TUI plugin alongside

```bash
curl -fsSL https://raw.githubusercontent.com/vitistack/vitictl/main/install.sh | bash -s -- --with-gui
```

### Or change the install directory:

```bash
curl -fsSL https://raw.githubusercontent.com/vitistack/vitictl/main/install.sh | bash -s -- --prefix "$HOME/.local/bin"
```

## Test

```bash
viti
```

### Output

```bash
🚀 viti is a command-line tool for interacting with one or more
Vitistack installations: inspecting vitistacks, searching for machines and
Kubernetes clusters, and extracting cluster configuration artifacts.

🌐 A Vitistack deployment may span several availability zones (Kubernetes
clusters): configure one or more kubeconfig/context availability zones in
~/.vitistack/ctl.config.yaml and commands will iterate them. Use
-z/--availabilityzone (or --az) to restrict a command to a single zone.

Installed version: v0.0.15

Usage:
  viti [command]

Available Commands:
  clusterstorage (cls, clusterstorages)                                  🗄️  Work with ClusterStorage resources
  completion                                                             Generate the autocompletion script for the specified shell
  config (c)                                                             ⚙️  Manage viti configuration (~/.vitistack/ctl.config.yaml)
  controlplanevirtualsharedip (lb, controlplanevirtualsharedips, cpvip)  🧷 Work with ControlPlaneVirtualSharedIP (load balancer) resources
  etcdbackup (eb, etcdbackups)                                           💾 Work with EtcdBackup resources
  help                                                                   Help about any command
  kubernetescluster (kc, kubernetesclusters)                             ☸️  Work with KubernetesCluster resources
  kubernetesprovider (kp, kubernetesproviders)                           ☁️  Work with KubernetesProvider resources
  kubevirtconfig (kvc, kubevirtconfigs)                                  💻 Work with KubevirtConfig resources
  machine (m, machines)                                                  🖥️  Work with Machine resources
  machineclass (mc, machineclasses)                                      🧩 Work with MachineClass resources
  machineprovider (mp, machineproviders)                                 🏭 Work with MachineProvider resources
  networkconfiguration (nc, networkconfigurations)                       🌐 Work with NetworkConfiguration resources
  networknamespace (nn, networknamespaces)                               🕸️  Work with NetworkNamespace resources
  plugin (plugins)                                                       🧩 Manage viti plugins (external binaries named viti-*)
  proxmoxconfig (pxc, proxmoxconfigs)                                    🔌 Work with ProxmoxConfig resources
  upgrade                                                                ⬆️  Check for a newer viti release and upgrade
  version                                                                Print the viti version
  vitistack (vs, vitistacks)                                             🌐 Inspect Vitistack resources

Flags:
  -z, --availabilityzone string   restrict to a single configured availability zone (by name)
      --az string                 alias for --availabilityzone
  -h, --help                      help for viti
  -v, --version                   version for viti

Use "viti [command] --help" for more information about a command.
```