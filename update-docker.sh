#!/bin/bash

if [ $(id -u) -eq 0 ]; then
  if [ -n "$1" ]; then
    _user=''

    while [ -n "$1" ]; do
      case "$1" in
      -u)
        _user="$2"
        shift 1
        ;;
      --help)
        echo '-u <username>'
        ;;
      *)
        echo "'$1' is valid!"
        ;;
      esac
      shift 1
    done

    if [ -n "$_user" ]; then
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
      apt install docker-ce -y &>/dev/null

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
      systemctl enable docker &>/dev/null

      echo "- Add user to docker..."
      usermod -aG docker $_user

      echo "...Done"
    else
      echo "Please provide username (-u)"
    fi
  else
    echo "Please provide username (-u)"
  fi
else
  echo "Please use in root mode"
fi
