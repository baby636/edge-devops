# Run from another computer to install
# curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | bash
# or
# wget -qO- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | bash 
sudo apt-get update -y
sudo apt-get install -y nagios-nrpe-server nagios-plugins

git clone https://github.com/EdgeApp/edge-devops.git
sudo cp ./edge-devops/nagios/bin/check_sync_failed* /usr/lib/nagios/plugins/
sudo cp ./edge-devops/nagios/cfg/* /etc/nagios/nrpe.d
sudo /etc/init.d/nagios-nrpe-server restart
