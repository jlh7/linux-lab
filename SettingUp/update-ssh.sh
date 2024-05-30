#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Nothing happen..."
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
head -n +2 /etc/ssh/sshd_config >./tmp
echo "Port 5222" >>./tmp
echo "AllowUsers $_user" >>./tmp
cat ./tmp >/etc/ssh/sshd_config

echo "- Restart..."
systemctl restart ssh
systemctl enable ssh --now

echo "...Done"
