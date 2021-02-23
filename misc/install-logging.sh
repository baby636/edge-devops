## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-logging.sh | bash
set -e

read -s -p $'Enter Papertrail token: \n\r' TOKEN
wget -qO - --header="X-Papertrail-Token: $TOKEN" https://papertrailapp.com/destinations/2979474/setup.sh | sudo bash

if grep -q "PROMPT_COMMAND" /etc/bash.bashrc; then
  echo "/etc/bash.bashrc already has prompt command"
else
  echo "Modifying /etc/bash.bashrc"
  cat <<'--EOF' >> /etc/bash.bashrc
export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug "$(whoami) [$$]: $(history 1 | sed "s/^[ ]*[0-9]\+[ ]*//" ) [$RETRN_VAL]"'
--EOF
fi