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
vim /home/$_user/.bashrc
cat /home/$_user/.bashrc >"/root/.bashrc"
echo "PS1='\[\033[01;32m\]\u\[\033[01;37m\]@\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[00m\]\$ '" >>"/home/$_user/.bashrc"
sudo echo "PS1='\[\033[01;33m\]\h\[\033[01;31m\]:\[\033[01;36m\] \w\n\[\033[00m\]\$ '" >>"/root/.bashrc"
source ~/.bashrc

echo "- Set screen resolution..."
cat ./grub.cfg >> "/etc/default/grub"
vim /etc/default/grub
update-grub

echo "- Set fontsize..."
vim /etc/default/console-setup
update-initramfs -u

echo "- Sudo without password..."
echo "$_user ALL=(ALL:ALL) NOPASSWD: ALL" >"/etc/sudoers.d/$_user"

echo "- Use ntp to update time..."
timedatectl set-timezone Asia/Ho_Chi_Minh
apt install ntp -y
systemctl start ntp
echo "------------------------------------------ DONE ------------------------------------------"
