set -e
## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-sync-azure.sh | sudo bash

curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-adduser.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-azure.sh | sudo bash
sudo mkdir -p /datadrive/repos
sudo chown bitz:bitz /datadrive/repos
mkdir -p /home/bitz/www
sudo -u bitz ln -s /datadrive/repos /home/bitz/www/repos
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/sync/install.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | sudo bash
