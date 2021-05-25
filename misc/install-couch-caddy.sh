## BURL=https://raw.githubusercontent.com/EdgeApp/edge-devops/master; curl -o- $BURL/misc/install-couch-caddy.sh | bash

echo "Running: $BURL/misc/install-couch-caddy.sh"

TLD=${TLD:-"edge.app"}
h=$(hostname)
dnsname=${h}.${TLD}

echo Installing as $dnsname

sudo apt-get install -y gnupg ca-certificates
echo "deb https://apache.bintray.com/couchdb-deb focal main" | sudo tee /etc/apt/sources.list.d/couchdb.list

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61

echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list

# Couch:

sudo apt update -y
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

# Use datadrive volume for couchdb data (deprecated)
# if [ -d "/datadrive/couchdb/data" ] 
# then
#     echo "Directory /datadrive/couchdb/data already exists." 
# else
#     sudo mkdir -p /datadrive/couchdb/data
#     sudo chown couchdb:couchdb /datadrive/couchdb/data
#     sudo cp -a /var/lib/couchdb/* /datadrive/couchdb/data/
#     sudo rm /opt/couchdb/data
#     sudo ln -s  /datadrive/couchdb/data /opt/couchdb/data
#     sudo chown couchdb:couchdb /opt/couchdb/data
# fi

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

# Caddy:

sudo apt install -y caddy

sudo echo "
# CouchDB:
$dnsname:6984 {
  reverse_proxy localhost:5984
}

# Main applications:
$dnsname {
  reverse_proxy localhost:8008
}
" > /etc/caddy/Caddyfile

sudo systemctl restart caddy
