#!/bin/bash

# Run the following commands from the registry/metrics node:

# Create data directories and set permissions
mkdir -p /exports/registry
#chown -R nfsnobody:nfsnobody /exports
#chmod -R 777 /exports
chown -R 1000000000.1000000000 /exports/registry
chmod -R 777 /exports/registry

mkdir -p /exports/metrics
chown -R 1000000000.1000000000 /exports/metrics
chmod -R 777 /exports/metrics
semanage fcontext -a -t nfs_t "/exports(/.*)?"

# Configure NFS
echo '/exports/registry *(rw)' >> /etc/exports
echo '/exports/metrics *(rw)' >> /etc/exports
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
mount -a

