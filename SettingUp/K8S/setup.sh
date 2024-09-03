#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root mode"
  exit 1
fi

echo "Setting up before install k8s..."

echo "- Turn off swap..."
sed -i '$ d' /etc/fstab
swapoff -a

echo "- Config containerd..."
echo "overlay" >>/etc/modules-load.d/containerd.conf
echo "br_netfilter" >>/etc/modules-load.d/containerd.conf

modprobe overlay
modprobe br_netfilter

echo "net.bridge.bridge-nf-call-iptables = 1" >>/etc/sysctl.d/99-kubernetes-cri.conf
echo "net.bridge.bridge-nf-call-ip6tables = 1" >>/etc/sysctl.d/99-kubernetes-cri.conf
echo "net.ipv4.ip_forward = 1" >>/etc/sysctl.d/99-kubernetes-cri.conf

sudo sysctl --system
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Restart containerd..."
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
echo "------------------------------------------ DONE ------------------------------------------"

echo "Installing k8s..."

echo "- Add K8S's official GPG key"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" >>/etc/apt/sources.list.d/kubernetes.list
apt update
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Installing k8s..."
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
echo "------------------------------------------ DONE ------------------------------------------"

_ip=''
if [ -z "$1" ]; then
  _ip=$(cat /etc/hosts | grep registry | awk '{printf $1}')
else
  _ip="$1"
fi

bash ./config.sh -ip $_ip

systemctl enable --now kubelet
echo "------------------------------------------ DONE ------------------------------------------"
