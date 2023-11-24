#!/bin/bash

hostname="kmaster"
kubermetes_dir="/var/tmp/Kubernetes"
ansible_dir="/var/tmp/Ansible"
nfs_server="kmaster"
new_kubernetes="/New/Kubernetes"
new_ansible="/New/Ansible"


# Get the IP address from Vagrant SSH config
vagrant up
ip_address=$(vagrant ssh-config | grep HostName | awk '{print $2}')

# Check if the IP address is not empty
if [ -n "$ip_address" ]; then
    # Update /etc/hosts with the new IP address for the specified hostname
    sudo sed -i "s/^.* $hostname$/$ip_address $hostname/" /etc/hosts
    echo "Updated /etc/hosts with new IP address for '$hostname'"
else
    echo "Failed to obtain IP address from Vagrant SSH config"
fi

sudo showmount -e $hostname


mkdir -p $kubermetes_dir
mkdir -p $ansible_dir
sudo mount -t nfs $hostname:/New/Kubernetes /var/tmp/Kubernetes
sudo mount -t nfs $hostname:/New/Ansible /var/tmp/Ansible

#Make sure the version is 4, do not use nfs3
sudo mount -t nfs4


# For unmounting created Volumes 
# sudo umount [directory_path]

