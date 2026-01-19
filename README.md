# Fedora CoreOS setup with k3s

Fedora coreos with k3s. This repository uses [kcli](https://github.com/karmab/kcli) to create and manage the VMs locally with libvirt.

## Build QEMU image
 ```bash
$ sudo just build oci-archive qemu
```

## Create VM
```bash
$ kcli create plan -f kcli_plan.yaml
```

## Retrieve kubeconfig to use on the host
```bash
./kubeconfig.sh 
export KUBECONFIG=/path/k3s-fcos/k3s-kubeconfig.yaml
```
