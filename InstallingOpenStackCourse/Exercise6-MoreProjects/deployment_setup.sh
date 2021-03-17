#! /bin/sh

cp /vagrant/deployment_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y

apt install -y python-jinja2 python-pip libssl-dev
apt install -y lvm2 thin-provisioning-tools curl vim
pip install -U pip

mkdir -p /home/vagrant/run-kolla
cp /vagrant/globals.yml /home/vagrant/run-kolla
cp /vagrant/run-kolla.sh /home/vagrant/run-kolla
cp /vagrant/init-runonce /home/vagrant/run-kolla
cp /vagrant/multinode /home/vagrant/run-kolla

reboot
