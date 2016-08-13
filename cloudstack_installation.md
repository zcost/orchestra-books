# Installation

This document is targeted for CentOS 7 and CloudStack 4.8~

## Environment

Keyword         | Value             | Description
----            | ----              | ----
VER             | 4.8               | CloudStack Version
PRIMARY         | /primary          | Primary storage directory path
SECONDARY       | /secondary        | Secondary storage directory path
DOMAIN          | cloud.priv        | Domain for management
PASSWORD        | password          | MySQL password for cloud account

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
baseurl=http://cloudstack.apt-get.eu/centos/7/${VER}/
enabled=1
gpgcheck=0
~~~

## NFS

Our configuration is going to use NFS for both primary and secondary storage. We are going to go ahead and setup two NFS shares for those purposes.

~~~bash
yum -y install nfs-utils
~~~

We now needs to configure NFS to serve up two different shares. This is handled comparatively easily in the /etc/exports

edit /etc/exports

~~~text
${SECONDARY} *(rw,async,no_root_squash,no_subtree_check)
${PRIMARY} *(rw,async,no_root_squash,no_subtree_check)
~~~

Yiy wukk bite tgat we specified two directories that don't exist(yet) on the syste. We'll go ahead and create those directories and set permissions appropriately on them.

~~~bash
mkdir -p ${PRIMARY}
mkdir -p ${SECONDARY}
~~~

CentOS 6.x releases use NFSv4 by default. NFSv4 requires that domain setting matches on all clients.

edit /etc/idmapd.conf

~~~ini
[General]
Domain = ${DOMAIN}
~~~

Now you'll need to uncomment the configuration values.

edit /etc/sysconfig/nfs

~~~text
LOCKD_TCPPORT=32803
LOCKD_UDPPORT=32769
MOUNTD_PORT=892
RQUOTAD_PORT=875
STATD_PORT=662
STATD_OUTGOING_PORT=2020
~~~

To take effect the nfs-config service has to be restarted.

~~~bash
systemctl restart nfs-config
systemctl enable rpcbind.service
systemctl enable nfs-server.service
systemctl restart  rpcbind.service
systemctl restart nfs-server.service
~~~

# Management Server Installation

## Database Installation and Configuration

We'll start with installing MySQL(MariaDB) and configuring some options to ensure it runs well with CloudStack.

~~~bash
yum install -y mariadb-server
~~~

Start mariaDB

~~~bash
systemctl enable mariadb.service
systemctl start mariadb.service
~~~

## Installation

We are now going to install the management server.

~~~bash
yum -y install cloudstack-management
cloudstack-setup-databases cloud:${PASSWORD}@localhost --deploy-as=root
~~~

When this process is finished, you should see a message like "CloudStack has successfully initialized the database"
Now that the database has been created, we can take the final step in setting up the management server.

~~~bash
cloudstack-setup-management --tomcat7
~~~

## System Template Setup

CloudStack uses a number of system VMs to provide functionality for accessing the console of virtual machines, providing various networking services, and managing various aspects of storage.

Now we need to download the system VM template and deploy that to the share we just mounted.

~~~bash
/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt \
-m ${SECONDARY} \
-u http://cloudstack.apt-get.eu/systemvm/4.6/systemvm64template-4.6.0-kvm.qcow2.bz2 \
-h kvm -F
~~~

Reference

http://docs.cloudstack.apache.org/projects/cloudstack-installation/en/4.8/qig.html
