# edge-devops

## Install scripts for Edge servers

Use bash scripts to auto install various types of Edge servers from with VMs. These are meant to be used as a `wget` or `curl` command.

## Examples

Install Edge sync server

    curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-sync.sh | bash

Install Edge sync server on Azure

    curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-sync-azure.sh | bash

Install Bitcoin BU server on Azure

    curl -o- https://raw.githubusercontent.com/EdgeApp/edge-devops/master/install-electrum-bu-azure.sh | bash

All scripts assume a /datadrive exists or can be created where large data can be stored. In the case of Azure servers, scripts will mount the extra /dev/sdc drive to /datadrive

Some scripts require pre-setup on the VM.

### Sync server scripts requirements

* User created named `bitz` and script run as that user
* SSH private key be installed for the `bitz` user which has access to proper github repos.
* SSL certs installed in

    /etc/ssl/wildcard/server.crt
    /etc/ssl/wildcard/server.key

### Bitcoin BU scripts requirements

* User created named `bitcoin` and script run as that user