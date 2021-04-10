## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/sync-server/install.sh | bash

echo "Running: $BURL/sync-server/install.sh"

# Install NodeJS/NPM LTS
echo "Installing NodeJS/NPM..."
curl -fsSL https://deb.nodesource.com/setup_14.x | bash
apt-get install -y nodejs

# Install yarn
echo "Installing Yarn..."
npm i -g yarn

# Install PM2
echo "Installing PM2..."
npm i -g pm2

# Install ab-sync util
echo "Installing ab-sync..."
curl -L "https://github.com/EdgeApp/edge-sync-server/raw/master/shared-bin/ab-sync" -o /usr/local/bin/ab-sync
chmod 755 /usr/local/bin/ab-sync

# Install libgit2 util
echo "Installing libgit2..."
curl -L "https://github.com/EdgeApp/edge-sync-server/raw/master/shared-bin/libgit2.so.23" -o /usr/local/lib/libgit2.so.23
chmod 755 /usr/local/lib/libgit2.so.23
ldconfig

# Install edge-sync-server
echo "Provisioning sync server as edgy user..."
sudo -i -u edgy bash -c "export COUCH_PASSWORD=$COUCH_PASSWORD; bash <(curl -o- \"https://raw.githubusercontent.com/EdgeApp/edge-devops/master/sync-server/project-install.sh\")"

# Setup PM2 to resurrect on startup
echo "Setting up PM2 startup..."
env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u edgy --hp /home/edgy