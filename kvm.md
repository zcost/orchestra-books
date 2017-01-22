# KVM

Keyword     |   Value           | Description
----        | ----              | ----
CENTOS      | 7.2.1511          | CentOS version
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
wget -O /var/lib/tftpboot/pxelinux.0 http://ftp.daumkakao.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/pxelinux.0
wget -O /var/lib/tftpboot/ldlinux.c32 http://ftp.daumkakao.com/ubuntu/dists/xenial/main/installer-amd64/current/images/netboot/ldlinux.c32

mkdir -p /var/lib/tftpboot/centos${CENTOS}
wget -O /var/lib/tftpboot/centos${CENTOS}/vmlinuz http://ftp.daumkakao.com/centos/${CENTOS}/os/x86_64/images/pxeboot/vmlinuz
wget -O /var/lib/tftpboot/centos${CENTOS}/initrd.img http://ftp.daumkakao.com/centos/${CENTOS}/os/x86_64/images/pxeboot/initrd.img
~~~


