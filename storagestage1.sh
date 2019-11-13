#!/bin/bash
sed -i.orginal "s/quiet/quiet intel_iommu=on/g" /etc/default/grub 2>/dev/null
update-grub
cp /etc/modules /etc/modules.original
echo "vfio
vfio_iommu_type1
vfio_pci
vfio_virqfd" >> /etc/modules
echo "find /sys/kernel/iommu_groups/ -type l" >> /root/checkhdd.sh