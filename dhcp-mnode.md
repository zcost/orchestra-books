# DHCP & PXEBOOT

## Environment

Keyword         | Value             | Description
----            | ----              | ----
DOMAIN          | cloud.priv        | Domain name for internal
MGMT01_MAC1     | 52:54:00:00:01:01 | Management node MAC address 1
MGMT02_MAC1     | 52:54:00:00:01:02 | Management node MAC address 1
KSDEVICE        | eth0              | Default Interface for Kickstart Installation
NUM_CNODE       | 5                 | Number of Compute node

*Notice: every code like ${KEYWORD} is replaced by envrironment value*
 

# Install DHCP Server

~~~bash
yum install -y dhcp
~~~

## Update Configuration

edit /etc/dhcp/dhcpd.conf

~~~text
ddns-update-style none;
ddns-hostname = option fqdn.fqdn;

option domain-name "${DOMAIN}";

default-lease-time 3600;
max-lease-time 86400;

log-facility local7;

include "/etc/dhcp/rack01.conf";
include "/etc/dhcp/mgmt.conf";
~~~
## Update DHCP environment

edit /etc/dhcp/mgmt.conf

~~~text
subnet 10.2.0.0 netmask 255.255.255.0 {
  range 10.2.0.11 10.2.0.200;
  option routers 10.2.0.254;
  option broadcast-address 10.2.0.255;
  option subnet-mask 255.255.255.0;
  option domain-name "${DOMAIN}";
  option domain-name-servers 8.8.8.8;
  host cloudstack-vm {
    hardware ethernet ${MGMT01_MAC1};
    fixed-address 10.2.0.11;
    option host-name "cloudstack-vm";
    }
  host monitoring01-vm {
    hardware ethernet ${MGMT02_MAC1};
    fixed-address 10.2.0.12;
    option host-name "monitoring01-vm";
    }
}
~~~

create /etc/dhcp/rack01.conf with number of cnodes

~~~python
fp = open('/etc/dhcp/rack01.conf', 'w')
content = """
subnet 10.1.1.0 netmask 255.255.255.0 {
    range 10.1.1.1 10.1.1.200;
    next-server ${IP};
    option routers 10.1.1.254;
    option broadcast-address 10.1.1.255;
    option subnet-mask 255.255.255.0;
    option domain-name "${DOMAIN}";
    option domain-name-servers 8.8.8.8;
    filename \"pxelinux.0\";

    #######################
    # Cnode Mgmt network
    #######################
"""
for i in range(${NUM_CNODE}):
    node = """    host cnode%.2d-R01 {
        #hardware ethernet aa:bb:cc:dd:ee:ff;
        fixed-address 10.1.1.%d;
        option subnet-mask 255.255.255.0;
        option host-name \"cnode%.2d-R01\";
        }\n""" % (i+1, i+1, i+1)
    content = content + node

content = content + """
    #######################
    # IPMI
    #######################
    """

for i in range(${NUM_CNODE}):
    node = """    host cnode%.2d-R01.IPMI {
        #hardware ethernet bb:cc:dd:ee:ff:aa;
        fixed-address 10.1.1.%d;
        option subnet-mask 255.255.255.0;
        }\n""" % (i, i + 101)
    content = content + node


content = content + "\n}"
fp.write(content)
fp.close()
~~~

# Specify Interface for dhcp

edit /etc/systemd/system/dhcpd.service

~~~text
[Unit]
Description=DHCPv4 Server Daemon
Documentation=man:dhcpd(8) man:dhcpd.conf(5)
Wants=network-online.target
After=network-online.target
After=time-sync.target

[Service]
Type=notify
ExecStart=/usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf -user dhcpd -group dhcpd --no-pid br-mgmt10g br-mgmt1g

[Install]
WantedBy=multi-user.target
~~~

# Restart Service

~~~bash
systemctl start dhcpd.service
systemctl enable dhcpd.service
~~~
