#! /bin/sh

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf
echo 'centos' >/etc/yum/vars/contentdir

cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-enp0s8
DEVICE="enp0s8"
DEFROUTE="no"
BOOTPROTO="static"
IPADDR="10.0.0.22"
NETMASK="255.255.255.0"
DNS1="8.8.8.8"
TYPE="Ethernet"
ONBOOT=yes
EOF

ifdown enp0s8
ifup enp0s8

cat <<- EOF > /etc/hosts
127.0.0.1 localhost
10.0.0.20 packstack
10.0.0.21 compute1
10.0.0.22 compute2
EOF

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network
