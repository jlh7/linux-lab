#!/bin/bash

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

date=$(date '+%H:%M:%S.%Y-%m-%d')

# exec 3>&1
# exec > >(tee -a $date.log)

clear
##################### Update
echo "Updating system..."

echo "- Installing service..."
sudo apt install -y vim
echo "------------------------------------------ DONE ------------------------------------------"

vim ./sources.list
if [ $(cat sources.list | wc -l) -gt 0 ]; then
    rm -rf /etc/apt/sources.list.d/original.list
    cat ./sources.list >/etc/apt/sources.list
fi

cat <<EOF >/bin/full-update-system
#!/bin/bash
sudo apt update
sudo apt full-upgrade -y
sudo snap refresh
sudo apt remove -y
sudo apt autoclean -y
EOF
chmod +x /bin/full-update-system

echo "- Updating..."
sudo full-update-system
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Installing service..."
sudo apt install -y apt-transport-https ca-certificates curl gpg systemd wget openssh-server
echo "------------------------------------------ DONE ------------------------------------------"

##################### Profile
cd Profile
bash setup.sh -u $_user
cd ..

##################### Network
cd Network
bash setup.sh -h $_host
cd ..

##################### SSH
cd SSH
bash setup.sh -u $_user
cd ..

##################### Docker
cd Docker
bash setup.sh -u $_user
cd ..

##################### K8S
cd K8S
bash setup.sh
cd ..

echo "- Updating..."
sudo full-update-system
echo "------------------------------------------ DONE ------------------------------------------"

# exec 1>&3

reboot
