#!/bin/bash

PS4="cmd # "

set -x
systemctl stop NetworkManager.sevice
systemctl disable NetworkManager.service
pkill dhclient

modprobe --first-time bonding
modprobe --first-time bridge
modprobe --first-time 8021q
set +x

# Set Default
IP="192.168.1.2"
NM="24"
GW="192.168.1.1"
NIC0="p1p0"
NIC1="p1p1"

function write_bond0()
{
cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-$NIC0
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$NIC0
ONBOOT=yes
MASTER=bond0
SLAVE=yes
NM_CONTROLLED=no
EOT

cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-$NIC1
TYPE=Ethernet
BOOTPROTO=none
DEVICE=$NIC1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
NM_CONTROLLED=no
EOT


cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
TYPE=Bond
BONDING_MASTER=yes
BOOTPROTO=none
ONBOOT=yes
BONDING_OPTS="miimon=1 updelay=0 downdelay=0 mode=4"
NAME=bond0
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NM_CONTROLLED=no
EOT

cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-bond0.11
VLAN=yes
TYPE=Vlan
PHYSDEV=bond0
VLAN_ID=11
DEVICE=bond0.11
BOOTPROTO=none
ONBOOT=yes
BRIDGE=br-public10g
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NM_CONTROLLED=no
EOT

cat <<EOT > /etc/sysconfig/network-scripts/ifcfg-br-public10g
TYPE=Bridge
DEVICE=br-public10g
ONBOOT=yes
IPADDR0=$IP
PREFIX0=$NM
GATEWAY0=$GW
NM_CONTROLLED=no
EOT
}

while getopts "i:n:g:a:b:" arg; do
    case $arg in
        i)
            IP=$OPTARG
            ;;
        n)
            NM=$OPTARG
            ;;
        g)
            GW=$OPTARG
            ;;
        a)
            NIC0=$OPTARG
            ;;
        b)
            NIC1=$OPTARG
            ;;
    esac
done

echo "IP Address: " $IP
echo "Netmask   : " $NM
echo "Gateway   : " $GW
echo "NIC0      : " $NIC0
echo "NIC1      : " $NIC1

write_bond0
