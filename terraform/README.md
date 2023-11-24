# Load-balanced libreddit deployment

Use KVM/QEMU, Docker, libvirt, Terraform, and Ansible to deploy
loadbalanced [libreddit](https://github.com/libreddit/libreddit/) and
verify deployment with Testinfra.

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
terraform plan -out=libreddit
```

2. Apply deployment plan

```bash
terraform apply "libreddit"
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

## Functions

Utility scripts exist for the following operations:

```bash
19:46 atm@lab iac ±|master ✗|→ make help
configure                      Configure whole deployment
configure.ping                 Ping all VMs
configure.base                 Configure all VMs to base production configuration
configure.libreddit            Configure libreddit
configure.loadbalance          Configure loadbalancer
lint                           Lint source code
on                             Boot VMs
shutdown                       Shutdown VMs
test                           Run all tests
test.base                      Test base configuration on all VMs
test.loadbalance               Test loadbalancer installation
test.libreddit                 Test libreddit installation
help                           Prints help for targets with comments
```
