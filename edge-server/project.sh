## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/edge-server/project.sh | bash

echo "Running: $BURL/edge-server/project.sh"

# Recommended to be run as edgy user

# Clone
echo "Cloning $PROJECT_URL..."
mkdir ~/apps
cd ~/apps
git clone $PROJECT_URL

# Install
echo "Installing $PROJECT_URL..."
cd $(basename $PROJECT_URL .git)
yarn

# Start processes
echo "Starting $PROJECT_URL..."
pm2 start pm2.json

# Save PM2 state for reboot resurrection
pm2 save