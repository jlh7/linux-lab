#!/bin/bash

if [ $(id -u) -eq 0 ]; then
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Please provide username and network id"
    else
        clear
        ##################### Update
        echo "Updating system..."
        sleep 1

        echo "- Updating..."
        tee >/dev/null <<EOF
    $(apt update)
EOF

        echo "- Upgrading..."
        tee >/dev/null <<EOF
    $(apt full-upgrade -y)
EOF

        echo "...Done"
        sleep 1
        clear

        ##################### Profile
        echo "Updating profile..."
        sleep 1

        echo "- Set color..."
        tee >>"/home/$1/.bashrc" <<EOF
PS1='\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[01;37m\]\$ '
EOF

        tee >>~/.bashrc <<EOF
PS1='\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[01;37m\]\$ '
EOF
        source ~/.bashrc

        echo "- Sudo without password..."
        echo "$1 ALL=(ALL:ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$1"

        echo "- Use ntp to update time..."
        tee >/dev/null <<EOF
    $(apt install ntp -y)
EOF
        systemctl start ntp

        echo "- Set host..."
        tee >>/etc/hosts <<EOF
$(echo $2) sample-node
$(echo $2)1 node-a
$(echo $2)2 node-b
$(echo $2)3 node-c
EOF

        echo "- Set netplan..."
        tee >/etc/netplan/50-cloud-init.yaml <<EOF
network:
    ethernets:
        enp0s3:
            dhcp4: true
        enp0s8:
            dhcp4: false
            addresses:
                - $(echo $2)/24
#               - $(echo $2)1/24
#               - $(echo $2)2/24
#               - $(echo $2)3/24
    version: 2
EOF

        netplan apply

        echo "...Done"
        sleep 1
        clear

        ##################### SSH
        echo "Update ssh..."
        sleep 1

        echo "- Config..."
        tee >>/etc/ssh/sshd_config <<EOF
Port 22022
AllowUsers $1
EOF

        systemctl restart ssh
        systemctl enable ssh

        echo "...Done"
        sleep 1
        clear

        ##################### Docker
        echo "Installing docker..."
        sleep 1

        echo "- Installing service..."
        tee >/dev/null <<EOF
    $(apt install -y apt-transport-https ca-certificates curl gpg)
EOF

        echo "- Add Docker's official GPG key"
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc

        echo "- Add the repository to Apt sources"
        tee >>/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF

        tee >/dev/null <<EOF
    $(apt update)
EOF
        echo "- Installing docker..."
        tee >/dev/null <<EOF
    $(apt install docker-ce -y)
EOF

        echo "...Done"
        sleep 1
        clear

        echo "Setting up docker..."
        sleep 1

        echo "- Setting dockerd..."
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

        echo "- Add user to docker..."
        usermod -aG docker $1

        echo "...Done"
        sleep 1
        clear

        ##################### K8S

        echo "Setting up before install k8s..."
        sleep 1

        echo "- Turn off swap..."
        sed -i '$ d' /etc/fstab
        swapoff -a

        echo "- Config containerd..."
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

        echo "...Done"
        sleep 1
        clear

        echo "Installing k8s..."
        sleep 1

        echo "- Add K8S's official GPG key"
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

        tee >>/etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF

        tee >/dev/null <<EOF
    $(apt update)
EOF

        echo "- Installing k8s..."
        tee >/dev/null <<EOF
    $(apt install -y kubelet kubeadm kubectl)
    $(apt-mark hold kubelet kubeadm kubectl)
EOF

        systemctl enable --now kubelet

        echo "...Done"
        sleep 1
        clear

        reboot
    fi
else
    echo "Please use in root mode"
fi
