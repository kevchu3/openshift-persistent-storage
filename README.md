OpenShift Hostpath Examples
===========================

The following examples are the hostpath implementation of the internal Docker registry and Cassandra (for Hawkular metrics) on a single node hostpath using NFS.

Disclaimer
----------
This is for lab installation and educational purposes only and not to be used in a production environment.

The use of NFS for the core OpenShift Container Platform components is not recommended, as NFS (and the NFS Protocol) does not provide the proper consistency needed for the applications that make up the OpenShift Container Platform infrastructure.

Requirements
------------

* OpenShift 3.3+

Setup
-----

Create a new partition for each of Docker registry and Cassandra (assumes Docker pool has already been created)
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
└─vdb3        252:19   0    5G  0 part /exports/metrics
```

Format the new partitions
```
mkfs.xfs /dev/vdb2
mkfs.xfs /dev/vdb3
```

Deploy
------

Run the hostpath setup from the node that will be used to host the registry and metrics.
```
./hostpath-setup.sh
```

Copy the files in `group_vars/OSEv3` and run the base Ansible playbooks to configure the Docker registry and Hawkular metrics
```
cp group_vars/OSEv3 <destination>
ansible-playbook -i hosts.lab config.yml
```

If needed, manually create the PersistentVolume for metrics:
```
oc create -f metrics-volume.pv.yml
```

License
-------

GPLv3

Author
------

Kevin Chung
