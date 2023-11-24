terraform {
  required_version = ">= 0.13"
  
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.0"
    }
  }
}

# Instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "new_bullseye_basic" {
  name = "new_bullseye_basic"
  type = "dir"
  path = "/home/atm/code/libvirt/pool/new_bullseye_basic"
}

# Fetch the latest bullseye_basic release image from their mirrors
resource "libvirt_volume" "debian-bullseye-qcow2" {
  name   = "debian-bullseye-qcow2"
  pool   = libvirt_pool.new_bullseye_basic.name
  source = "/home/ashfaaq/images/debian/debian-11-generic-amd64.qcow2"
  format = "qcow2"
}

variable "loadbalance_count" {
  default = 2
}

resource "libvirt_volume" "domain_bullseye_loadbalance_volume" {
  name           = "domain_bullseye_loadbalance_volume-${count.index}"
  base_volume_id = libvirt_volume.debian-bullseye-qcow2.id
  count          = var.loadbalance_count
  pool           = libvirt_pool.new_bullseye_basic.name
  size           = 85368709120
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.new_bullseye_basic.name
}

# Create the machine
resource "libvirt_domain" "domain_bullseye_loadbalance" {
  count = var.loadbalance_count

  name   = "bullseye_loadbalance_${count.index}"
  memory = "8192"
  vcpu   = 8

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.domain_bullseye_loadbalance_volume.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

locals {
  loadbalance_vm_ips   = [for i in libvirt_domain.domain_bullseye_loadbalance : i.network_interface.0.addresses[0]]
  loadbalance_vm_names = [for i in libvirt_domain.domain_bullseye_loadbalance : i.name]
  loadbalance_vm_map   = [for i in libvirt_domain.domain_bullseye_loadbalance : {
    ip   = i.network_interface.0.addresses[0]
    name = i.name
  }]
}

output "bullseye_loadbalance_ip" {
  value = local.loadbalance_vm_map
}

resource "local_file" "hosts_yml" {
  content  = templatefile("./templates/hosts.yml.tftpl", {
    loadbalance_vm_ips   = local.loadbalance_vm_ips,
    loadbalance_vm_names = local.loadbalance_vm_names,
    loadbalance_vms      = local.loadbalance_vm_map
  })

  filename = "./ansible/inventory/hosts.ini"
}

#resource "local_file" "nginx_loadbalance_conf" {
 # content  = templatefile("./templates/nginx-libreddit.tftpl", {
  #  loadbbalance_vm_ips   = local.loadbalance_vm_ips,
  #  loadbalance_vm_names = local.loadbalance_vm_names,
  #  loadbalance_vms      = local.loadbalance_vm_map
 # })

 # filename = "./ansible/assets/nginx.cfg"
#}


