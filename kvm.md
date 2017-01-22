# KVM

Keyword     |   Value           | Description
----        | ----              | ----
CENTOS      | 7.3.1611          | CentOS version
ROOT_PW     | mypassword        | Root password for New installed OS


# Install KVM

~~~bash
yum groupinstall -y "X Window System"
yum install -y vconfig bridge-utils wget
yum install -y qemu libvirt tightvnc seabios
~~~

## Restart libvirtd service

~~~bash
systemctl enable libvirtd
systemctl restart libvirtd
virsh version
~~~

# Install TFTP

~~~bash
yum install -y tftp tftp-server xinetd
~~~

## update config

edit /etc/xinetd.d/tftp

~~~text
service tftp
{
    socket_type     = dgram
    protocol        = udp
    wait            = yes
    user            = root
    server          = /usr/sbin/in.tftpd
    server_args     = -c -s /var/lib/tftpboot
    disable         = no
    per_source      = 11
    cps             = 100 2
    flags           = IPv4
}
~~~

## Enable Service

~~~bash
systemctl enable xinetd
systemctl enable tftp
~~~

## Configure firewalld

~~~bash
firewall-cmd --zone=public --add-service=tftp --permanent
firewall-cmd --reload
~~~

# Download Netboot Image

~~~bash
mkdir -p /var/lib/tftpboot/pxelinux.cfg
wget -O /var/lib/tftpboot/pxelnux.0 http://ftp.daumkakao.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/pxelinux.0
mkdir -p /var/lib/tftpboot/centos${CENTOS}
wget -O /var/lib/tftpboot/centos${CENTOS}/vmlinuz http://ftp.daumkakao.com/centos/${CENTOS}/os/x86_64/images/pxeboot/vmlinuz
wget -O /var/lib/tftpboot/centos${CENTOS}/initrd.img http://ftp.daumkakao.com/centos/${CENTOS}/os/x86_64/images/pxeboot/initrd.img
~~~

## Make default config

edit /var/lib/tftpboot/pxelinux.cfg/default

~~~text
# D-I config version 2.0
console 0
serial 0 115200 0

default CentOS 7.3

# install
label CentOS 7.3
    kernel centos${CENTOS}/vmlinuz
    append initrd=centos${CENTOS}/initrd.img vga=normal inst.stage2=http://ftp.daumkakao.com/centos/${CENTOS}/os/x86_64/ ks=tftp:/install/anaconda-ks.cfg.${CENTOS} ksdevice=bootif

prompt 0
timeout 10
~~~

# Kickstart

## edit kickstart

edit /tmp/ks.cfg

~~~text
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="http://ftp.daum.net/centos/${CENTOS}/os/x86_64/"
# Reboot after installation
reboot

# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=auto --activate
network  --bootproto=dhcp --device=eth1 --onboot=off --ipv6=auto

# Root password
rootpw "${ROOT_PW}"
# System services
services --enabled="chronyd"
# System timezone
timezone Asia/Seoul --isUtc
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=vda

%packages
@base
@core
chrony
kexec-tools
%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%post --log=/root/ks-post.log
yum install -y python-devel gcc expect epel-release
yum install -y python-pip
pip install jeju --upgrade
%end
~~~
