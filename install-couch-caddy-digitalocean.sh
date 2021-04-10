## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/install-couch-caddy-digitalocean.sh | bash

echo "Running: $BURL/install-couch-caddy-digitalocean.sh"

echo "Stopping CouchDB in case it's running"
sudo systemctl stop couchdb
sleep 4
set -e
curl -o- $BURL/misc/install-digitalocean-datadrive.sh | bash
curl -o- $BURL/misc/install-aliases.sh | bash
curl -o- $BURL/misc/install-couch-caddy.sh | bash
curl -o- $BURL/misc/addusers.sh | bash
