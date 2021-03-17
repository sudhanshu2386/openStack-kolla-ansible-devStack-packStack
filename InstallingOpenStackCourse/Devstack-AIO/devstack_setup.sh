#! /bin/sh

export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

sudo apt-get install -y git

git clone https://git.openstack.org/openstack-dev/devstack

cp /devstack/local.conf devstack

cd devstack
./stack.sh
