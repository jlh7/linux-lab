#!/bin/bash

if [ $(id -u) -eq 0 ]; then
  if [ -n "$1" ]; then
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
    elif [ -n "$_user" ]; then
      echo "Update ssh..."

      echo "- Config..."
      tee <<EOF >>/etc/ssh/sshd_config
Port 22022
AllowUsers $_user
EOF

      systemctl restart ssh
      systemctl enable ssh &>/dev/null

      echo "...Done"

    else
      echo "Please provide username (-u)"
    fi
  else
    echo "Nothing happen..."
  fi
else
  echo "Please use in root mode"
fi
