#! /bin/sh

mount -t vboxsf vagrant /vagrant

cp /vagrant/.vagrant/machines/controller/virtualbox/private_key .ssh/controller.pem
cp /vagrant/.vagrant/machines/compute1/virtualbox/private_key .ssh/compute1.pem
cp /vagrant/.vagrant/machines/block1/virtualbox/private_key .ssh/block1.pem
chmod 600 .ssh/controller.pem
chmod 600 .ssh/compute1.pem
chmod 600 .ssh/block1.pem

ssh -i .ssh/controller.pem vagrant@controller echo "OK"
ssh -i .ssh/compute1.pem vagrant@compute1 echo "OK"
ssh -i .ssh/block1.pem vagrant@block1 echo "OK"

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
kolla-ansible -i kolla/multinode bootstrap-servers
kolla-ansible -i kolla/multinode prechecks
kolla-ansible -i kolla/multinode deploy

kolla-ansible post-deploy
pip install python-openstackclient
cp /home/vagrant/kolla/init-runonce /usr/local/share/kolla-ansible/init-runonce
. /etc/kolla/admin-openrc.sh
cd /usr/local/share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
