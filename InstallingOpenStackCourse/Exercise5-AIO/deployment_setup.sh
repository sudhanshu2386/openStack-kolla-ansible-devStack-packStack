#! /bin/sh

cp /vagrant/deployment_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y

apt install -y python-jinja2 python-pip libssl-dev
apt install -y lvm2 thin-provisioning-tools curl
pip install -U pip

pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdc

echo "configfs" >> /etc/modules
update-initramfs -u
systemctl daemon-reload

mkdir -p /home/vagrant/kolla
cp /vagrant/globals.yml /home/vagrant/kolla
cp /vagrant/run-kolla.sh /home/vagrant/kolla
cp /vagrant/init-runonce /home/vagrant/kolla

reboot
