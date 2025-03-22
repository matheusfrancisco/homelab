resource "proxmox_vm_qemu" "masters" {

    count = var.master_nr
    target_node = var.target_node

    name = format("%s-${count.index + 1}", var.master_naming)
    vmid = var.master_id_range + count.index + 1


    clone = "debian-11-cloudinit-template"
    onboot = true 
    agent = 1 
    os_type = "cloud-init"
    cpu = "host"

    cores = var.master_cores
    sockets = var.master_sockets
    memory = var.master_memory
    ciuser = var.ciuser
    
    sshkeys = var.ssh_keys
    ipconfig0 = "ip=${cidrhost(var.bridge_cidr_range, var.master_network_range + count.index)}/24,gw=${cidrhost(var.bridge_cidr_range, 1)}"

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
               size = var.master_disksize
               storage = "local-lvm"
            }
         }
      }
    }
    boot = "order=scsi0;ide2"

    tags = "masters"

}
