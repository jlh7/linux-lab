#!/bin/bash

if [ $(id -u) -eq 0 ]; then
  echo "Setting up before install k8s..."

  echo "- Turn off swap..."
  sed -i '$ d' /etc/fstab
  swapoff -a

  echo "- Config containerd..."
  tee <<EOF >>/etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

  modprobe overlay
  modprobe br_netfilter

  tee <<EOF >>/etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

  sudo sysctl --system &>/dev/null

  containerd config default >/etc/containerd/config.toml
  sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
  systemctl restart containerd
  systemctl enable containerd &>/dev/null

  echo "...Done"

  echo "Installing k8s..."

  echo "- Add K8S's official GPG key"
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  tee <<EOF >>/etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF

  apt update &>/dev/null

  echo "- Installing k8s..."
  apt install -y kubelet kubeadm kubectl &>/dev/null
  apt-mark hold kubelet kubeadm kubectl &>/dev/null

  systemctl enable --now kubelet &>/dev/null

  echo "...Done"
else
  echo "Please use in root mode"
fi
