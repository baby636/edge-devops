## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/caddy/install.ubuntu.sh | bash

echo "Running: $BURL/caddy/install.ubuntu.sh"

# Caddy:

echo "Installing caddy..."

echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list

sudo apt-get install -y gnupg ca-certificates
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61
sudo apt update -y

sudo apt install -y caddy

sudo echo "import /etc/caddy/*.caddy" > /etc/caddy/Caddyfile

sudo systemctl restart caddy
