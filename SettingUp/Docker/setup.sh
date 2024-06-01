#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root mode"
  exit 1
fi

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
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "- Add the repository to Apt sources"
mkdir -p /etc/apt/sources.list.d
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" >>/etc/apt/sources.list.d/docker.list
apt update
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Installing docker..."
apt install docker-ce -y
echo "------------------------------------------ DONE ------------------------------------------"

echo "Setting up docker..."

echo "- Setting dockerd..."
mkdir -p /etc/systemd/system/docker.service.d
chmod a+rw -R /etc/systemd/system/docker.service.d
cat ./override.cfg >/etc/systemd/system/docker.service.d/override.conf

echo "- Restart docker..."
systemctl daemon-reload
systemctl restart docker
systemctl enable docker
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Add user to docker..."
usermod -aG docker $_user

echo "------------------------------------------ DONE ------------------------------------------"
