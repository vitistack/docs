# NetworkConfiguration

The NetworkConfiguration CRD defines network interface configuration and VLAN settings for machines. It represents a machine's connection to a network segment.

## Resource Definition

```yaml
apiVersion: vitistack.io/v1alpha1
kind: NetworkConfiguration
metadata:
  name: string
  namespace: string
spec:
  # Network Identification
  networkId: string             # Unique network identifier
  vlan: int                     # VLAN ID (1-4094)

  # Layer 2 Configuration
  bridge: string                # Bridge interface name
  mtu: int                      # Maximum Transmission Unit

  # IP Configuration
  ipam:
    type: string                # IPAM type: static, dhcp, kea
    subnet: string              # Network subnet (CIDR)
    gateway: string             # Default gateway
    dns:
      servers: []string         # DNS server addresses
      searchDomains: []string   # DNS search domains

  # DHCP Configuration (when type=kea)
  dhcp:
    enabled: bool               # Enable DHCP server
    poolStart: string           # DHCP pool start address
    poolEnd: string             # DHCP pool end address
    leaseTime: string           # DHCP lease duration
    reservations:
    - macAddress: string        # MAC address for reservation
      ipAddress: string         # Reserved IP address
      hostname: string          # Reserved hostname

  # Security Configuration
  security:
    isolation: bool             # Enable network isolation
    firewallRules:
    - direction: string         # Rule direction: ingress, egress
      protocol: string          # Protocol: tcp, udp, icmp
      port: string              # Port or port range
      source: string            # Source CIDR or IP
      destination: string       # Destination CIDR or IP
      action: string            # Action: allow, deny

status:
  ready: bool                   # Network readiness status
  allocatedIPs: []string        # Currently allocated IP addresses
  connectedMachines: []string   # Connected machine references
```

## Relationship to NetworkNamespace

A NetworkConfiguration references a [NetworkNamespace](networknamespace.md) to determine which network segment and IP pool it belongs to. When using static IP allocation, the static-ip-operator creates an [IPAllocation](ipallocation.md) resource for each NetworkConfiguration that requests an address.

## Related Resources

- [NetworkNamespace](networknamespace.md) — The network segment this configuration belongs to
- [IPAllocation](ipallocation.md) — Individual IP allocations created for this configuration
- [Machine](machine.md) — Machine that uses this network interface
