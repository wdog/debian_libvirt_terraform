    variable "vm_name"  {
        description = "VM name"
        default = "gino"
    }
    variable "libvirt_disk_path" {
        description = "path for libvirt pool"
        default     = "/var/lib/libvirt/pool/gino-pool"   
    }
    variable "libvirt_pool_name" {
        description = "path for libvirt pool"
        default     = "gino-pool"   
    }
