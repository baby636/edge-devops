## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/sync-server/install.ubuntu.sh | bash

echo "Running: $BURL/sync-server/install.ubuntu.sh"

# Install NodeJS environment
curl -o- $BURL/nodejs/install.ubuntu.sh | bash

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
sudo -i -u edgy bash -c "export BURL=$BURL; export COUCH_PASSWORD=$COUCH_PASSWORD; bash <(curl -o- \"$BURL/sync-server/project.sh\")"
