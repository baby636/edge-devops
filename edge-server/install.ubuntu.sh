## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/edge-server/install.ubuntu.sh | bash

echo "Running: $BURL/edge-server/install.ubuntu.sh"

TLD=${TLD:-"edge.app"}
DNSNAME=$(hostname).${TLD}
HTTP_PORT=${HTTP_PORT:-"8008"}
PROJECT_NAME=$(basename $PROJECT_URL)

# Install edge server
echo "Installing $PROJECT_URL as edgy user..."
sudo -i -u edgy bash -c "$ENV_EXPORTS; bash <(curl -o- \"$BURL/edge-server/project.sh\")"

# Add caddy file
sudo echo "
# Main applications:
$DNSNAME {
  reverse_proxy localhost:$HTTP_PORT
}
" > /etc/caddy/$PROJECT_NAME.caddy

sudo systemctl restart caddy
