#!/bin/bash

VM=k3s
CONFIG=$(pwd)/k3s-kubeconfig.yaml

kcli ssh -u root $VM "cat /etc/rancher/k3s/k3s.yaml" > $CONFIG
IP=$(kcli info vm $VM | grep ip | awk -F ":" '{ print $2 }' | tr -d " ")
sed -i "s|server: https://127.0.0.1:6443|server: https://$IP:6443|g" $CONFIG
echo "export KUBECONFIG=$CONFIG"
