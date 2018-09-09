set -e

if [ ! -f env.sh ]; then
  echo '# Full DNS name of this machine (ie. git1.edge.app)
export host_name=""
# CouchDB admin password
export couchdb_admin_password=""
# CouchDB user password
export couchdb_user_password=""
# Seed server to synchronize with full URL. ie.
# https://username:password@git2.edge.app:6984
export seed_server=""' > env.sh
  echo '
  
  *** Please complete the created env.sh file and rerun install script ***
  
  '
  sudo chown bitz:bitz env.sh
  exit 1
fi

rm -rf /home/bitz/code
machine_name="$(echo ${host_name} | cut -d'.' -f1)"

source env.sh
if grep -q "${machine_name} ${host_name}" /etc/hosts
then
  sudo sed -i '$ d' /etc/hosts
fi

cp /etc/hosts hosts
echo "127.0.0.1 ${machine_name} ${host_name}" >> hosts
sudo cp hosts /etc/hosts
sudo echo ${machine_name} > hostname
sudo cp -a hostname /etc/hostname
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install ufw apache2 supervisor python-pip python-dev python-virtualenv libncurses5-dev vim git fail2ban libpq-dev postgresql-9.5 couchdb -y
sudo a2enmod rewrite proxy proxy_http proxy_html cgid ssl status xml2enc

## SSH key
chmod 600 ~/.ssh/id_ed25519

## Virtual ENV
rm -rf /home/bitz/airbitz
mkdir -p /home/bitz/airbitz
cd /home/bitz/airbitz
virtualenv ENV

## Clone code
rm -rf /home/bitz/code
mkdir -p /home/bitz/code
cd /home/bitz/code
git clone git@github.com:EdgeApp/airbitz-sync-server.git
git clone git@github.com:EdgeApp/edge-devops.git
rm -f /home/bitz/airbitz/ENV/airbitz
ln -s /home/bitz/code/airbitz-sync-server/syncserver /home/bitz/airbitz/ENV/airbitz

## Update virtual ENV
source /home/bitz/airbitz/ENV/bin/activate
pip install -r /home/bitz/code/airbitz-sync-server/staging/requirements.txt
# cd /home/bitz/code/airbitz-sync-server/syncserver
# python manage.py migrate auth
# python manage.py migrate

## Absync
cd /home/bitz
sudo rm -rf /etc/absync
sudo rm -f /usr/lib/libgit2*
sudo rm -f /usr/bin/ab-sync
sudo mkdir -p /etc/absync
sudo rsync -avz /home/bitz/code/airbitz-sync-server/staging/hooks /etc/absync/
sudo cp /home/bitz/code/airbitz-sync-server/staging/libgit2* /usr/lib
sudo cp /home/bitz/code/airbitz-sync-server/staging/ab-sync /usr/bin/ 
sudo echo '
[Servers]
servers=https://git2.airbitz.co/repos,https://git3.airbitz.co/repos' > absync.conf
sudo cp -a absync.conf /etc/absync/
sudo cp -a /home/bitz/code/airbitz-sync-server/staging/supervisord/* /etc/supervisor/conf.d/
sudo supervisorctl update

## Apache
if [ -f /etc/apache2/envvars.bak ]; then
  sudo cp -a /etc/apache2/envvars.bak /etc/apache2/envvars
else
  sudo cp -a /etc/apache2/envvars /etc/apache2/envvars.bak
fi
sudo sed -e "s/APACHE_RUN_USER=.*/APACHE_RUN_USER=bitz/g" /etc/apache2/envvars > envvars.tmp
sudo sed -e "s/APACHE_RUN_GROUP=.*/APACHE_RUN_GROUP=bitz/g" envvars.tmp > envvars
sudo cp -a envvars /etc/apache2/

rm -rf /home/bitz/www/
mkdir -p /home/bitz/www/repos
sudo rm -f /etc/apache2/sites-enabled/*.conf
sudo cp /home/bitz/code/airbitz-sync-server/staging/apache/git-js.conf /etc/apache2/sites-enabled/
sudo sed -e "s/ServerName .*/ServerName ${host_name}/g" /etc/apache2/sites-enabled/git-js.conf > git-js.conf
sudo cp -a git-js.conf /etc/apache2/sites-enabled/
sudo apachectl -t
sudo service apache2 restart

