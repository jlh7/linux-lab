#!/bin/bash

sudo -i

##################### Update
apt update
apt full-upgrade -y

clear

##################### Profile

tee >>/home/adm1n/.bashrc <<EOF
PS1='\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[01;37m\]\$ '
EOF

tee >>~/.bashrc <<EOF
PS1='\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[01;37m\]\$ '
EOF
source ~/.bashrc

echo 'adm1n ALL=(ALL:ALL) NOPASSWD: ALL' >/etc/sudoers.d/adm1n

tee >>/etc/hosts <<EOF
211.1.1.2 sample-node
211.1.1.21 node-a
211.1.1.22 node-b
211.1.1.23 node-c
EOF

tee >>/etc/netplan/50-cloud-init.yaml <<EOF
network:
    ethernets:
        enp0s3:
            dhcp4: true
        enp0s8:
            dhcp4: false
            addresses:
                - 211.1.1.2/24
#               - 211.1.1.21/24
#               - 211.1.1.22/24
#               - 211.1.1.23/24
    version: 2
EOF

clear

##################### SSH
tee >>/etc/ssh/sshd_config <<EOF
Port 22022
AllowUsers adm1n
EOF

systemctl restart ssh
systemctl enable ssh

clear

##################### Docker
apt install -y apt-transport-https ca-certificates curl gpg

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee >>/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF

apt update
apt install docker-ce -y

mkdir -p /etc/systemd/system/docker.service.d
tee >>/etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:43210
Restart=always
RestartSec=2
EOF

chmod a+rw -R /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker
systemctl enable docker

usermod -aG docker adm1n

clear

##################### K8S

sed -i '$ d' /etc/fstab
swapoff -a

tee >>/etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

tee >>/etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

tee >>/etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF

apt update

apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable --now kubelet

reboot
