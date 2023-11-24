Note: Below Instructions can be done automatically by using /Kubernetes/Automate/automate.sh, but make sure all requirements related to vagrant, libvirt, ansible and nfs are installed and configured correctly, Make changes according to your needs.

Starting with a new Virtual Machine?, No-problem, here is a complete walkthrough.

   Optional(Connect to github)
   ```sh
   ssh-keygen -t ed25519 -C "newk8"
   ```
   Add necessary Details to ssh key and Paste it in git. 
   Clone the repository, for making changes anytime. 
   
   Make sure to give authenticity of your github
   ```sh
   git config --global user.name "VenkataKarthik0211"
   git config --global user.email "sacredspirits47@gmail.com"
   ```
   To push all changes
   ```sh
   git add .
   git commit -m "Modifications done"
   git push origin -o main
   ```
   Install libvrit and virt-manager
   ```sh
   sudo apt update
   sudo apt install build-essential qemu-kvm libvirt-daemon-system libvirt-dev 
   sudo apt install virt-manager
   virsh list
   sudo systemctl start libvirtd
   sudo systemctl enable libvirtd
   ```
   Install Vagrant
   ```sh
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt sources.list.d/hashicorp.list
   sudo apt update && sudo apt install vagrant
   ```
   Install and enable nfs-server for PV and PVC setup
   ```sh
   sudo apt install nfs-server && sudo systemctl enable nfs-server && sudo systemctl start nfs-server
   ```
   Create a directory of your choice in my case: /var/tm/Kubernetes/nfs for mounting the volume
   ```sh
   sudo mkdir -p /var/tmp/Kubernetes/nfs
   sudo chow nobody: /var/tmp/Kubernetes/nfs
   ```
   Edit /etc/exports and add your directory in this file as follows
   
   /var/tmp/Kubernetes/nfs      *(rw,sync,no_subtree_check, no_root_squash, no_all_squash, insecure)
   ```sh
   echo '/var/tmp/Kubernetes/nfs *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)' | sudo tee -a /etc/exports
   sudo exportfs -rav 
   sudo exportfs -v
   ```
   
   Make sure to use script1.sh, kmaster-script2.sh, kworker2.sh.
   Make use of scrit3.sh for loadbalancer and installation of istio
   
   (Kubernetes nodes) - NFS clients, mounting at a common directory ~/nfs - for backup and test 
   ```sh
   echo "IP_Address_of_nfs_server:/var/tmp/Kubernetes/nfs /home/yourusername/nfs nfs defaults 0 0" | sudo tee -a /etc/fstab
   sudo mount -t nfs4 IP_Address_of_nfs_server:/var/tmp/Kubernetes/nfs ~/nfs
   ```
   ```sh
   ```
   ```sh
   ```

