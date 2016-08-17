# Install NFS Server

## Environment

Keyword         | Value             | Description
----            | ----              | ----
PRIMARY         | /primary          | Primary storage directory path
SECONDARY       | /secondary        | Secondary storage directory path
DOMAIN          | cloud.priv        | Domain for management


This is for Primary storage and Secondary storage for CloudStack

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

# TODO List

Change Firewall rule
firewall-cmd --zone=internal --add-service=nfs --permanent
firewall-cmd --reload


