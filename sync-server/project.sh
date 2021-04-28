## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/sync-server/project.sh | bash

echo "Running: $BURL/sync-server/project.sh"

# Recommended to be run as edgy user

# Clone
echo "Cloning edge-sync-server..."
mkdir ~/apps
cd ~/apps
git clone https://github.com/EdgeApp/edge-sync-server.git

# Install
echo "Installing edge-sync-server..."
cd edge-sync-server
yarn

# Start processes
echo "Starting edge-sync-server..."
pm2 start pm2.json

# Save PM2 state for reboot resurrection
pm2 save