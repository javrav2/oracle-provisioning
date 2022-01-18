#!/bin/bash
# DB Server Installation
# Author		: Darryl Mendez 
# Date			: 9/1/2020
# Description   : Initial Revision
#                 Shell script for formatting and mounting of RAW EBS Devices and SWAP
devices="/dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm"
sudo cp /etc/fstab /etc/fstab.orig
sudo sed -i /swap/d /etc/fstab
echo "#Adding Automated New Mount Points"  >> /etc/fstab
for var in $(lsblk -d -n -o NAME)
do
   device=`sudo nvme id-ctrl -v /dev/"$var" | grep 0000 | awk -F' ' '{print $18}'  |  cut -c2-9`
   #echo $var $device
   if [ $device = /dev/sdf ];
   then
     echo "swap space"
     sudo mkswap /dev/$var
     sudo swapon /dev/$var
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
     sudo echo "UUID=$uuid swap swap defaults 0 0" >> /etc/fstab
   #oradb1
   elif [ $device = /dev/sdg ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /local/oradb1
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
     sudo echo "UUID=$uuid /local/oradb1 xfs defaults,noatime 0 2" >> /etc/fstab
   #oralg1
   elif [ $device = /dev/sdh ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /local/oralg1
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
	 sudo echo "UUID=$uuid /local/oralg1 xfs defaults,noatime 0 2" >> /etc/fstab
   #oralg2
   elif [ $device = /dev/sdi ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /local/oralg2
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
	 sudo echo "UUID=$uuid /local/oralg2 xfs defaults,noatime 0 2" >> /etc/fstab
   #ora_backup_dd_nfs
   elif [ $device = /dev/sdj ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /ora_backup_dd_nfs
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
	 sudo echo "UUID=$uuid /local/ora_backup_dd_nfs xfs defaults,noatime 0 2" >> /etc/fstab
   #orabin
   elif [ $device = /dev/sdk ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /local/orabin
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
	 sudo echo "UUID=$uuid /local/orabin xfs defaults,noatime 0 2" >> /etc/fstab
  #orabck
  elif [ $device = /dev/sdl ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /local/orabck
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
	 sudo echo "UUID=$uuid /local/orabck xfs defaults,noatime 0 2" >> /etc/fstab
   #oraarc
   elif [ $device = /dev/sdm ];
   then
     echo $device
     sudo mkfs -t xfs /dev/$var
     sudo mount /dev/$var /local/oraarc 
     uuid=`ls -l /dev/disk/by-uuid | grep $var | awk -F ' ' '{print $9}'`
     echo $uuid
	 sudo echo "UUID=$uuid /local/oraarc xfs defaults,noatime 0 2" >> /etc/fstab
   fi
done
