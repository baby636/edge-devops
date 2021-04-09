## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/misc/user-security.sh | bash

# This will disable SSH access to root and edgy users.
# This script should only be run after misc/addusers.sh and password change
# for at least one administrative user.

echo 'DenyUsers root edgy' > /etc/ssh/sshd_config.d/disable_users.conf
systemctl restart sshd