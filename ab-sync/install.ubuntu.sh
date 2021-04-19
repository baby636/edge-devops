## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/ab-sync/install.ubuntu.sh | bash

echo "Running: $BURL/ab-sync/install.ubuntu.sh"

# Install ab-sync util
echo "Installing ab-sync..."
curl -L "https://github.com/EdgeApp/edge-sync-server/raw/master/shared-bin/ab-sync" -o /usr/local/bin/ab-sync
chmod 755 /usr/local/bin/ab-sync

# Install libgit2 util
echo "Installing libgit2..."
curl -L "https://github.com/EdgeApp/edge-sync-server/raw/master/shared-bin/libgit2.so.23" -o /usr/local/lib/libgit2.so.23
chmod 755 /usr/local/lib/libgit2.so.23
ldconfig
