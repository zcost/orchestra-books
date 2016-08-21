# Network Configuration of Management Node

This is tested for CentOS 7.

Keyword         | Value         | Description
----            | ----          | ----
NIC1            | ens2f0        | Network Interface 1 for bonding
NIC2            | ens2f1        | Network Interface 2 for bonding
MODE            | 4             | bonding mode(4 == LACP)
MIIMON          | 100           | MII link monitoring (ms)
VLAN_MGMT       | 3             | VLAN ID for management network
VLAN_PUBLIC     | 11            | VLAN ID for public  network
BRIDGE_MGMT     | br-mgmt10g    | Bridge Interface for management network
BRIDGE_CLOUD0   | cloudbr0      | Bridge for Cloud 
BRIDGE_CLOUD1   | cloudbr1      | Bridge for Cloud

# Bonding Interface

## Prerequisite

Load bonding module

~~~bash
modprobe bonding
modprobe 8021q
modprobe --first-time bridge
yum install -y bridge-utils
~~~

## Step 1. Create Bond Interface File

Create a bonding interface file (ifcfg-bond0) under the folder */etc/sysconfig/network-scripts/*

edit /etc/sysconfig/network-scripts/ifcfg-bond0

~~~text
DEVICE=bond0
TYPE=Bond
NAME=bond0
BONDING_MASTER=yes
BOOTPROTO=none
ONBOOT=yes
BONDING_OPTS="mode=${MODE} miimon=${MIIMON}"
NM_CONTROLLED=no
~~~

## Step 2. Edit the NIC interface files


~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-${NIC1}', 'w')
content = """
TYPE=Ethernet
BOOTPROTO=none
DEVICE=${NIC1}
ONBOOT=yes
MASTER=bond0
SLAVE=yes
NM_CONTROLLED=no
"""
fp.write(content)
fp.close()

fp = open('/etc/sysconfig/network-scripts/ifcfg-${NIC2}', 'w')
content = """
TYPE=Ethernet
BOOTPROTO=none
DEVICE=${NIC2}
ONBOOT=yes
MASTER=bond0
SLAVE=yes
NM_CONTROLLED=no
"""
fp.write(content)
fp.close()
~~~

## Step 3. Restart the Network Service

~~~bash
ifconfig ${NIC1} up
ifconfig ${NIC2} up
ifconfig bond0 up
~~~

# VLAN Interface

## Create VLAN interface for management

Set Management IP address based on hostname
ex) cnode01-R01 is 10.2.1.1
Rack # indicates the 3rd digit of IP address
Host # indicates the 4th digit of IP address

~~~python
import socket
fp = open('/etc/sysconfig/network-scripts/ifcfg-bond0.${VLAN_MGMT}', 'w')
h = socket.gethostname()
i = h.split('-')
ip3 = int(i[0][-2:])
ip4 = int(i[1][-2:])
ip='10.2.%s.%s' % (ip4, ip3)
content = """
VLAN=yes
TYPE=Vlan
PHYSDEV=bond0
VLAN_ID=${VLAN_MGMT}
BOOTPROTO=none
DEVICE=bond0.${VLAN_MGMT}
ONBOOT=yes
IPADDR=%s
NETMASK=255.255.0.0
NM_CONTROLLED=no
""" % ip

fp.write(content)
fp.close()
~~~


## Create VLAN Interface for public

~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-bond0.${VLAN_PUBLIC}', 'w')
content = """
VLAN=yes
TYPE=Vlan
PHYSDEV=bond0
VLAN_ID=${VLAN_PUBLIC}
BOOTPROTO=none
DEVICE=bond0.${VLAN_PUBLIC}
ONBOOT=yes
NM_CONTROLLED=no
BRIDGE=cloudbr0
""" 

fp.write(content)
fp.close()
~~~


## Public Bridge Network

~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-cloudbr0', 'w')
content = """
TYPE=Bridge
BOOTPROTO=none
DEVICE=cloudbr0
ONBOOT=yes
DELAY=5
STP=yes
NM_CONTROLLED=no
""" 



~~~bash
ifconfig bond0.${VLAN_MGMT} up
ifconfig bond0.${VLAN_PUBLIC} up
~~~
