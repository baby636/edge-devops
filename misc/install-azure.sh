### Mount Disk

sudo umount /datadrive
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk /dev/sdc ${TGTDEV}
  d # delete partition
  n # new partition
  p # primary partition
    # partition number 1
    # default - start at beginning of disk 
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

set -e
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir -p /datadrive
sudo mount /dev/sdc1 /datadrive
if grep -q "datadrive" /etc/fstab
then
  sudo sed -i '$ d' /etc/fstab
fi
sudo rm -f fstab
sudo sh -c blkid | sudo tail -1 | sudo awk -F '"' '{print $2}' | awk '{print "UUID=\""$1"\"   /datadrive   ext4   defaults   1   2"}' > ~/fstab
sudo sh -c 'cat ~/fstab >> /etc/fstab'
sudo umount /datadrive
sudo mount /datadrive
sudo chmod 775 /datadrive/
sudo chown ${USER}.${USER} /datadrive/
df -BG
