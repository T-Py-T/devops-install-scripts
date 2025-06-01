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

### 7. Changet the actual hostname of the machine and keys of the control plane
sudo kubeadm join 192.168.1.27:6443 --token mmm5s9.kukes4glnq8qlxdc \
    --discovery-token-ca-cert-hash sha256:7e2038d75e23abeb03dd59100678c2d16d5ca471c1ccf9f29b31d50156a77393

#############################################################
# Troubleshooting kubeadm join errors on worker nodes:
# 1. If you see errors about existing files or ports in use:
#    [ERROR FileAvailable--etc-kubernetes-kubelet.conf]: /etc/kubernetes/kubelet.conf already exists
#    [ERROR Port-10250]: Port 10250 is in use
#    [ERROR FileAvailable--etc-kubernetes-pki-ca.crt]: /etc/kubernetes/pki/ca.crt already exists
#
# 2. Run the following commands to reset the node:
#    sudo kubeadm reset -f
#    sudo systemctl stop kubelet
#    sudo systemctl stop docker
#    sudo systemctl stop docker.socket   # <--- Add this line if 'docker.socket' is still active
#    sudo rm -rf /etc/kubernetes
#    sudo rm -rf /var/lib/kubelet/*
#    sudo systemctl start docker
#    sudo systemctl start kubelet
#
# 3. Then, re-run the kubeadm join command.
#
# 4. If port 10250 is still in use, check for running kubelet processes:
#    sudo lsof -i :10250
#    sudo kill <PID>
#
# 5. After cleanup, try joining the cluster again.
#############################################################
