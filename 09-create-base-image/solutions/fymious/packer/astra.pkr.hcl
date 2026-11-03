packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.1.0"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = ">= 1.1.0"
    }
  }
}

variable "iso_path"     { default = "iso/astra-preseed.iso" }
variable "iso_checksum" { default = "sha256:f9fcfd047a7a1ec2e29e522f97a7a2dd64fc942ccd5dff522ed34e780c4f20e8" }

source "qemu" "astra" {
  iso_url          = "file://${abspath(var.iso_path)}"
  iso_checksum     = var.iso_checksum
  vm_name          = "astra17.qcow2"
  output_directory = "output-astra"
  format           = "qcow2"
  accelerator      = "kvm"
  cpus             = 2
  memory           = 2048
  disk_size        = "20G"
  headless         = false
  http_directory   = "http"
  net_device       = "virtio-net"
  disk_interface   = "virtio"

  boot_wait = "2s"
  boot_command = [
    "<down><wait>",
    "<enter><wait>",
    "<down><wait>",
    "<f2><wait><esc><wait>",
    " auto=true priority=critical preseed/file=/cdrom/preseed.cfg",
    " debian-installer/locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=us",
    " grub-installer/bootdev=/dev/vda astra-license/license=true<enter>",
    " debian-installer/locale=en_US.UTF-8 debian-installer/language=en debian-installer/country=US",
    " keyboard-configuration/xkb-keymap=us",
  ]

  ssh_username     = "vagrant"
  ssh_password     = "Vagrant123"
  ssh_timeout      = "60m"
  shutdown_command = "echo Vagrant123 | sudo -S shutdown -P now"
}

build {
  sources = ["source.qemu.astra"]

  provisioner "shell" {
    execute_command = "echo Vagrant123 | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "apt-get update",
      "apt-get install -y docker.io debootstrap rsync",
      "usermod -aG docker vagrant"
    ]
  }

  post-processor "vagrant" {
    output = "astra17.box"
  }
}
