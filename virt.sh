#!/bin/bash
clear

# Internet checking functionality
function check_connectivity() {
    local test_ip
    local test_count
    test_ip="8.8.8.8"
    test_count=1
    if ping -c ${test_count} ${test_ip} 2> /dev/null; then
       echo "Connected to the internet"
    else
       echo "Connect to the internet and please try again"
       exit
    fi
}

function make_static_host(){
	local INTERFACE_FILE="/etc/network/interfaces"
	if [ -f "$INTERFACE_FILE.original" ]
	then
		echo "Backup exists"
	else
		cp $INTERFACE_FILE $INTERFACE_FILE.original
	fi

	echo "auto lo
iface lo inet loopback
iface ${interface} inet manual
auto vmbr0
iface vmbr0 inet static
        address  ${IP}
        netmask  ${SUBNET}
        gateway  ${GATEWAY}
	bridge-ports ${INTERFACE}
	bridge-stp off
        bridge-fd 0
        dns-nameservers ${GATEWAY}"  > /etc/network/interfaces
	service networking restart
}

# Check for internet
check_connectivity

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

# Define HOST
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

# Set IP Address
OBTAINED_IP=$(ifconfig $interface | grep inet | awk '{print $2}')
IP=""
echo "Enter Static IP for the host ($interface -> $OBTAINED_IP) : "
read IP
if [ -z "$IP" ]
then
	IP="192.168.5.12"
fi

# Set Net Mask
NETMASK=""
echo "Enter Netmask : "
read NETMASK

# Set Gateway 
echo "Enter Gateway : "
read GATEWAY 

make_static_host

# Write HOST file
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
# sed -i "/${IP}	${HOST}/d" $HOST_FILE

# Installation
apt update > /dev/null && apt upgrade -y > /dev/null

echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/virt-repo.list

wget http://download.proxmox.com/debian/proxmox-ve-release-6.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-6.x.gpg

apt update -y > /dev/null && apt dist-upgrade -y > /dev/null

apt install -y proxmox-ve postfix open-iscsi > /dev/null
