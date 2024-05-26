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
