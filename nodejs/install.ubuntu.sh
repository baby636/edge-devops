## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/nodejs/install.ubuntu.sh | bash

echo "Running: $BURL/nodejs/install.ubuntu.sh"

# Install NodeJS/NPM LTS
echo "Installing NodeJS/NPM..."
curl -fsSL https://deb.nodesource.com/setup_14.x | bash
apt-get install -y nodejs

# Install development tools for native addons
sudo apt-get install -y gcc g++ make

# Install yarn
echo "Installing Yarn..."
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install -y yarn

# Install PM2
echo "Installing PM2..."
npm i -g pm2

# Setup PM2 to resurrect on startup
echo "Setting up PM2 startup..."
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u edgy --hp /home/edgy
