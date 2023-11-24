# Load-balanced libreddit deployment

Use KVM/QEMU, Docker, libvirt, Terraform, and Ansible to deploy
loadbalanced (https://github.com/libreddit/libreddit/).

## Dependencies

1. GNU/Linux host machine
2. KVM
3. QEMU
4. Libvirt
5. Terraform
6. Python 3
7. Ansible
8. Testinfra
9. Debian 11 Bullseye qcow2 bootable

## Usage instructions

### 1. Provision resources (VMs) on KVM using Terraform

1. Generate and verify deployment plan

```bash
terraform plan 
```

2. Apply deployment plan

```bash
terraform apply 
```

### 2. Verify VMs are reachable from host

```bash
make configure.ping
```

### 3. Configure VMs

```bash
make configure
```

### 4. Test deployment

```bash
make test
```

### 5. Take down deployment

```bash
terraform destroy
```


