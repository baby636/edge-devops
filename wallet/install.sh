set -e

w=$(whoami)

if [ $w = bitz ]; then
  echo 'Running as user bitz...'
else
  echo "Please run as user bitz"
  sudo su -l bitz
  exit 1
fi

if [ ! -f env.sh ]; then
  echo '# Full DNS name of this machine (ie. git1.edge.app)
export host_name=""

# Git sync servers comma separated
# ie. SYNC_SERVER_URL="https://git2.airbitz.co,https://git3.airbitz.co"
export SYNC_SERVER_URL=""

# Admin password for postgres db
export POSTGRES_ADMIN_PASSWORD=""
' > env.sh
  echo '
  
  *** Please complete the created env.sh file and rerun install script ***
  
  '
  sudo chown bitz:bitz env.sh
  exit 1
fi

source env.sh

rm -rf /home/bitz/code
machine_name="$(echo ${host_name} | cut -d'.' -f1)"

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
sudo apt-get install ufw apache2 supervisor python-pip python-dev python-virtualenv libncurses5-dev vim git fail2ban libpq-dev postgresql-9.5 rabbitmq-server -y
# sudo a2enmod rewrite proxy proxy_http proxy_html cgid ssl status xml2enc

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
git clone git@github.com:EdgeApp/airbitz-wallet-server.git
git clone git@github.com:EdgeApp/edge-devops.git
rm -f /home/bitz/airbitz/ENV/airbitz
ln -s /home/bitz/code/airbitz-wallet-server/walletserver /home/bitz/airbitz/ENV/airbitz

## Update sync server addresses
sudo sed -e "s/SYNC_SERVERS/SYNC_SERVER_URL=${SYNC_SERVER_URL}/g" /home/bitz/code/airbitz-wallet-server/staging/etc-profile.d/environment_vars.sh > environment_vars.sh
sudo sed -e "s/SYNC_SERVER_URL/SYNC_SERVER_URL=${SYNC_SERVER_URL}/g" /home/bitz/code/airbitz-wallet-server/staging/supervisor/celeryd.conf > celeryd.conf
sudo sed -e "s/SYNC_SERVER_URL/SYNC_SERVER_URL=${SYNC_SERVER_URL}/g" /home/bitz/code/airbitz-wallet-server/staging/supervisor/walletserver.conf > walletserver.conf
cp -f environment_vars.sh /home/bitz/code/airbitz-wallet-server/staging/etc-profile.d/environment_vars.sh
cp -f celeryd.conf /home/bitz/code/airbitz-wallet-server/staging/supervisor/celeryd.conf
cp -f walletserver.conf /home/bitz/code/airbitz-wallet-server/staging/supervisor/walletserver.conf

## Copy system config files
sudo cp -f /home/bitz/code/airbitz-wallet-server/staging/etc-profile.d/environment_vars.sh /etc/profile.d/

## Postgres
sudo -u postgres psql -c "create role airbitz with login password 'airbitz'";
sudo -u postgres createdb -E UTF8 wallet
sudo -u postgres psql -d wallet -c "grant all privileges on database wallet to airbitz";

## Update virtual ENV
source /home/bitz/airbitz/ENV/bin/activate
pip install -r /home/bitz/code/airbitz-wallet-server/staging/requirements.txt
pip uninstall south

cd /home/bitz/code/airbitz-wallet-server/walletserver

mkdir -p .keys
keyczart create --location=.keys --purpose=crypt
keyczart addkey --location=.keys --status=primary --size=256

python manage.py migrate auth
python manage.py migrate
python manage.py createsuperuser

sudo cp -a /home/bitz/code/airbitz-wallet-server/staging/supervisord/* /etc/supervisor/conf.d/

## Restart supervisorctl
sudo supervisorctl update

## Apache
sudo rm -f /etc/apache2/sites-enabled/*.conf
sudo cp -a /home/bitz/code/airbitz-wallet-server/staging/apache/auth-server.conf /etc/apache2/sites-enabled/
sudo apachectl -t
sudo service apache2 restart

## NodeJS
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install -y nodejs
sudo npm install -y forever -g
sudo npm install -y forever-service -g 
cd /home/bitz/code/airbitz-wallet-server
npm i
cd /home/bitz/code/edge-devops
npm i
cd /home/bitz

## Javascript install script
# node code/edge-devops/sync/install.js ${SYNC_SERVER_URL}

## Background scripts
cd /home/bitz/code/airbitz-wallet-server/lib
sudo forever-service install dbBackup -r bitz --script dbBackup.js  --start
sudo forever-service install checkServers -r bitz --script checkServers.js  --start

## Firewall
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow 443/tcp
sudo ufw allow 5666
sudo ufw allow from 127.0.0.1
sudo ufw enable
sudo ufw status verbose

## rmate for remote file editing
sudo wget -O /usr/local/bin/rmate https://raw.github.com/aurora/rmate/master/rmate