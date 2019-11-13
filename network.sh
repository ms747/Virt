#!/bin/bash
cp /etc/network/interfaces /etc/network/interfaces.original
echo "auto lo
iface lo inet loopback

iface eno2 inet manual

iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
        address  192.168.100.100
        netmask  255.255.255.0
        gateway  192.168.1.1
        bridge-ports eno2
        bridge-stp off
        bridge-fd 0
        dns-nameservers 192.168.1.1

auto vmbr1
iface vmbr1 inet static
        address  10.10.10.10
        netmask  255.255.255.0
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0"  >> /etc/network/interfaces
        
mv /etc/hosts /etc/hosts.original
        
echo "127.0.0.1 localhost.localdomain localhost
192.168.100.100 ldmc.local ldmc
192.168.100.200 pubstorage.ldmc.local
10.10.10.99 pvtstorage.ldmc.local
# The following lines are desirable for IPv6 capable hosts

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts" >> /etc/hosts