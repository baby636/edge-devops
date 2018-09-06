### Mount Disk

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk /dev/sdc ${TGTDEV}
  n # new partition
  p # primary partition
    # partition number 1
    # default - start at beginning of disk 
    # default, extend partition to end of disk
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF