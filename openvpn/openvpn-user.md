# Create OpenVPN User 


## Prerequisite

Keyword | Value         | Description
----    | ----          | ----
NAME    | gildong.hong  | Username
EMAIL   | gildong.hong@email.com    | email address of user
OU      | zcost_development         | Name of Organization
DIR     | /root/keys                | Target directory for key saving
SERVER  | 127.0.0.1                 | IP address of OpenVPN Server

# Create Keypair

## OpenVPN user key creatation

~~~bash
.
#! /bin/bash

# Params
#   $1: name
#   $2: email
#   $3: ou
#
# ex: python pyengine-build-key.sh choonho.son choonho.son@email.com test-department

cd /etc/openvpn/easy-rsa
source ./vars

export KEY_EMAIL=${EMAIL}
export KEY_OU=${OU}

./build-key --batch ${NAME}
~~~

## Create client.ovpn file

edit /tmp/client.ovpn

~~~text
client
dev tun
proto udp
remote ${SERVER} 1194
resolv-retry infinite
nobind
user nobody
group nogroup
persist-key
persist-tun
ca ${NAME}.ca
cert ${NAME}.crt
key ${NAME}.key
ns-cert-type server
comp-lzo
verb 3
~~~

## Copy keys to target directory

~~~bash
target=${DIR}/${NAME}/
mkdir -p $target
cp /tmp/client.ovpn $target
cp /etc/openvpn/easy-rsa/keys/ca.crt    $target
cp /etc/openvpn/easy-rsa/keys/${NAME}.crt $target
cp /etc/openvpn/easy-rsa/keys/${NAME}.key $target
~~~
