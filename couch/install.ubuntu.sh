## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/couch/install.ubuntu.sh | bash

echo "Running: $BURL/couch/install.ubuntu.sh"

TLD=${TLD:-"edge.app"}
DNSNAME=$(hostname).${TLD}

echo "deb https://apache.bintray.com/couchdb-deb focal main" | sudo tee /etc/apt/sources.list.d/couchdb.list

# Couch:

sudo apt-get install -y gnupg ca-certificates
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61
sudo apt update -y

echo "Installing CouchDB..."

sudo apt install -y debconf-utils
echo "couchdb couchdb/adminpass password $COUCH_PASSWORD" | debconf-set-selections
echo "couchdb couchdb/adminpass_again password $COUCH_PASSWORD" | debconf-set-selections
echo "couchdb couchdb/nodename string couchdb@$(hostname)-int.$TLD" | debconf-set-selections
echo "couchdb couchdb/cookie string $COUCH_COOKIE" | debconf-set-selections
echo "couchdb couchdb/bindaddress string 0.0.0.0" | debconf-set-selections
echo "couchdb couchdb/mode select $COUCH_MODE" | debconf-set-selections
sudo apt install -y couchdb

sudo systemctl stop couchdb

# Add seedlist config if present
if [ -n $COUCH_SEEDLIST ]; then
  sudo echo "
[cluster]
  seedlist = $COUCH_SEEDLIST
" > /opt/couchdb/etc/local.d/clustering.ini
fi

# Use datadrive volume for couchdb logs
if [ -d "/datadrive"]; then
  if [ -d "/datadrive/couchdb/log" ]; then
    echo "Directory /datadrive/couchdb/log already exists." 
  else
    sudo mkdir -p /datadrive/couchdb/log
    sudo cp -a /var/log/couchdb/* /datadrive/couchdb/log/
    sudo chown -R couchdb:couchdb /datadrive/couchdb/log/
    sudo echo "
  [log]
  writer = file
  file = /datadrive/couchdb/log/couchdb.log
  level = info
  " > /opt/couchdb/etc/local.d/logging.ini
  fi
fi

# Change owner for all new couchdb config files
sudo chown couchdb:couchdb /opt/couchdb/etc/local.d/*

sudo systemctl restart couchdb

# Wait until couch is up
let tries=0
while [ $tries -lt 10 ]; do
  sleep 2
  curl "http://admin:$COUCH_PASSWORD@localhost:5984/_up"
  if [ $? = 0 ]; then
    break
  fi
  echo "CouchDB not ready. Retrying."
  ((++tries))
done

# Couch setup
curl -X PUT "http://admin:$COUCH_PASSWORD@localhost:5984/_users"
curl -X PUT "http://admin:$COUCH_PASSWORD@localhost:5984/_replicator"
curl -X PUT "http://admin:$COUCH_PASSWORD@localhost:5984/_global_changes"

# Add caddy file
sudo echo "
# CouchDB:
$DNSNAME:6984 {
  reverse_proxy localhost:5984
}
" > /etc/caddy/couch.caddy

sudo systemctl restart caddy