## Postgres
# sudo -u postgres psql -c "create role airbitz with login password 'airbitz'";
# sudo -u postgres createdb -E UTF8 -T template0 syncserver
# sudo -u postgres psql -d syncserver -c "grant all privileges on database syncserver to airbitz";

## NodeJS
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install -y nodejs
sudo npm install -y forever -g
sudo npm install -y forever-service -g 
cd /home/bitz/code/airbitz-sync-server
npm i
cd /home/bitz/code/edge-devops
npm i
cd /home/bitz

## CouchDB
if [ -f /etc/couchdb/local.ini.bak ]; then
  sudo cp -a /etc/couchdb/local.ini.bak /etc/couchdb/local.ini
else
  sudo cp -a /etc/couchdb/local.ini /etc/couchdb/local.ini.bak
fi

if [ -d /var/lib/couchdb.bak ]; then
  sudo rm -rf /var/lib/couchdb
  sudo cp -a /var/lib/couchdb.bak /var/lib/couchdb
else
  sudo cp -a /var/lib/couchdb /var/lib/couchdb.bak
fi

echo "Cleaning and making /var/run/couchdb"
sudo rm -rf /var/run/couchdb
sudo mkdir -p /var/run/couchdb
sudo chown couchdb:couchdb /var/run/couchdb
echo "Modifying couchdb ini file"
sudo sed -e "s@\[ssl\]@\[ssl\]\\ncert_file = /etc/ssl/wildcard/server.crt\\nkey_file = /etc/ssl/wildcard/server.key@g" /etc/couchdb/local.ini > local.ini.tmp
sudo sed -e "s@\[daemons\]@\[daemons\]\\nhttpsd = {couch_httpd, start_link, \[https\]}@g" local.ini.tmp > local.ini
sudo cp -a local.ini /etc/couchdb/

sudo chown -R couchdb:couchdb /var/lib/couchdb
sudo chown -R couchdb:couchdb /etc/couchdb

echo "Creating admin user"
curl -s -X PUT http://localhost:5984/_config/admins/admin -d "\"${couchdb_admin_password}\""

echo "Creating db_repos"
curl -X PUT http://admin:${couchdb_admin_password}@localhost:5984/db_repos

echo "Adding sync user"
curl -HContent-Type:application/json -vXPUT http://admin:${couchdb_admin_password}@localhost:5984/_users/org.couchdb.user:bitz --data-binary "{\"_id\": \"org.couchdb.user:bitz\",\"name\": \"bitz\",\"roles\": [],\"type\": \"user\",\"password\": \"${couchdb_user_password}\"}"

echo "Changing bind address"
curl -X PUT http://admin:${couchdb_admin_password}@localhost:5984/_config/httpd/bind_address -d '"0.0.0.0"'

echo "Change require_valid_user => true"
curl -X PUT http://admin:${couchdb_admin_password}@localhost:5984/_config/couch_httpd_auth/require_valid_user -d '"true"'

echo "Restarting couchdb"
sudo systemctl restart couchdb

## Javascript install script
node code/edge-devops/sync/install.js ${couchdb_admin_password} ${couchdb_user_password} ${seed_server}

## Background scripts
cd /home/bitz/code/airbitz-sync-server/lib
sudo forever-service install fixStuck -r bitz --script fixStuck.js  --start
sudo forever-service install gcRepos -r bitz --script gcRepos.js  --start
sudo forever-service install syncRepos -r bitz --script syncRepos.js  --start

## Firewall
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow 80,443/tcp
sudo ufw allow 6984
sudo ufw allow 5666
sudo ufw allow from 127.0.0.1
sudo ufw enable
sudo ufw status verbose

## rmate for remote file editing
sudo wget -O /usr/local/bin/rmate https://raw.github.com/aurora/rmate/master/rmate