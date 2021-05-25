## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/auto-deploy/install.ubuntu.sh | bash

echo "Running: $BURL/auto-deploy/install.ubuntu.sh"

[ -z $PROJECT_DIR ] && echo "Missing PROJECT_DIR env for auto-deploy" >&2 && exit 1

# Install auto-deploy
autoDeployPath="/usr/local/bin/auto-deploy"
crontabPath="/etc/cron.d/auto-deploy_$(basename $PROJECT_DIR)"
crontabContent=$(cat <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
* * * * * edgy auto-deploy $PROJECT_DIR >> ~/auto-deploy.log
EOF
)

echo "Installing auto-deploy"
curl -s -o $autoDeployPath $BURL/auto-deploy/cmd
chmod 755 $autoDeployPath

echo "Adding crontab: $crontabPath"
echo "$crontabContent" > $crontabPath
