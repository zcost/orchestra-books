# Installation

This document is targeted for CentOS 7 and CloudStack 4.8~

## Environment

Keyword         | Value             | Description
----            | ----              | ----
VER             | 4.8               | CloudStack Version
REPO            | http://220.73.134.133/cloudstack | Repository for CloudStack package
VG_NAME         | vg00              | Volume Group name for local storage

## SELinux

SELinux must be set to permissive. We want to both configure this for future boots and modify in the current running system.

To configure SELinux to be permissive in the running system we need to run the following command:

~~~bash
setenforce 0
~~~

To ensure that it remains in that state we need to configure the file /etc/selinux/config to reflect the permissive state.

edit /etc/selinux/config

~~~text
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of these two values:
# targeted - Targeted processes are protected,
# mls - Multi Level Security protection.
SELINUXTYPE=targeted
~~~

## NTP

NTP configuration is a necessity for keeping all of the clocks in your cloud servers in sync.

~~~bash
yum -y install ntp
systemctl enable ntpd.service
systemctl start ntpd.service
~~~

## Configure the CloudStack Package Repository

We need to configure the machine to use a CloudStack package repository.

edit /etc/yum.repos.d/cloudstack.repo

~~~text
[cloudstack]
name=cloudstack
baseurl=${REPO}/centos/7/${VER}/
enabled=1
gpgcheck=0
~~~

# KVM Setup and Installation

Installation of the KVM agent is trivial with just a single command, but afterwards we need to configure a few things

~~~bash
yum -y install nfs-utils
yum -y install cloudstack-agent
~~~

## QEMU Configuration

KVM configuration is relatively simple at only a single item. We need to edit the QEMU VNC configuration.

~~~bash
echo "vnc_listen=\"0.0.0.0\"" >> /etc/libvirt/qemu.conf
~~~

## Libvirt Configuration

CloudStack uses libvirt for managing virtual machines. Therefore it is vital that libvirt is configured correctly.

* In order to have live migration working libvirt has to listen for unsecured TCP connections.

~~~bash
echo "listen_tls = 0" >> /etc/libvirt/libvirtd.conf
echo "listen_tcp = 1" >> /etc/libvirt/libvirtd.conf
echo "tcp_port = \"16059\"" >> /etc/libvirt/libvirtd.conf
echo "auth_tcp = \"none\"" >> /etc/libvirt/libvirtd.conf
echo "mdns_adv = 0" >> /etc/libvirt/libvirtd.conf
~~~

* Tunring on "listen_tcp" in libvirtd.conf is not enough. we have to change the parameters as well we also need to modify /etc/sysconfig/libvirtd

~~~bash
echo "LIBVIRTD_ARGS=\"--listen\"" >> /etc/sysconfig/libvirtd
systemctl restart  libvirtd.service
systemctl start cloudstack-agent.service
~~~

# Use Local Storage

To Use local storage, make a new volume

~~~bash
lvcreate -L 100G ${VG_NAME} -n lv_data
mkfs.ext4 -F /dev/mapper/${VG_NAME}-lv_data
echo "/dev/mapper/${VG_NAME}-lv_data    /var/lib/libvirt/images     ext4    defaults    1   1" >> /etc/fstab
~~~ 
# Reference
http://docs.cloudstack.apache.org/projects/cloudstack-installation/en/4.8/qig.html
