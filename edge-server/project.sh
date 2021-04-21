## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/edge-server/project.sh | bash

echo "Running: $BURL/edge-server/project.sh"

# Recommended to be run as edgy user

# Clone
gitUrl="https://github.com/EdgeApp/$PROJECT.git"
echo "Cloning $gitUrl..."
mkdir ~/apps
cd ~/apps
git clone $gitUrl

# Install
echo "Installing $PROJECT..."
cd $PROJECT
yarn

# Start processes
echo "Starting $PROJECT..."
pm2 start pm2.json

# Save PM2 state for reboot resurrection
pm2 save