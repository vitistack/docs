# How to setup vitistack

## Prerequisites

First of all you need a Kubernetes cluster to run all the Vitistack operators.

### On prem

Create hardware nodes an install ex Talos, K0s or other kubernetes solutions

### Cloud

- Azure Kubernetes Service (AKS)
- Elastic Kubernetes Service (EKS)
- Scaleway
- Upcloud
- or others

### Locally

You could use Kind (https://kind.sigs.k8s.io/docs/user/quick-start/#installation) or Talosctl (https://docs.siderolabs.com/talos/v1.11/getting-started/talosctl) to install spin up a Kubernetes cluster locally.

## Visual cluster overview

![Vitistack cluster setup](../../images/vitistack-setup.excalidraw.png "Vitistack cluster setup")

It is also possible that the supervisor cluster also has Kubevirt installed, so there is also support for only one cluster. But it is wise to spread out the risk onto multiple clusters, incause of errors.

## CRDS

[Install vitistack crds](../infrastructure/vitistack-crds.md)

## Machine Classes

[Install machineclasses](../setup/install-machineclasses.md)

## Vitistack operator

[Vitistack operator](../operators/install-vitistack-operator.md)

## Network

To be continued

## DHCP

We currently support:

- [Kea DHCP](../operators/install-keadhcp.md)

## Vitistack Machine Providers

To make vitistack machines, we currently support

- [Kubevirt](../machines/install-kubevirt.md)
- [Proxmox](../machines/install-proxmox.md)
- [Physical](../machines/install-physical-operator.md)

## Vitistack Kubernetes Providers

To install a vitistack Kubernetes cluster, we currently support

- [Talos](../clusters/install-talos.md)
