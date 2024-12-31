#!/bin/bash

#  Setup K8-Cluster using kubeadm [K8 Version-->1.28.1]
### 1. Update System Packages [On Master & Worker Node]
sudo apt-get update

### 2. Install Docker[On Master & Worker Node]
sudo apt install docker.io -y
sudo chmod 666 /var/run/docker.sock

### 3. Install Required Dependencies for Kubernetes[On Master & Worker Node]
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo mkdir -p -m 755 /etc/apt/keyrings

### 4. Add Kubernetes Repository and GPG Key[On Master & Worker Node]
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

### 5. Update Package List[On Master & Worker Node]
sudo apt update

### 6. Install Kubernetes Components[On Master & Worker Node]
sudo apt install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1