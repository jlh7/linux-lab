#!/bin/bash

if [ $(id -u) -eq 0 ]; then
  if [ -n "$1" ]; then
    _host=''
    _ip=''
    _numNode=0
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
      --num-node)
        _numNode=$2
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
      echo '--num-node <number of node>'
      echo 'At least it must be provided hostname and network ip'
    elif [ -n "$_host" ] && [ -n "$_ip" ]; then

      echo "Updating node..."

      hostnamectl set-hostname $_host

      echo "- Set host..."
      tail -n 5 /etc/hosts >./tmp.txt

      tee <<EOF >/etc/hosts
127.0.0.1  localhost
127.0.1.1  $_host

EOF

      echo "$_ip  $_host" >>/etc/hosts

      if ((_numNode > 0)); then
        for ((i = 1; i <= $_numNode; i++)); do
          echo "$(echo $_ip)$i  node-$i" >>/etc/hosts
        done
      fi

      cat ./tmp.txt >>/etc/hosts
      rm ./tmp.txt

      tee <<EOF >/etc/netplan/50-cloud-init.yaml
network:
    ethernets:
        enp0s3:
            dhcp4: true
        enp0s8:
            dhcp4: false
            addresses:
                - $_ip/24
    version: 2
EOF

      netplan apply
      echo "...Done"
    else
      if [ -z "$_host" ]; then
        echo "Please provide hostname (-h)"
      fi

      if [ -z "$_ip" ]; then
        echo "Please provide network ip (--ip)"
      fi
    fi
  else
    echo "Nothing happen..."
  fi
else
  echo "Please use in root mode"
fi
