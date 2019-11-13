#!/bin/bash
# Post Install
cd /root
wget https://gansan.in/downloads/virt_logo.png
mv /usr/share/pve-manager/images/proxmox_logo.png /usr/share/pve-manager/images/proxmox_logo.png.original
mv /usr/share/pve-docs/ /usr/share/noshow/
cp /root/virt_logo.png /usr/share/pve-manager/images/proxmox_logo.png 2>/dev/null
sed -i.original "s/Proxmox VE Login/LCMC Login/g;s/Proxmox VE authentication server/Special/g" /usr/share/pve-manager/js/pvemanagerlib.js
sed -i.original "s/\[% nodename %\] - Proxmox Virtual Environment/LCMC - Virtual Enviornment/g" /usr/share/pve-manager/index.html.tpl
sed -i.original "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service
rm /root/virt_logo*
sed -i.original "s/Proxmox Virtual Environment/LCMC Virtual Server/g" /etc/default/grub
sed -i.original "s/Proxmox/LCMC/g" /usr/bin/pvebanner
sed -i.original "s/Proxmox/LCMC/g" /etc/issue
update-grub