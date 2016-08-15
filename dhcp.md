# DHCP & PXEBOOT

## Environment

Keyword         | Value             | Description
----            | ----              | ----
DOMAIN          | cloud.priv        | Domain name for internal
REPO            | https://raw.githubusercontent.com/zcost/orchestra-books/master    | distribution repo
CENTOS          | http://ftp.daumkakao.com/centos/7/os/x86_64/images/pxeboot/ | CentosOS Repo for pxeboot
MGMT01_MAC1     | 52:54:00:00:01:01 | Management node MAC address 1
KSDEVICE        | eth0              | Default Interface for Kickstart Installation
NUM_CNODE       | 7                 | Number of Compute node

*Notice: every code like ${KEYWORD} is replaced by envrironment value*
 
~~~bash
apt-get update
~~~

# Install DHCP Server

~~~bash
apt-get install -y isc-dhcp-server
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

# Install TFTP server

~~~bash
apt-get install -y tftpd tftp
~~~

## Update Configuration

edit /etc/xinetd.d/tftp

~~~text
service tftp
{
protocol        = udp
port            = 69
socket_type     = dgram
wait            = yes
user            = nobody
server          = /usr/sbin/in.tftpd
server_args     = /tftpboot
disable         = no
}
~~~

## Update TFTP environment

~~~bash
mkdir -p /tftpboot
mkdir -p /tftpboot/pxelinux.cfg
mkdir -p /tftpboot/centos7
wget -O /tftpboot/pxelinux.0            ${REPO}/dist/pxelinux.0
wget -O /tftpboot/centos7/vmlinuz       ${CENTOS}/vmlinuz
wget -O /tftpboot/centos7/initrd.img    ${CENTOS}/initrd.img
~~~

edit /tftpboot/pxelinux.cfg/default 

~~~text
# D-I config version 2.0
console 0
serial 0 115200 0

default CentOS 7.2

# install
label CentOS 7.2
    kernel centos7/vmlinuz
    append initrd=centos7/initrd.img vga=normal ks=http://${IP}/static/install/anaconda-ks.cfg.7 ksdevice=${KSDEVICE}

prompt 0
timeout 10
~~~

## Update DHCP environment

edit /etc/dhcp/mgmt.conf

~~~text
subnet 10.2.0.0 netmask 255.255.0.0 {
  range 10.2.0.11 10.2.1.200;
  next-server ${IP};
  option routers 10.2.0.254;
  option broadcast-address 10.2.255.255;
  option subnet-mask 255.255.0.0;
  option domain-name "${DOMAIN}";
  option domain-name-servers 8.8.8.8;
  filename "pxelinux.0";

  host cloudstack01-vm {
    hardware ethernet ${MGMT01_MAC1};
    fixed-address 10.2.0.11;
    option subnet-mask 255.255.0.0;
    option host-name "cloudstack01-vm";
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

# Restart Service

~~~bash
chown -R nobody:nogroup /tftpboot/
service isc-dhcp-server restart
service xinetd restart
~~~
