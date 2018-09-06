curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
sudo apt-get update -y
sudo apt-get install -y docker-ce
sudo docker container ls a

sudo docker run -d \
  --name bu-coind \
  --restart unless-stopped \
  -v /datadrive/bitcoind:/data \
  -p 8338:8338 \
  -p 127.0.0.1:8332:8332 \
  amacneil/bitcoinunlimited:1.0.1.2 bitcoind -rpcallowip=::/0 -rpcallowip=0.0.0.0/0 -rpcallowip=127.0.0.1/0 -server=1 -rpcuser=bitcoinunlimiteduser -rpcpassword=bitcoinunlimitedpassword -disablewallet -txindex=1 -printtoconsole

sudo docker run -d \
  --net="host" \
  --restart unless-stopped \
  --name bu-electrumx \
  -v /datadrive/electrumx:/data \
  -e DAEMON_URL=http://bitcoinunlimiteduser:bitcoinunlimitedpassword@127.0.0.1:8332 \
  -e COIN=BitcoinSegwit \
  -e MAX_SESSIONS=300000 \
  -e MAX_SUBS=30000000 \
  -e MAX_SESSION_SUBS=10000000 \
  -e TCP_PORT=50001 \
  -e SSL_PORT=50002 \
  -p 50001:50001 \
  -p 50002:50002 \
  lukechilds/electrumx