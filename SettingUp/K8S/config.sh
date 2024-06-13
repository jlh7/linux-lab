#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root mode"
  exit 1
fi

if [ -z "$1" ]; then
  echo '-ip <ip registry>'
  echo '--help for help'
  exit 1
fi

_ip=''
_is_help=false

while [ -n "$1" ]; do
  case "$1" in
  -ip)
    _ip="$2"
    shift 1
    ;;
  --help)
    _is_help=true
    break
    ;;
  *)
    echo "'$1' is valid!"
    ;;
  esac
  shift 1
done

if [ "$_is_help" = true ]; then
  echo '-ip <ip registry>'
  exit 1
fi

if [ -z "$_ip" ]; then
  echo 'Please provide ip registry'
  exit 1
fi

sed -i 's|config_path = \"\"|config_path = \"/etc/containerd/certs.d\"|g' /etc/containerd/config.toml

mkdir -p /etc/containerd/certs.d
p=$(pwd)
cd /etc/containerd/certs.d

mkdir -p "registry.k8s.io"
tee <<EOF >registry.k8s.io/hosts.toml
server = "https://registry.k8s.io"
[host."http://registry.k8s.io"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
EOF

mkdir -p "$_ip:55055"
tee <<EOF >"$_ip:55055/hosts.toml"
server = "https://$_ip:55055"
[host."http://$_ip:55055"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
EOF

cd $p
