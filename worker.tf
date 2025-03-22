resource "proxmox_vm_qemu" "workers" {
    count = var.worker_nr
    target_node = var.target_node

    name = format("%s-${count.index + 1}", var.worker_naming)
    vmid = var.worker_id_range + count.index + 1


    clone = "debian-11-cloudinit-template"
    onboot = true 
    agent = 1 
    os_type = "cloud-init"
    cpu = "host"

    cores = var.worker_cores
    sockets = var.worker_sockets
    memory = var.worker_memory
    ciuser = var.ciuser
    
    sshkeys = var.ssh_keys
    ipconfig0 = "ip=${cidrhost(var.bridge_cidr_range, var.worker_network_range + count.index)}/24,gw=${cidrhost(var.bridge_cidr_range, 1)}"

    network {
        bridge = var.bridge_network
        model  = "virtio"
    }

    disks {
      ide {
          ide2 {
              cloudinit {
                 storage = "local-lvm"
              }
          }
      }
      scsi {
         scsi0 {
            disk {
               size = var.worker_disksize
               storage = "local-lvm"
            }
         }
      }
    }
    boot = "order=scsi0;ide2"

    tags = "workers"

}
