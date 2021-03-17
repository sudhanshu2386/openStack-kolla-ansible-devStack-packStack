#! /bin/sh

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

sed -i -e 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf

cat <<- EOF > /etc/sysconfig/network-scripts/ifcfg-enp0s8
DEVICE="enp0s8"
DEFROUTE="no"
BOOTPROTO="static"
IPADDR="10.0.0.20"
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

echo 'centos' >/etc/yum/vars/contentdir

systemctl disable firewalld
systemctl stop firewalld
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network



yum install -y centos-release-openstack-pike
yum update -y
yum install -y openstack-packstack

cat <<- EOF > /home/vagrant/run-packstack.sh
export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8
echo "Running 'ssh vagrant@compute1'"
echo "The password is 'vagrant'"
ssh vagrant@compute1 echo "OK"
echo "Running 'ssh vagrant@compute2'"
echo "The password is 'vagrant'"
ssh vagrant@compute2 echo "OK"
echo "Running packstack with options"
echo "The 'root' password is 'vagrant'"
packstack --install-hosts="10.0.0.20","10.0.0.21","10.0.0.22" --os-heat-install=y --os-heat-cfn-install=y --os-neutron-lbaas-install=y --keystone-admin-passwd="openstack" --keystone-demo-passwd="openstack"
EOF

chown vagrant:vagrant /home/vagrant/run-packstack.sh
