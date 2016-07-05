# Prepare Virtual Machine

Keyword         | Value             | Description
----            | ----              | ----
STORAGE         | /storage          | Directory for VM image
MGMT            | br-mgmt10g        | Bridge network
PUBLIC          | br-public10g      | Bridge network
UBUNTU_VER      | ubuntu-14.04.4-server-amd64.iso                   | Ubuntu 14.04 Image
UBUNTU_REPO     | http://ftp.daumkakao.com/ubuntu-releases/14.04    | Ubuntu 14.04 Repo
CENTOS_REPO     | http://ftp.daumkakao.com/centos/7/isos/x86_64     | CentOS 7 Repo
CENTOS_VER      | CentOS-7-x86_64-Minimal-1511.iso                  | CentOS 7 ISO
MGMT01_MAC1     | 52:54:00:00:01:01 | Management node MAC address 1
MGMT01_MAC2     | 52:54:00:00:02:01 | Management node MAC address 2

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

## Download CentOS Image from web

~~~bash
wget -O ${STORAGE}/iso/${UBUNTU_VER} ${UBUNTU_REPO}/${UBUNTU_VER}
wget -O ${STORAGE}/iso/${CENTOS_VER} ${CENTOS_REPO}/${CENTOS_VER}
~~~

## Create Virtual Disk

~~~bash
qemu-img create -f qcow2 ${STORAGE}/img/orchestra.img 100G
qemu-img create -f qcow2 ${STORAGE}/img/mgmt01.img 200G
~~~

## Create VM definition file

edit /tmp/orchestra

~~~text
<domain type="kvm">
  <name>orchestra</name>
  <memory>16777216</memory>
  <vcpu>12</vcpu>
  <sysinfo type="smbios">
    <system>
      <entry name="manufacturer">PyEngine</entry>
      <entry name="product">Orchestration Engine Node</entry>
      <entry name="version">2016.6</entry>
    </system>
  </sysinfo>
  <os>
    <type>hvm</type>
    <boot dev="cdrom"/>
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
      <source file="${STORAGE}/img/orchestra.img"/>
      <target bus="virtio" dev="vda"/>
    </disk>
     <disk type="file" device="cdrom">
      <source file="${STORAGE}/iso/${UBUNTU_VER}"/>
      <target dev="hdc"/>
    </disk>
    <interface type='bridge'>
      <model type="virtio"/>
      <source bridge="virbr0"/>
    </interface>
    <interface type='bridge'>
      <model type="virtio"/>
      <source bridge="${MGMT}"/>
    </interface>
    <interface type='bridge'>
      <model type="virtio"/>
      <source bridge="${PUBLIC}"/>
    </interface>

    <serial type="pty"/>
    <input type="tablet" bus="usb"/>
    <graphics type="vnc" autoport="yes" keymap="en-us" listen="127.0.0.1"/>
  </devices>
</domain>
~~~

Move definition of mgmt01 to storage folder

~~~bash
mv /tmp/orchestra ${STORAGE}/
cd ${STORAGE}
virsh create orchestra
~~~
