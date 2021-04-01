# Prepare the system

DEBIAN_FRONTEND=noninteractive sudo apt-get -y update
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y

# Get Extarnal IP of this Instance
externalip=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Clone devstack repo

git clone https://git.openstack.org/openstack-dev/devstack

cd devstack

# Prepare 'local.conf'
cat <<- EOF > local.conf
[[local|localrc]]
# Set basic passwords
ADMIN_PASSWORD=openstack
DATABASE_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=openstack
# Configure Nova novnc Proxy Base URL with External IP of this Instance
NOVNCPROXY_URL=http://$externalip:6080/vnc_auto.html
# Enable Heat
enable_plugin heat https://git.openstack.org/openstack/heat
# Enable Swift
enable_service s-proxy s-object s-container s-account
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data/swift
# Enable Cinder Backup
enable_service c-bak
# Enable Telemetry
enable_plugin gnocchi https://github.com/openstack/gnocchi master
enable_plugin ceilometer https://git.openstack.org/openstack/ceilometer
EOF

./stack.sh

# Install and enable Heat Dashboard

echo "Installing and enabling Heat Dashboard in Horizon"
sudo pip install heat-dashboard
cp /usr/local/lib/python2.7/dist-packages/heat_dashboard/enabled/_[1-9]*.py /opt/stack/horizon/openstack_dashboard/local/enabled
cat <<- EOF >> /opt/stack/horizon/openstack_dashboard/local/local_settings.py
POLICY_FILES = {
    'identity': 'keystone_policy.json',
    'compute': 'nova_policy.json',
    'volume': 'cinder_policy.json',
    'image': 'glance_policy.json',
    'network': 'neutron_policy.json',
    'orchestration': '/usr/local/lib/python2.7/dist-packages/heat_dashboard/conf/heat_policy.json',
}
EOF
cd /opt/stack/horizon
python manage.py compilemessages
DJANGO_SETTINGS_MODULE=openstack_dashboard.settings python manage.py collectstatic --noinput
DJANGO_SETTINGS_MODULE=openstack_dashboard.settings python manage.py compress --force
sudo service apache2 restart

echo "You can access Horizon Dashboard at External IP address: http://$externalip/dashboard"
