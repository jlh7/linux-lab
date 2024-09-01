#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root mode"
  exit 1
fi

if [ -z "$1" ]; then
  echo '-h <hostname>'
  echo '--help for help'
  exit 1
fi

_host=''
_is_help=false

while [ -n "$1" ]; do
  case "$1" in
  -h)
    _host="$2"
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
  echo '-h <hostname>'
  exit 1
fi

if [ -z "$_host" ]; then
  echo "Please provide hostname (-h)"
  exit 1
fi

echo "Updating node..."

hostnamectl set-hostname $_host

vim ./hosts.cfg
vim ./50-cloud-init.yaml

echo "- Setting network from file ..."
cat ./hosts.cfg >/etc/hosts
rm -rf /etc/netplan/*.yaml
cp ./*.yaml /etc/netplan
chmod 600 /etc/netplan/*.yaml
sudo netplan apply
echo "------------------------------------------ DONE ------------------------------------------"
