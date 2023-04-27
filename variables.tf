variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/var/lib/libvirt/pool/debian-pool"
}

variable "img_url" {
  description = "debian image"
  default     = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.6.0-amd64-netinst.iso"
}

variable "vm_hostname" {
  description = "vm hostname"
  default     = "debter"
}

variable "ssh_username" {
  description = "the ssh user to use"
  default     = "debian"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default     = "~/.ssh/id_rsa"
}
