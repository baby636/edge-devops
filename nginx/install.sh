# Install and setup nginx to forward SSL requests to port 8000 on localhost
# Requirest SSL certs installed in /etc/ssl/wildcard using names server.crt, server.ca, and server.key

# curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nginx/install.sh | sudo bash

set -e

sudo apt-get update
sudo apt-get install nginx
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nginx/default > default
sudo cp -f default /etc/nginx/sites-enabled/default
sudo service nginx restart
