#!/bin/bash


#  Setup K8-Cluster using kubeadm [K8 Version-->1.28.1]
### 1. Update System Packages [On Master & Worker Node]
sudo apt-get update -y
sudo apt-get upgrade -y

### 2. Install Docker[On Master & Worker Node]
if ! command -v docker &> /dev/null; then
    sudo apt install docker.io -y
    sudo chmod 666 /var/run/docker.sock
else
    echo "Docker already installed, skipping installation."
fi

### 3. Install Required Dependencies for Kubernetes[On Master & Worker Node]
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo mkdir -p -m 755 /etc/apt/keyrings

### 4. Add Kubernetes Repository and GPG Key[On Master & Worker Node]
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

### 5. Update Package List[On Master & Worker Node]
sudo apt update -y
sudo apt upgrade -y

### 6. Install Kubernetes Components[On Master & Worker Node]
if ! command -v kubeadm &> /dev/null; then
    sudo apt install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1
else
    echo "Kubernetes components already installed, skipping installation."
fi

### 7. [RESET] Clean up any previous Kubernetes cluster (if needed)
if [ -f /etc/kubernetes/admin.conf ]; then
    echo "Kubernetes cluster detected, resetting..."
    sudo kubeadm reset -f
    sudo systemctl stop kubelet
    sudo systemctl stop containerd
    sudo rm -rf /etc/cni/net.d
    sudo rm -rf /var/lib/etcd
    sudo rm -rf $HOME/.kube
    sudo systemctl start containerd
    sudo systemctl start kubelet
else
    echo "No existing Kubernetes cluster detected, skipping reset."
fi

### 8. Initialize Kubernetes Master Node [On MasterNode]
# Set POD_CIDR based on environment or argument
POD_CIDR="192.168.0.0/16"
if [ "$K8S_CLOUD" = "true" ]; then
    POD_CIDR="10.244.0.0/16"
fi

sudo kubeadm init --pod-network-cidr=$POD_CIDR
if [ $? -ne 0 ]; then
    echo "kubeadm init failed. Exiting."
    exit 1
fi

### 9. Configure Kubernetes Cluster [On MasterNode]
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Debug: Show kubeconfig server line
echo "Kubeconfig server entry:"
grep server $HOME/.kube/config

# Ensure kubelet is running
sudo systemctl restart kubelet

# Wait for API server to be available (up to 5 minutes)
echo "Waiting for Kubernetes API server to be available..."
for i in {1..60}; do
    export KUBECONFIG=$HOME/.kube/config
    kubectl get --raw='/healthz' &> /dev/null && break
    sleep 5
    if [ $i -eq 60 ]; then
        echo "Kubernetes API server is not available after 300 seconds. Showing pod status for debugging:"
        kubectl get pods -n kube-system
        echo "Exiting."
        exit 1
    fi
done

### 10. Deploy Networking Solution (Cilium) [On MasterNode]
CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CLI_VERSION}/cilium-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin
rm cilium-linux-amd64.tar.gz{,.sha256sum}

cilium install --version 1.15.4 --set kubeProxyReplacement=strict

cilium status --wait

### 11. Deploy Ingress Controller (NGINX) [On MasterNode]
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.49.0/deploy/static/provider/baremetal/deploy.yaml

### (Optional) Enable UFW and allow SSH and Kubernetes API port if UFW is installed and not enabled
if command -v ufw &> /dev/null; then
    if ! sudo ufw status | grep -q "Status: active"; then
        echo "Enabling UFW and allowing SSH and Kubernetes API port 6443..."
        sudo ufw allow ssh
        sudo ufw allow 6443/tcp
        sudo ufw --force enable
    else
        echo "UFW is already enabled. Ensuring port 6443 is allowed..."
        sudo ufw allow 6443/tcp
    fi
else
    echo "UFW is not installed. Skipping firewall configuration."
fi

kubeadm join 192.168.1.27:6443 --token mmm5s9.kukes4glnq8qlxdc --discovery-token-ca-cert-hash sha256:7e2038d75e23abeb03dd59100678c2d16d5ca471c1ccf9f29b31d50156a77393
