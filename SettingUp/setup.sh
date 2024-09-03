#!/bin/bash

if [ $(id -u) -ne 0 ]; then
    echo "Please run as root mode"
    exit 1
fi

_user=''
_host=''

while [ -z "$_user" ]; do
    echo -n "Please, input username: "
    read _user
done
while [ -z "$_host" ]; do
    echo -n "Please, input hostname: "
    read _host
done

clear
##################### Update
echo "Updating system..."

echo "- Installing service..."
apt install -y vim apt-transport-https ca-certificates curl gpg systemd wget openssh-server openvswitch-switch-dpdk
echo "------------------------------------------ DONE ------------------------------------------"

echo "- Adding repository..."
if [ ! -f /etc/apt/sources.list.d/original.list ]; then
    vim /etc/apt/sources.list
else
    vim /etc/apt/sources.list.d/original.list
fi

cat <<EOF >/bin/full-update-system
#!/bin/bash
sudo apt update
sudo apt full-upgrade -y
sudo snap refresh
sudo apt remove -y
sudo apt autoclean -y
sudo systemctl daemon-reload
EOF
chmod +x /bin/full-update-system

echo "- Updating..."
sudo full-update-system
echo "------------------------------------------ DONE ------------------------------------------"
sleep 3
clear

##################### Network
cd Network
bash setup.sh -h $_host
cd ..
sleep 3
clear

##################### Profile
cd Profile
bash setup.sh -u $_user
cd ..
sleep 3
clear

##################### SSH
cd SSH
bash setup.sh -u $_user
cd ..
sleep 3
clear

##################### Docker
cd Docker
bash setup.sh -u $_user
cd ..
sleep 3
clear

##################### K8S
cd K8S
bash setup.sh
cd ..
sleep 3
clear

echo "- Updating..."
sudo full-update-system
echo "------------------------------------------ DONE ------------------------------------------"
sleep 3
clear

reboot
