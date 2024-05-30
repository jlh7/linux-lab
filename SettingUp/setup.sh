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

clear
##################### Update
echo "Updating system..."

echo "- Updating..."
apt update

echo "- Upgrading..."
apt full-upgrade -y

echo "...Done"

##################### Profile
bash ./update-profile.sh -u $_user

##################### SSH
bash ./update-ssh.sh -u $_user

##################### Docker
bash ./update-docker.sh -u $_user

##################### K8S
bash ./update-k8s.sh
