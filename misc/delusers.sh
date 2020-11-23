set -e

## curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/misc/addusers.sh | bash

## deletes users based on the ~/.ssh/authorized_keys file of the current user.

while read line; do
    fullname=$(echo "${line##* }")
    name=$(echo $fullname | cut -d@ -f1)
    echo "Creating account for" $name
    sudo deluser $name
    sudo rm -rf /home/$name/
done < ~/.ssh/authorized_keys
