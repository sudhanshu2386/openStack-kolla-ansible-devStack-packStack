#! /bin/sh

cp /vagrant/controller_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y

apt install -y python python-simplejson glances
apt install -y lvm2 thin-provisioning-tools

echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload

pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdc

reboot
