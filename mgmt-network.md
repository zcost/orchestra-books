# Network Configuration of Management Node

This is tested for CentOS 7.

Keyword         | Value         | Description
----            | ----          | ----
NIC0            | em1           | Management Network (1G)
NIC1            | ens6f0        | Network Interface 1 for bonding
NIC2            | ens6f1        | Network Interface 2 for bonding
MODE            | 4             | bonding mode(4 == LACP)
MIIMON          | 100           | MII link monitoring (ms)
VLAN_MGMT       | 3             | VLAN ID for management network
VLAN_PUBLIC     | 11            | VLAN ID for public  network
BRIDGE_MGMT0    | br-mgmt1g    | Bridge Interface for management network
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

# Bridge Interface

## Create Bridge interface for management

~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-${BRIDGE_MGMT0}', 'w')
content = """
TYPE=Bridge
BOOTPROTO=none
DEVICE=${BRIDGE_MGMT0}
ONBOOT=yes
"""
fp.write(content)
fp.close()


fp = open('/etc/sysconfig/network-scripts/ifcfg-${BRIDGE_MGMT}', 'w')
content = """
TYPE=Bridge
BOOTPROTO=none
DEVICE=${BRIDGE_MGMT}
ONBOOT=yes
"""
fp.write(content)
fp.close()

~~~

# Mgmt1g Interface

## Create management interface

~~~python
fp = open('/etc/sysconfig/network-scripts/ifcfg-${NIC0}', 'w')
content = """
TYPE=Ethernet
BOOTPROTO=none
NAME=${NIC0}
ONBOOT=yes
BRIDGE=${BRIDGE_MGMT0}
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

~~~

## Update Network

~~~bash
systemctl restart network.service
~~~
