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
            echo '--ip <network-ip>'
            echo '--num-node <number of node>'
        elif [ -n "$_user" ] && [ -n "$_ip" ]; then
            clear
            ##################### Update
            echo "Updating system..."

            echo "- Updating..."
            apt update &>/dev/null

            echo "- Upgrading..."
            apt full-upgrade -y &>/dev/null

            echo "...Done"

            ##################### Profile
            bash ./update-profile.sh -u $_user --ip $_ip --num-node $_numNode

            ##################### SSH
            bash ./update-ssh.sh -u $_user

            ##################### Docker
            bash ./update-docker.sh -u $_user

            ##################### K8S
            bash ./update-k8s.sh

            reboot

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
