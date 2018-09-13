## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-sync-digitalocean.sh | bash

echo "Stopping CouchDB in case it's running"
sudo systemctl stop couchdb
sleep 4
set -e
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-digitalocean.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-azure.sh | sudo bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/sync/install.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | sudo bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-aliases.sh | bash
