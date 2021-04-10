## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/install-couch-caddy-digitalocean-1604.sh | bash

echo "Running: $BURL/install-couch-caddy-digitalocean-1604.sh"

echo "Stopping CouchDB in case it's running"
sudo systemctl stop couchdb
sleep 4
set -e
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-digitalocean-datadrive.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-aliases.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-couch-caddy-1604.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/addusers-bitz.sh | bash
