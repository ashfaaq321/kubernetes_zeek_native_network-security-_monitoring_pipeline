# For local persistent volumes we need nfs server
# -------------------- Installation of nfs server --------------------W
# What is ephermeral volumes? 
# A) These are volumes which are temporary and lasts very short period of time
# Different types of ephemeral volumes are emptydir, configmap, secret, downward API etc.
 
#Install NFS Server
#Install NFS Server and create the directory for our exports on your master node

sudo apt install nfs-kernel-server -y 
sudo mkdir -p /export/volumes
sudo mkdir -p /export/volumes/static
sudo mkdir -p /export/volumes/dynamic

sudo bash -c 'echo "/export/volumes  *(rw,no_root_squash,no_subtree_check)" > /etc/exports'
cat /etc/exports
sudo systemctl restart nfs-kernel-server.service

# Install NFS Client on worker nodes of cluster

#On each Node in your cluster...install the NFS client.
sudo apt install nfs-common -y

#Test out basic NFS access before moving on.
sudo mount -t nfs4 kmaster:/export/volumes /mnt/
mount | grep nfs
sudo umount /mnt
