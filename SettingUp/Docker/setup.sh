#!/bin/bash

if [ -z "$1" ]; then
  echo '-u <username>'
  echo '--help for help'
  exit 1
fi

_user=''
_is_help=false

while [ -n "$1" ]; do
  case "$1" in
  -u)
    _user="$2"
    shift 1
    ;;
  --help)
    _is_help=true
    ;;
  *)
    echo "'$1' is valid!"
    ;;
  esac
  shift 1
done

if [ "$_is_help" = true ]; then
  echo '-u <username>'
  exit 1
fi

if [ -z "$_user" ]; then
  echo "Please provide username (-u) as an argument when running the script"
  exit 1
fi

echo "Installing docker..."

echo "- Add Docker's official GPG key"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "- Add the repository to Apt sources"
sudo mkdir -p /etc/apt/sources.list.d
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(sudo . /etc/os-release && sudo echo "$VERSION_CODENAME") stable" >>/etc/apt/sources.list.d/docker.list
full-update-system
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Installing docker..."
sudo apt install docker-ce -y
echo "------------------------------------------ DONE ------------------------------------------"

echo "Setting up docker..."

echo "- Setting dockerd..."
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo chmod a+rw -R /etc/systemd/system/docker.service.d
cat ./override.cfg >/etc/systemd/system/docker.service.d/override.conf

echo "- Restart docker..."
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Add user to docker..."
sudo usermod -aG docker $_user

echo "------------------------------------------ DONE ------------------------------------------"
