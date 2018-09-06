sudo cp ./bin/check_sync_failed* /usr/lib/nagios/plugins/
sudo cp ./cfg/* /etc/nagios/nrpe.d
sudo /etc/init.d/nagios-nrpe-server restart

