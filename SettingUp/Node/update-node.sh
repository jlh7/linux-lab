#!/bin/bash

if [ $(id -u) -ne 0 ]; then
  echo "Please run as root mode"
  exit 1
fi

if [ -z "$1" ]; then
  echo '-h <hostname>'
  echo '--ip <network ip>'
  echo '--help for help'
  exit 1
fi

_host=''
_ip=''
_is_help=false

while [ -n "$1" ]; do
  case "$1" in
  -h)
    _host="$2"
    shift 1
    ;;
  --ip)
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
  echo '-h <hostname>'
  echo '--ip <network ip>'
  exit 1
fi

if [ -z "$_host" ] || [ -z "$_ip" ]; then
  if [ -z "$_host" ]; then
    echo "Please provide hostname (-h)"
  fi

  if [ -z "$_ip" ]; then
    echo "Please provide network ip (--ip)"
  fi
  exit 1
fi

echo "Updating node..."

hostnamectl set-hostname $_host

echo "- Set host from file hosts..."

cat ./hosts.txt >/etc/hosts

echo "network:" >/etc/netplan/01-netcfg.yaml
echo "  ethernets:" >>/etc/netplan/01-netcfg.yaml
echo "    enp0s3:" >>/etc/netplan/01-netcfg.yaml
echo "      dhcp4: true" >>/etc/netplan/01-netcfg.yaml
echo "    enp0s8:" >>/etc/netplan/01-netcfg.yaml
echo "      dhcp4: false" >>/etc/netplan/01-netcfg.yaml
echo "      addresses:" >>/etc/netplan/01-netcfg.yaml
echo "        - $_ip/24" >>/etc/netplan/01-netcfg.yaml
echo "  version: 2" >>/etc/netplan/01-netcfg.yaml

netplan apply
echo "------------------------------------------ DONE ------------------------------------------"
reboot
