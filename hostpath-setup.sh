#!/bin/bash

# Run the following commands from the node hosting NFS:

# Create data directories and set permissions
mkdir -p /exports/registry
chown -R nfsnobody:nfsnobody /exports/registry
chmod -R 777 /exports/registry

mkdir -p /exports/metrics
chown -R nfsnobody:nfsnobody /exports/metrics
chmod -R 777 /exports/metrics

mkdir -p /exports/logging-es
chown -R nfsnobody:nfsnobody /exports/logging-es
chmod -R 777 /exports/logging-es

semanage fcontext -a -t nfs_t "/exports(/.*)?"

# Configure NFS
systemctl restart nfs-server
systemctl restart nfs
firewall-cmd --add-service=nfs
firewall-cmd --add-service=nfs --permanent
firewall-cmd --add-service=rpc-bind
firewall-cmd --add-service=rpc-bind --permanent
systemctl restart firewalld.service
semanage fcontext -a -t nfs_t "/exports(/.*)?"
restorecon -R -v /exports
exportfs -rv

# Set up mountpoint
echo '/dev/vdb2  /exports/registry   xfs   defaults  0 0' >> /etc/fstab
echo '/dev/vdb3  /exports/metrics    xfs   defaults  0 0' >> /etc/fstab
echo '/dev/vdb5  /exports/logging-es xfs   defaults  0 0' >> /etc/fstab
mount -a

