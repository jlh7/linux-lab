#!/bin/bash

if [ $(id -u) -eq 0 ]; then
    if [ -n "$1" ]; then
        _user=''
        _ip=''
        _numNode=0

        while [ -n "$1"]; do
            case "$1" in
            -u)
                _user="$2"
                shift 1
                ;;
            --ip)
                _ip="$2"
                shift 1
                ;;
            --num-node)
                _numNode=$2
                shift 1
                ;;
            --help)
                echo '-u <username>'
                echo '--ip <network-ip>'
                echo '--num-node <number of node>'
                ;;
            *)
                echo "'$1' is valid!"
                ;;
            esac
            shift 1
        done

        if [ -n "$_user" ] && [ -n "$_ip"]; then
            clear
            ##################### Update
            echo "Updating system..."

            echo "- Updating..."
            apt update &>/dev/null

            echo "- Upgrading..."
            apt full-upgrade -y &>/dev/null

            echo "...Done"

            ##################### Profile
            echo "Updating profile..."

            echo "- Set color..."
            tee <<EOF >>"/home/$_user/.bashrc"
PS1='\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[01;37m\]\$ '
EOF

            tee <<EOF >>~/.bashrc
PS1='\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[01;37m\]\$ '
EOF
            source ~/.bashrc

            echo "- Sudo without password..."
            echo "$_user ALL=(ALL:ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$_user"

            echo "- Use ntp to update time..."
            apt install ntp -y &>/dev/null
            systemctl start ntp

            echo "- Set host..."
            tee >>/etc/hosts <<EOF
$(echo $_ip) sample-node
EOF
            if [ _numNode -gt 0 ]; then
                for ((i = 1; i <= $_numNode; i++)); do
                    echo "$(echo $_ip)$i node-$i" >>/etc/hosts
                done
            fi

            echo "- Set netplan..."
            tee >./tmp.txt <<EOF
network:
    ethernets:
        enp0s3:
            dhcp4: true
        enp0s8:
            dhcp4: false
            addresses:
                - $(echo $_ip)/24
EOF

            if [ _numNode -gt 0 ]; then
                for ((i = 1; i <= $_numNode; i++)); do
                    echo "#               - $(echo $_ip)$i/24" >>./tmp.txt
                done
            fi

            echo "    version: 2" >>./tmp.txt
            cat ./tmp.txt >/etc/netplan/50-cloud-init.yaml

            netplan apply

            echo "...Done"

            ##################### SSH
            echo "Update ssh..."

            echo "- Config..."
            tee <<EOF >>/etc/ssh/sshd_config
Port 22022
AllowUsers $_user
EOF

            systemctl restart ssh
            systemctl enable ssh

            echo "...Done"

            ##################### Docker
            echo "Installing docker..."

            echo "- Installing service..."
            apt install -y apt-transport-https ca-certificates curl gpg &>/dev/null

            echo "- Add Docker's official GPG key"
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc

            echo "- Add the repository to Apt sources"
            tee <<EOF >>/etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable
EOF

            apt update &>/dev/null
            echo "- Installing docker..."
            tee <<EOF >/dev/null
    $(apt install docker-ce -y)
EOF

            echo "...Done"

            echo "Setting up docker..."

            echo "- Setting dockerd..."
            mkdir -p /etc/systemd/system/docker.service.d
            tee <<EOF >>/etc/systemd/system/docker.service.d/override.conf
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
            usermod -aG docker $_user

            echo "...Done"

            ##################### K8S

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

            sudo sysctl --system

            containerd config default >/etc/containerd/config.toml
            sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
            systemctl restart containerd
            systemctl enable containerd

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

            systemctl enable --now kubelet

            echo "...Done"

            reboot

        else
            if [ -z "$_user" ]; then
                echo "Please provide username (-u)"
            fi

            if [ -z "$_ip" ]; then
                echo "Please provide network ip (--ip)"
            fi
        fi
    else
        echo "Please provide username (-u) and network ip (--ip)"
    fi
else
    echo "Please use in root mode"
fi
