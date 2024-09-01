#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Please run as root mode"
    exit 1
fi

_user=''
_host=''

while [ -z "$_user" ]; do
    echo -n "Please, input username:"
    read _user
done
while [ -z "$_host" ]; do
    echo -n "Please, input hostname:"
    read _host
done

date=$(date '+%H:%M:%S.%Y-%m-%d')

exec 3>&1
exec > >(tee -a /var/log/startUp.$date.log)

clear
##################### Update
echo "Updating system..."

echo "- Installing service..."
apt install -y vim apt-transport-https ca-certificates curl gpg systemd wget openssh-server openvswitch-switch-dpdk
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

##################### Network
cd Network
bash setup.sh -h $_host
cd ..

##################### Profile
cd Profile
bash setup.sh -u $_user
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

exec 1>&3

reboot
