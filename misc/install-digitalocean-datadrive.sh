## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/misc/install-digitalocean-datadrive.sh | bash


### Mount Disk

sudo umount /datadrive || echo "Already unmounted"
sudo umount /dev/sda || echo "Already unmounted"

if grep -q "datadrive" /etc/fstab; then
  echo "fstab already has datadrive"
else
  echo "Modifying fstab"
  sudo echo "/dev/sda /datadrive ext4 defaults,nofail,discard 0 0" >> /etc/fstab
fi
sudo mkdir -p /datadrive
sudo mount /datadrive
curl -sSL https://repos.insights.digitalocean.com/install.sh | sudo bash