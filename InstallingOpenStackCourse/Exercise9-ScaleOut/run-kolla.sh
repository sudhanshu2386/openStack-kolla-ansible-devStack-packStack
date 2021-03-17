#! /bin/sh

mount -t vboxsf vagrant /vagrant

cp /vagrant/.vagrant/machines/controller1/virtualbox/private_key .ssh/controller1.pem

cp /vagrant/.vagrant/machines/compute1/virtualbox/private_key .ssh/compute1.pem

cp /vagrant/.vagrant/machines/ceph1/virtualbox/private_key .ssh/ceph1.pem
cp /vagrant/.vagrant/machines/ceph2/virtualbox/private_key .ssh/ceph2.pem
cp /vagrant/.vagrant/machines/ceph3/virtualbox/private_key .ssh/ceph3.pem

chmod 600 .ssh/controller1.pem

chmod 600 .ssh/compute1.pem

chmod 600 .ssh/ceph1.pem
chmod 600 .ssh/ceph2.pem
chmod 600 .ssh/ceph3.pem

ssh -i .ssh/controller1.pem vagrant@controller1 echo "OK"

ssh -i .ssh/compute1.pem vagrant@compute1 echo "OK"

ssh -i .ssh/ceph1.pem vagrant@ceph1 echo "OK"
ssh -i .ssh/ceph2.pem vagrant@ceph2 echo "OK"
ssh -i .ssh/ceph3.pem vagrant@ceph3 echo "OK"


pip install ansible==2.5.2

pip install kolla-ansible==6.0.0

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla

cp /home/vagrant/run-kolla/globals.yml /etc/kolla

mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type = qemu
cpu_mode = none
EOF

cat << EOF > /etc/kolla/config/ceph.conf
[global]
mon max pg per osd = 3000
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
cp /home/vagrant/run-kolla/init-runonce /usr/local/share/kolla-ansible/init-runonce
. /etc/kolla/admin-openrc.sh
cd /usr/local/share/kolla-ansible
./init-runonce
echo "Horizon available at 10.0.0.10, user 'admin', password below:"
grep keystone_admin_password /etc/kolla/passwords.yml
