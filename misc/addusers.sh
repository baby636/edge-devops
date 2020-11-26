set -e

## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/addusers.sh | bash

## Auto create users based on the ~/.ssh/authorized_keys file of the current user.
## Gives all created users sudo access and puts their key in the new users ~/.ssh/authorized_keys directory

declare -A passwds
while read line; do
    if [[ -z "${line// }" ]]; then
        continue
    fi
    fullname=$(echo "${line##* }")
    name=$(echo $fullname | cut -d@ -f1)
    passwds["$name"]=""
    if [ -d /home/$name ]; then
        continue
    fi
    echo "Creating account for" $name
    sudo adduser --disabled-password --gecos "" $name
    sudo echo $line > $name-authorized_keys
    sudo mkdir -p /home/$name/.ssh
    sudo chmod 754 /home/$name/.ssh
    sudo cp -f $name-authorized_keys /home/$name/.ssh/authorized_keys
    sudo chmod 600 /home/$name/.ssh/authorized_keys
    sudo chown -R $name.$name /home/$name/.ssh
    sudo gpasswd -a $name ssh
    sudo gpasswd -a $name sudo
    passwd=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
    echo "$passwd
$passwd" | sudo passwd --quiet $name
    passwds["$name"]=$passwd
done < ~/.ssh/authorized_keys

name="edgy"
echo "Creating account for" $name
sudo adduser --disabled-password --gecos "" $name
sudo echo $line > $name-authorized_keys
sudo mkdir -p /home/$name/.ssh
sudo chmod 754 /home/$name/.ssh
sudo cp -f $name-authorized_keys /home/$name/.ssh/authorized_keys
sudo chmod 600 /home/$name/.ssh/authorized_keys
sudo chown -R $name.$name /home/$name/.ssh
sudo gpasswd -a $name ssh
sudo gpasswd -a $name sudo
passwd=$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM
echo "$passwd
$passwd" | sudo passwd --quiet $name
echo "Password for $name:" ${passwd}

while read line; do
    if [[ -z "${line// }" ]]; then
        continue
    fi
    fullname=$(echo "${line##* }")
    name=$(echo $fullname | cut -d@ -f1)
    echo "Password for $name:" ${passwds["$name"]}
done < ~/.ssh/authorized_keys
