# Installation

This document is targeted for CentOS 7 and CloudStack 4.8~

## Environment

Keyword         | Value             | Description
----            | ----              | ----
VER             | 4.8               | CloudStack Version
NFS_SERVER      | 10.2.0.254        | NFS Server  Address
SECONDARY       | /secondary        | Secondary storage directory path
DOMAIN          | cloud.priv        | Domain for management
PASSWORD        | password          | MySQL password for cloud account
REPO            | http://220.73.134.133/cloudstack | Repository for CloudStack package

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

## NFS

Our configuration is going to use external NFS for both primary and secondary storage. We are going to Rmount NFS


~~~bash
yum -y install nfs-utils
~~~


Yiy wukk bite tgat we specified two directories that don't exist(yet) on the syste. We'll go ahead and create those directories and set permissions appropriately on them.

~~~bash
mkdir -p ${SECONDARY}
mount -t nfs ${NFS_SERVER}:/secondary ${SECONDARY}
~~~

## Configure Firewall for CloudStack
~~~bash
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
~~~

# Management Server Installation

## Database Installation and Configuration

We'll start with installing MySQL(MariaDB) and configuring some options to ensure it runs well with CloudStack.

~~~bash
yum install -y mariadb-server
~~~

Start mariaDB

~~~bash
sed -i s/PrivateTmp=true/PrivateTmp=false/ /lib/systemd/system/mariadb.service
systemctl enable mariadb.service
systemctl start mariadb.service
~~~

## Installation

We are now going to install the management server.
Haveged is enhance entropy of system.
Since CloudStack installation needs to encrypt something.
But it is very slow on VM. Because of low entropy.

~~~bash
yum -y install haveged
haveged -w 1024
yum -y install cloudstack-management
cloudstack-setup-databases cloud:${PASSWORD}@localhost --deploy-as=root
~~~

When this process is finished, you should see a message like "CloudStack has successfully initialized the database"
Now that the database has been created, we can take the final step in setting up the management server.

~~~bash
cloudstack-setup-management --tomcat7
~~~

# System Template Setup

We change to wget with quite mode.
There are Paramiko bug for wget with large buffer, ssh session hang.

~~~bash
sed -i s/wget/wget\ -q/ /usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt
/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt \
-m ${SECONDARY} \
-u ${REPO}/systemvm/4.6/systemvm64template-4.6.0-kvm.qcow2.bz2 \
-h kvm -F
~~~

Reference

http://docs.cloudstack.apache.org/projects/cloudstack-installation/en/4.8/qig.html
