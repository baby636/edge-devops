# Run from another computer to install
# curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | bash
# or
# wget -qO- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | bash 
sudo apt-get update -y
sudo apt-get install -y nagios-nrpe-server nagios-plugins

git clone https://github.com/EdgeApp/edge-devops.git
sudo cp ./edge-devops/nagios/bin/check_sync_failed* /usr/lib/nagios/plugins/
sudo cp ./edge-devops/nagios/cfg/* /etc/nagios/nrpe.d

sudo chown root:root /usr/lib/nagios/plugins/check_disk
sudo chmod u+s /usr/lib/nagios/plugins/check_disk
sudo chmod o+x /usr/lib/nagios/plugins/check_disk

# Add status server IP address to allowed IPs
if [ -f /etc/nagios/nrpe.cfg.bak ]; then
  sudo cp -a /etc/nagios/nrpe.cfg.bak /etc/nagios/nrpe.cfg
else
  sudo cp -a /etc/nagios/nrpe.cfg /etc/nagios/nrpe.cfg.bak
fi
sudo sed -e "s/allowed_hosts=.*/allowed_hosts=127.0.0.1,138.197.219.166/g" /etc/nagios/nrpe.cfg > nrpe.cfg
sudo cp -a nrpe.cfg /etc/nagios/

sudo /etc/init.d/nagios-nrpe-server restart
