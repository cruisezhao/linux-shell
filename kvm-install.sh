#!/bin/sh
#Auto Make KVM Virtualization
#Author wugk 2013-12-06
#Defined Path
cat<<EOF
++++++++++++++++Welcome To Use Auto Install KVM Scripts ++++++++++++++++++
+++++++++++++++++++++++++This KVM Install Virtual ++++++++++++++++++++++++
+++++++++++++++++++++++++2013-12-06 Author wugk ++++++++++++++++++++++++++
EOF
KVM_SOFT=(
kvm python-virtinst libvirt  bridge-utils virt-manager qemu-kvm-tools  virt-viewer  virt-v2v libguestfs-tools
)
NETWORK=(
HWADDR=`ifconfigeth0 |egrep"HWaddr|Bcast"|tr"\n"" "|awk'{print $5,$7,$NF}'|sed-e 's/addr://g'-e 's/Mask://g'|awk'{print $1}'`
IPADDR=`ifconfigeth0 |egrep"HWaddr|Bcast"|tr"\n"" "|awk'{print $5,$7,$NF}'|sed-e 's/addr://g'-e 's/Mask://g'|awk'{print $2}'`
NETMASK=`ifconfigeth0 |egrep"HWaddr|Bcast"|tr"\n"" "|awk'{print $5,$7,$NF}'|sed-e 's/addr://g'-e 's/Mask://g'|awk'{print $3}'`
GATEWAY=`route -n|grep"UG"|awk'{print $2}'`
)
#Check whether the system supports virtualization
egrep'vmx|svm'/proc/cpuinfo>>/dev/null
if
[ "$?"-eq"0"];then
echo'Congratulations, your system success supports virtualization !'
else
echo-e 'OH,your system does not support virtualization !\nPlease modify the BIOS virtualization options (Virtualization Technology)'
exit0
fi
if
[ -e /usr/bin/virsh];then
echo"Virtualization is already installed ,Please exit ....";exit0
fi
yum -y install${KVM_SOFT[@]}
/sbin/modprobekvm
ln-s /usr/libexec/qemu-kvm/usr/bin/qemu-kvm
lsmod | grepkvm >>/dev/null
if
[ "$?"-eq"0"];then
echo'KVM installation is successful !'
else
echo'KVM installation is falis,Please check ......'
exit1
fi
cd/etc/sysconfig/network-scripts/
mkdir-p /data/backup/`date+%Y%m%d-%H:%M:%S`
yes|cpifcfg-eth* /data/backup/`date+%Y%m%d-%H:%M:%S`/
if
[ -e /etc/sysconfig/network-scripts/ifcfg-br0];then
echo"The ifcfg-br0 already exist ,Please wait exit ......"
exit2
else
cat>ifcfg-eth0 <<EOF
DEVICE=eth0
BOOTPROTO=none
${NETWORK[0]}
NM_CONTROLLED=no
ONBOOT=yes
TYPE=Ethernet
BRIDGE="br0"
${NETWORK[1]}
${NETWORK[2]}
${NETWORK[3]}
USERCTL=no
EOF
cat>ifcfg-br0 <<EOF
DEVICE="br0"
BOOTPROTO=none
${NETWORK[0]}
IPV6INIT=no
NM_CONTROLLED=no
ONBOOT=yes
TYPE="Bridge"
${NETWORK[1]}
${NETWORK[2]}
${NETWORK[3]}
USERCTL=no
EOF
fi
echo'Your can restart Ethernet Service: /etc/init.d/network restart !'
echo'---------------------------------------------------------'
sleep1
echo'Your can restart KVM Service : /etc/init.d/libvirtd restart !'
echo
echo-e "You can create a KVM virtual machine: \nvirt-install --name=centos01 --ram 512 --vcpus=1 --disk path=/data/kvm/centos01.img,size=7,bus=virtio --accelerate --cdrom /data/iso/centos58.iso --vnc --vncport=5910 --vnclisten=0.0.0.0 --network bridge=br0,model=virtio --noautoconsole"
