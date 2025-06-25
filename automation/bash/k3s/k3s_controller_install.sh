#!/bin/bash


# Install without default CNI so we can use Cilium
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend=none --cluster-cidr=10.42.0.0/16 --disable-network-policy" sh -
#### Get the token for the worker
sudo cat /var/lib/rancher/k3s/server/node-token

# Set up kubectl access
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
# Test kubectl
kubectl get nodes
# Install Cilium
cilium install
# Check Cilium status
cilium status --wait