#!/bin/bash
clear
# Get Interface
echo "Please Select your interface"
interface=""
values=$(ls /sys/class/net)
PS3="Select interface : "
select value in $values
do
	interface=$value
	break
done

HOST_FILE="/etc/hosts"
cp $HOST_FILE $HOST_FILE.scriptbackup

# Disable 127.0.1.1
sed -i.original -E "s/^(127.0.1.1)/#\1/g" $HOST_FILE

# Set Hostname
HOST=""
echo "Enter Hostname ($(hostname)) : "
read HOST
if [ -z "$HOST" ]
then
	HOST="msdt.local msdt"
fi

# Set Ipaddress
OBTAINED_IP=$(ifconfig $interface | grep inet | awk '{print $2}')
IP=""
echo "Enter Static IP for the host ($interface -> $OBTAINED_IP) : "
read IP
if [ -z "$IP" ]
then
	IP="192.168.5.12"
fi

sed -i.original "3i$IP	$HOST" $HOST_FILE
echo "Wrote to $HOST_FILE"

# Validate HOST
IP_FROM_HOST=$(hostname --ip-address)
echo "${IP_FROM_HOST} ${IP}"
if [ "${IP}" = "${IP_FROM_HOST}" ];
then
	echo "Works"
else
	echo "Something went wrong"
	exit
fi

# Reset HOST files
sed -i "/${IP}	${HOST}/d" $HOST_FILE

# Installation

echo "deb http://download.proxmox.com/debian/pve stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

wget http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-5.x.gpg

apt update -y && apt dist-upgrade -y

apt install -y proxmox-ve postfix open-iscsi
