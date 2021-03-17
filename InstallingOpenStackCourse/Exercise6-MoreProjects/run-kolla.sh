#! /bin/sh

mount -t vboxsf vagrant /vagrant

cp /vagrant/.vagrant/machines/controller/virtualbox/private_key .ssh/controller.pem
cp /vagrant/.vagrant/machines/compute1/virtualbox/private_key .ssh/compute1.pem
cp /vagrant/.vagrant/machines/compute2/virtualbox/private_key .ssh/compute2.pem
chmod 600 .ssh/controller.pem
chmod 600 .ssh/compute1.pem
chmod 600 .ssh/compute2.pem

ssh -i .ssh/controller.pem vagrant@controller echo "OK"
ssh -i .ssh/compute1.pem vagrant@compute1 echo "OK"
ssh -i .ssh/compute2.pem vagrant@compute2 echo "OK"


pip install ansible

pip install kolla-ansible==6.0.0

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla

cp /home/vagrant/run-kolla/globals.yml /etc/kolla

mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type = qemu
cpu_mode = none
EOF

kolla-genpwd

kolla-ansible -i run-kolla/multinode bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

kolla-ansible -i run-kolla/multinode prechecks

if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

kolla-ansible -i run-kolla/multinode deploy

if [ $? -ne 0 ]; then
  echo "Deploy failed"
  exit $?
fi

kolla-ansible post-deploy

pip install python-openstackclient

cp /home/vagrant/run-kolla/init-runonce .
. /etc/kolla/admin-openrc.sh
cd /usr/local/share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
