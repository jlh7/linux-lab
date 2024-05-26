#!/bin/bash

if [ $(id -u) -eq 0 ]; then
  if [ -n "$1" ]; then
    _user=''
    _ip=''
    _numNode=0
    _is_help=false

    while [ -n "$1" ]; do
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
      echo '-u <username>'
      echo '--ip <network ip>'
      echo '--num-node <number of node>'
      echo 'At least it must be provided username and network ip'
    elif [ -n "$_user" ] && [ -n "$_ip" ]; then

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
    else
      if [ -z "$_user" ]; then
        echo "Please provide username (-u)"
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
