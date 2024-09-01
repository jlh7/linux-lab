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
  exit 1
fi

if [ -z "$_user" ]; then
  echo "Please provide username (-u) as an argument when running the script"
  exit 1
fi

echo "Updating profile..."
echo "- Set color..."
echo "PS1='\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[00m\]\$ '" >>"/home/$_user/.bashrc"
sudo $(echo "PS1='\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[00m\]\$ '" >>"/root/.bashrc")
source ~/.bashrc

echo "- Set screen resolution..."
vim ./grub.cfg
sudo cat ./grub.cfg >>/etc/default/grub
sudo update-grub

echo "- Set fontsize..."
vim ./console-setup.cfg
sudo cat ./console-setup.cfg >/etc/default/console-setup
sudo update-initramfs -u

echo "- Sudo without password..."
sudo echo "$_user ALL=(ALL:ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$_user"

echo "- Use ntp to update time..."
sudo timedatectl set-timezone Asia/Ho_Chi_Minh
sudo apt install ntp -y
sudo systemctl start ntp
echo "------------------------------------------ DONE ------------------------------------------"
