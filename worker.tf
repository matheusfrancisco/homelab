resource "proxmox_vm_qemu" "workers" {

    count = var.worker_nr
    
    # VM General Settings
    target_node = var.target_node
    vmid = var.worker_id_range + count.index + 1
    name = format("%s-${count.index + 1}", var.worker_naming)

    # VM Advanced General Settings
    onboot = true 

    # VM OS Settings
    clone = "ubuntu-2204-cloud-init"

    # VM System Settings
    agent = 1
    
    # VM CPU Settings
    cores = var.worker_cores
    sockets = var.worker_sockets

    # VM Memory Settings
    memory = var.worker_memory

    # Cloud-Init
    ciuser = var.ciuser
    sshkeys = var.ssh_keys
    ipconfig0 = "ip=${cidrhost(var.bridge_cidr_range, var.worker_network_range + count.index)}/24,gw=${cidrhost(var.bridge_cidr_range, 1)}"

    # VM Network Settings
    network {
      id = count.index + 1
      bridge = var.bridge_network
      model  = "virtio"
      firewall = true
    }

    disk {
      type = "disk"
      slot = "scsi0"
      storage = "local-lvm"
      size = var.worker_disksize
    }

    tags = "workers"

}
