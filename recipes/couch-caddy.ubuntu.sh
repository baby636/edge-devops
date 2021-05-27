## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/recipes/couch-caddy.ubuntu.sh | bash

echo "Running: $BURL/recipes/couch-caddy.ubuntu.sh"

# Collect input

if [[ -z $COUCH_MODE ]]; then
  read -p $'CouchDB cluster mode? (y/n): \n\r' answer
  case $answer in
    y|Y|yes) export COUCH_MODE=clustered ;;
    *) export COUCH_MODE=standalone ;;
  esac
fi
if [[ -z $COUCH_PASSWORD ]]; then
  read -s -p $'Enter CouchDB password: \n\r' COUCH_PASSWORD
  export COUCH_PASSWORD
fi
if [[ $COUCH_MODE == 'clustered' ]] && [[ -z $COUCH_COOKIE ]]; then
  read -s -p $'Enter CouchDB master cookie: \n\r' COUCH_COOKIE
  export COUCH_COOKIE
fi
if [[ $COUCH_MODE == 'clustered' ]] && [[ -z $COUCH_SEEDLIST ]]; then
  read -s $'Enter CouchDB cluster seedlist: \n\r' COUCH_SEEDLIST
  export COUCH_SEEDLIST
fi

curl -o- $BURL/datadrive/install.ubuntu.sh | bash
curl -o- $BURL/misc/install-aliases.sh | bash
curl -o- $BURL/caddy/install.ubuntu.sh | bash
curl -o- $BURL/couch/install.ubuntu.sh | bash
curl -o- $BURL/misc/addusers.sh | bash