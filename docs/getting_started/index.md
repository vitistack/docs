# Getting started

## What is Vitistack

VitiStack is a Kubernetes-native infrastructure platform that provisions and manages virtual machines and Kubernetes clusters across multiple providers (**machine providers**: Proxmox, KubeVirt. **kubernetes providers**: Talos, AKS). 

This guide will be relative quick and easy, dependent on your knowledge about [kubernetes](https://kubernetes.io/docs), [Linux](https://en.wikipedia.org/wiki/Linux) and networking. If you have suggestions or want to contribute, please add an issue to the [repo](https://github.com/vitistack/docs).

Our weapon of choice is Kubernetes, so we could have everything at scale, and all is declarative. Customization is done with the [operator pattern](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/).  

1. [Requirements](./requirements.md) will go through the hardware or machines needed
2. [Install kubernetes](./install-kubernetes.md)
2. [Setup storage](./setup-storage.md)
3. [Install kubevirt](./install-kubevirt.md)
4. [Setup Vitistack operators](./operators.md)
5. [Create VMs and guest Kubernetes clusters](./examples.md)

[Optional install Vitictl](./vitictl.md)