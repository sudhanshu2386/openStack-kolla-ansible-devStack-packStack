#! /bin/sh

cp /vagrant/deployment_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y

apt install -y python-jinja2 python-pip libssl-dev curl vim
pip install -U pip

reboot
