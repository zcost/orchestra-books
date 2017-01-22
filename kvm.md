# KVM

Keyword     |   Value           | Description
----        | ----              | ----


# Install KVM

~~~bash
yum groupinstall -y "X Window System"
yum install -y vconfig bridge-utils
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
