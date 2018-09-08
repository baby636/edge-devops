set -e

## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/install-adduser.sh | bash

echo '
sudo adduser $1
sudo mkdir /home/$1/.ssh
sudo chmod 754 /home/$1/.ssh
sudo chown $1.$1 /home/$1/.ssh
sudo touch /home/$1/.ssh/authorized_keys
sudo chmod 600 /home/$1/.ssh/authorized_keys
sudo chown $1.$1 /home/$1/.ssh/authorized_keys
sudo vi /home/$1/.ssh/authorized_keys
sudo gpasswd -a $1 ssh
sudo gpasswd -a $1 sudo
' > adduserplus
chmod 755 adduserplus