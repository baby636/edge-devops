## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/edge-server/install.ubuntu.sh | bash

echo "Running: $BURL/edge-server/install.ubuntu.sh"

TLD=${TLD:-"edge.app"}
DNSNAME=$(hostname).${TLD}
HTTP_PORT=${HTTP_PORT:-"8008"}
PROJECT_NAME=$(basename $PROJECT_URL)

# SSH key file
echo "Adding SSH key to /home/edgy/.ssh/id_ed25519"
eval "$(ssh-agent)"
mkdir -p /home/edgy/.ssh
echo "Saving SSH Key to file:"
echo "$GITKEY" > /home/edgy/.ssh/id_ed25519
# Setting correct perms to add key
chmod 600 /home/edgy/.ssh/id_ed25519 
# Making pubkey for Github's identification of key
ssh-keygen -y -f /home/edgy/.ssh/id_ed25519 > /home/edgy/.ssh/id_ed25519.pub 
echo "Generated pub key: "
cat /home/edgy/.ssh/id_ed25519.pub
echo "Adding github.com to known hosts"
ssh-keyscan -t rsa github.com >> /home/edgy/.ssh/known_hosts
echo "Adding gitkey"
ssh-add /home/edgy/.ssh/id_ed25519
# Give .ssh to edgy user
chown -R edgy:edgy /home/edgy/.ssh

# Install edge server
echo "Installing $PROJECT_URL as edgy user..."
sudo -i -u edgy bash -c "$ENV_EXPORTS; bash <(curl -o- \"$BURL/edge-server/project.sh\")"

# Add caddy file
sudo echo "
# Main applications:
$DNSNAME {
  reverse_proxy localhost:$HTTP_PORT
}
" > /etc/caddy/$PROJECT_NAME.caddy
