provider "libvirt" {
  uri = "qemu+ssh://root@192.168.122.1/system"
}

# from pool
resource "libvirt_pool" "debian" {
  name = "debian-pool"
  type = "dir"
  path = var.libvirt_disk_path
}

resource "libvirt_volume" "root" {
  name = "debian-root.qcow2"
  size = 4 * 1024 * 1024 * 1024
  pool = libvirt_pool.debian.name
}

resource "libvirt_volume" "swap" {
  name = "debian-swap.qcow2"
  size = 512 * 1024 * 1024
  pool = libvirt_pool.debian.name
}

resource "libvirt_volume" "netinstall" {
  name = "netinstall.iso"
  source = "debian-netinst-preseed.iso"
  pool = libvirt_pool.debian.name
}
# MAIN 


resource "libvirt_domain" "debian" {
  name = var.vm_hostname
  memory = 8192
  vcpu = 8

  disk {
    volume_id = libvirt_volume.root.id
  }

  disk {
    volume_id = libvirt_volume.swap.id
  }

  disk {
    file = "${var.libvirt_disk_path}/netinstall.iso" 
  }


  boot_device {
    dev = [ "hd", "cdrom"]
  }

  network_interface {
    network_name = "default"
  }

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

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}


