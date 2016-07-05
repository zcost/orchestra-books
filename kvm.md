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


