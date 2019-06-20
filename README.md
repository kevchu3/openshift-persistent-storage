OpenShift Persistent Storage
===========================

The following are persistent storage examples on OpenShift:
* Hostpath implementation of infrastructure components (registry, metrics, logging) on a single node using NFS
* GlusterFS implementation for applications
* Additional customization of NFS for Docker registry

Disclaimer
----------

This is for lab installation and educational purposes only and not to be used in a production environment.

The use of NFS for the core OpenShift Container Platform components is not recommended, as NFS (and the NFS Protocol) does not provide the proper consistency needed for the applications that make up the OpenShift Container Platform infrastructure.

Requirements
------------

* OpenShift Container Platform 3.11
* OpenShift Container Storage 3.11 (for application persistent storage only)

Setup
-----

To configure persistent storage, the cluster should have the following tiers:
* Master node(s)
* 1 infrastructure node - with NFS storage
* 3 GlusterFS nodes - for OpenShift Container Storage (OCS) converged mode
* N application nodes

On the infra node, create a new partition for each of Docker registry and Cassandra (assumes Docker pool has already been created)
```
fdisk /dev/vdb
               enter "n" #To create new partition (vdb2 with all defaults)
               enter "t" #To tag/label the partition which got created (tag "8e")
               enter "w" #To write the created partition to the server
partprobe /dev/vdb
```

The resulting partitions should look something like this:
```
lsblk
...
vdb           252:16   0   50G  0 disk 
├─vdb1        252:17   0   30G  0 part /var/lib/docker
├─vdb2        252:18   0   15G  0 part /exports/registry
├─vdb3        252:19   0    5G  0 part /exports/metrics
├─vdb4        252:20   0    1K  0 part 
└─vdb5        252:21   0   10G  0 part /exports/logging-es
```

Format the new partitions
```
mkfs.xfs /dev/vdb2
mkfs.xfs /dev/vdb3
mkfs.xfs /dev/vdb5


```

Deploy
------

Run the hostpath setup from the node that will be used to host the registry, metrics, and logging.
```
./hostpath-setup.sh
```

Run the GlusterFS setup from the nodes that will be used to host application persistent storage.
```
./glusterfs-setup.sh
```

Copy the files in `group_vars/OSEv3` and run the base Ansible playbooks to configure infrastructure and application persistent storage:
```
cp group_vars/OSEv3 <destination>
ansible-playbook -i hosts.lab config.yml
```

If needed, manually create the PersistentVolume for metrics:
```
oc create -f metrics-volume.pv.yml
oc create -f logging-volume.pv.yml
```

Optionally, to apply NFS customizations on the Docker registry:
ansible-playbook -i hosts.lab post-config.yml

License
-------

GPLv3

Author
------

Kevin Chung
