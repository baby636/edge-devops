## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/edge-server/install.ubuntu.sh | bash

echo "Running: $BURL/edge-server/install.ubuntu.sh"

# Install Couch/Caddy
curl -o- $BURL/couch-caddy/install.ubuntu.sh | bash

# Install NodeJS environment
curl -o- $BURL/nodejs/install.ubuntu.sh | bash

# Install edge server
echo "Installing $PROJECT as edgy user..."
sudo -i -u edgy bash -c "$ENV_EXPORTS; bash <(curl -o- \"$BURL/edge-server/project.sh\")"
