#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Please run as root mode"
    exit 1
fi

if [ -z "$1" ]; then
    echo '-u <username>'
    echo '-h <hostname>'
    echo '--help for help'
    exit 1
fi

_user=''
_host=''
_is_help=false

while [ -n "$1" ]; do
    case "$1" in
    -u)
        _user="$2"
        shift 1
        ;;
    -h)
        _host="$2"
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
    echo '-h <hostname>'
    exit 1
fi

if [ -z "$_user" ]; then
    echo "Please provide username (-u) as an argument when running the script"
    exit 1
fi

if [ -z "$_host" ]; then
    echo "Please provide hostname (-h) as an argument when running the script"
    exit 1
fi

clear
##################### Update
echo "Updating system..."

echo "- Updating..."
apt update
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Upgrading..."
apt full-upgrade -y
echo "------------------------------------------ DONE ------------------------------------------"

##################### Profile
bash ./Profile/setup.sh -u $_user

##################### Network
bash ./Network/setup.sh -h $_host

##################### SSH
bash ./SSH/setup.sh -u $_user

##################### Docker
bash ./Docker/setup.sh -u $_user

##################### K8S
bash ./K8S/setup.sh -u $_user
