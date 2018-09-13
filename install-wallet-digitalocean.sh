## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-wallet-digitalocean.sh | bash

set -e
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/addusers.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-digitalocean.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/wallet/install.sh | bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/nagios/install.sh | sudo bash
curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-aliases.sh | bash
