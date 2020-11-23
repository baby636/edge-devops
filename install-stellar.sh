# Install and setup Stellar Horizon server. Must have ssl certs in /etc/ssl/wildcard as
# server.crt, server.ca, and server.key.
# Install as user 'edgy'

## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-stellar.sh | bash

set -e
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-docker-bionic.sh | sudo bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nginx/install.sh | sudo bash
sudo mkdir -p /datadrive/stellar
sudo chown edgy:edgy /datadrive/stellar
sudo docker run --rm -d -p 8000:8000 -v "/datadrive/stellar:/opt/stellar" --name stellar stellar/quickstart --pubnet
