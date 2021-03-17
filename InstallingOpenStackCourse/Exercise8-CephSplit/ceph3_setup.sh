#! /bin/sh

cp /vagrant/ceph3_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y

apt install -y python python-simplejson glances

parted /dev/sdc -s -- mklabel gpt mkpart KOLLA_CEPH_OSD_BOOTSTRAP 1 -1

echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload

reboot
