set -e

## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/misc/install-pm2.sh | bash

echo "Running: $BURL/misc/install-pm2.sh"

sudo npm install pm2 -g