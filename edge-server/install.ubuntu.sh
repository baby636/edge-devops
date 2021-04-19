## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/edge-server/install.ubuntu.sh | bash

echo "Running: $BURL/edge-server/install.ubuntu.sh"

# Install edge server
echo "Installing $PROJECT_URL as edgy user..."
sudo -i -u edgy bash -c "$ENV_EXPORTS; bash <(curl -o- \"$BURL/edge-server/project.sh\")"
