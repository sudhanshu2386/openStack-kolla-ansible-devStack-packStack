#! /bin/sh

pip install ansible==2.5.2

pip install kolla-ansible==6.0.0

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla
cp /home/vagrant/kolla/globals.yml /etc/kolla
mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type = qemu
cpu_mode = none
EOF
# vim /etc/kolla/globals.yml
# ifconfig
# ip a

kolla-genpwd
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one bootstrap-servers
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one prechecks
kolla-ansible -i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one deploy
kolla-ansible post-deploy
pip install python-openstackclient
cp /home/vagrant/kolla/init-runonce /usr/local/share/kolla-ansible/init-runonce
. /etc/kolla/admin-openrc.sh
cd /usr/local/share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
