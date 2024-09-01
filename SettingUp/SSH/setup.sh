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

echo "Update ssh..."

echo "- Config..."
vim ./sshd.cfg
sudo cat ./sshd.cfg >/etc/ssh/sshd_config.d/override.conf

echo "- Restart..."
sudo systemctl restart ssh
sudo systemctl enable ssh --now
echo "------------------------------------------ DONE ------------------------------------------"
