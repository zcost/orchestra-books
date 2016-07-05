# Network Configuration of Management Node

This is tested for CentOS 7.

Keyword         | Value         | Description
----            | ----          | ----
NIC1            | ens6f0        | Network Interface 1 for bonding
NIC2            | ens6f1        | Network Interface 2 for bonding
MODE            | 4             | bonding mode(4 == LACP)
MIIMON          | 100           | MII link monitoring (ms)
VLAN_MGMT       | 3             | VLAN ID for management network
VLAN_PUBLIC     | 11            | VLAN ID for public  network
BRIDGE_MGMT     | br-mgmt10g    | Bridge Interface for management network
BRIDGE_PUBLIC   | br-public10g  | Bridge Interface for public network


# Bonding Interface

## Prerequisite

Load bonding module

~~~bash
modprobe bonding
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
BONDING_OPS="mode=${MODE} miimon=${MIIMON}"
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
"""
fp.write(content)
fp.close()
~~~

## Step 3. Restart the Network Service

~~~bash
ifconfig ${NIC1} up
ifconfig ${NIC2} up
systemctl restart network.service
ifconfig bond0 up
~~~

# Bridge Interface

## Create Bridge interface for management

~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-${BRIDGE_MGMT}', 'w')
content = """
TYPE=Bridge
BOOTPROTO=none
DEVICE=${BRIDGE_MGMT}
ONBOOT=yes
"""
fp.write(content)
fp.close()

fp = open('/etc/sysconfig/network-scripts/ifcfg-${BRIDGE_PUBLIC}', 'w')
content = """
TYPE=Bridge
BOOTPROTO=none
DEVICE=${BRIDGE_PUBLIC}
ONBOOT=yes
"""
fp.write(content)
fp.close()
~~~

# VLAN Interface

## Create VLAN interface for management

~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-VLAN${VLAN_MGMT}', 'w')
content = """
VLAN=yes
TYPE=Vlan
PHYSDEV=bond0
VLAN_ID=${VLAN_MGMT}
BOOTPROTO=none
DEVICE=VLAN${VLAN_MGMT}
ONBOOT=yes
BRIDGE=${BRIDGE_MGMT}
"""
fp.write(content)
fp.close()

fp = open('/etc/sysconfig/network-scripts/ifcfg-VLAN${VLAN_PUBLIC}', 'w')
content = """
VLAN=yes
TYPE=Vlan
PHYSDEV=bond0
VLAN_ID=${VLAN_PUBLIC}
BOOTPROTO=none
DEVICE=VLAN${VLAN_PUBLIC}
ONBOOT=yes
BRIDGE=${BRIDGE_PUBLIC}
"""
fp.write(content)
fp.close()
~~~

## Update Network

~~~bash
systemctl restart NetworkManager
~~~
