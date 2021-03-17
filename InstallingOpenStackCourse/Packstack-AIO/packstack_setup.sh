#! /bin/sh

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf

cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-eth1
DEVICE="eth1"
DEFROUTE="no"
BOOTPROTO="static"
IPADDR="10.0.0.20"
NETMASK="255.255.255.0"
DNS1="8.8.8.8"
TYPE="Ethernet"
ONBOOT=yes
EOF

ifdown eth1
ifup eth1

cat <<- EOF > /etc/hosts
127.0.0.1 localhost
10.0.0.20 packstack
EOF

echo 'centos' >/etc/yum/vars/contentdir

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network



yum install -y centos-release-openstack-pike
yum-config-manager --enable openstack-pike
yum update -y
yum install -y openstack-packstack
yum install -y lvm2

packstack --install-hosts="10.0.0.20" \
 --os-heat-install=y --os-heat-cfn-install=y \
 --os-neutron-lbaas-install=y --keystone-admin-passwd="openstack" --keystone-demo-passwd="openstack"
