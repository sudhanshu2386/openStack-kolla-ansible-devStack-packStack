# Prepare the system

DEBIAN_FRONTEND=noninteractive sudo apt-get -y update
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y

# Get External IP of this Instance
externalip=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# Clone devstack Pike repo

git clone https://git.openstack.org/openstack-dev/devstack -b stable/pike

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
enable_plugin heat https://git.openstack.org/openstack/heat stable/pike
# Enable Swift
enable_service s-proxy s-object s-container s-account
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data/swift
# Enable Cinder Backup
enable_service c-bak
EOF

./stack.sh

echo "You can access Horizon Dashboard at External IP address: http://$externalip/dashboard"
