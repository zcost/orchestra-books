# Prepare Virtual Machine

Create Virtual Machine for CloudStack
Netinstall from blank disk

Keyword         | Value             | Description
----            | ----              | ----
VER             | 7.2.1511          | CentOS version
STORAGE         | /storage          | Directory for VM image
MGMT            | br-mgmt10g        | Bridge network
PUBLIC          | br-public10g      | Bridge network
MGMT01_MAC0     | 52:54:00:00:00:02 | Management node MAC address 1
MGMT01_MAC1     | 52:54:00:00:01:02 | Management node MAC address 1
MGMT01_MAC2     | 52:54:00:00:02:02 | Management node MAC address 2

## Prepare environment

Virtual Disk is stored at ${STORAGE} directory

~~~bash
if [ ! -d "${STORAGE}" ]; then
    mkdir -p ${STORAGE}
fi
mkdir -p ${STORAGE}/img
mkdir -p ${STORAGE}/iso
~~~

# Create Virtual Machine

## Create Virtual Disk

~~~bash
qemu-img create -f qcow2 ${STORAGE}/img/cloudstack01.img 200G
~~~

## Create VM definition file

edit /tmp/cloudstack

~~~text
<domain type="kvm">
  <name>cloudstack</name>
  <memory>16777216</memory>
  <vcpu>12</vcpu>
  <sysinfo type="smbios">
    <system>
      <entry name="manufacturer">PyEngine</entry>
      <entry name="product">Orchestration Engine Node</entry>
      <entry name="version">2017.1</entry>
    </system>
  </sysinfo>
  <os>
    <type>hvm</type>
    <boot dev="hd"/>
    <boot dev="network"/>
    <smbios mode="sysinfo"/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <clock offset="utc">
    <timer name="pit" tickpolicy="delay"/>
    <timer name="rtc" tickpolicy="catchup"/>
  </clock>
  <cpu mode="host-model" match="exact"/>
  <devices>
    <disk type="file" device="disk">
      <driver name="qemu" type="qcow2" cache="none"/>
      <source file="${STORAGE}/img/cloudstack01.img"/>
      <target bus="virtio" dev="vda"/>
    </disk>
    <interface type='bridge'>
      <model type="virtio"/>
      <source bridge="virbr0"/>
      <mac address="${MGMT01_MAC0}"/>
    </interface>
    <interface type='bridge'>
      <model type="virtio"/>
      <source bridge="${MGMT}"/>
      <mac address="${MGMT01_MAC1}"/>
    </interface>
    <interface type='bridge'>
      <model type="virtio"/>
      <source bridge="${PUBLIC}"/>
      <mac address="${MGMT01_MAC2}"/>
    </interface>

    <serial type="pty"/>
    <input type="tablet" bus="usb"/>
    <graphics type="vnc" autoport="yes" keymap="en-us" listen="127.0.0.1"/>
  </devices>
</domain>
~~~

# Create PXE

edit /tmp/pxe-default

~~~text
# D-I config version 2.0
console 0
serial 0 115200 0

default CentOS 7.2

# install
label CentOS 7.2
    kernel centos${VER}/vmlinuz
    append initrd=centos${VER}/initrd.img vga=normal inst.stage2=http://ftp.daumkakao.com/centos/${VER}/os/x86_64/ inst.ks=https://raw.githubusercontent.com/zcost/orchestra-books/master/ks/cloudstack.7 ksdevice=bootif

prompt 0
timeout 10
~~~

Move definition of mgmt01 to storage folder

~~~bash
mv /tmp/pxe-default /var/lib/tftpboot/pxelinux.cfg/01-52-54-00-00-00-02
mv /tmp/cloudstack ${STORAGE}/
cd ${STORAGE}
virsh create cloudstack
~~~
