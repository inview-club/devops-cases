packer {
  required_plugins {
    qemu = {
      version = "= 1.1.8"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "astra_password" {
  type        = string
  sensitive   = true
  description = "Пароль пользователя user в исходной виртуальной машине."
}

variable "source_sha256" {
  type        = string
  description = "Контрольная сумма SHA-256 исходного QCOW2."
}

locals {
  source_image = abspath("${path.root}/.work/packer/astra.qcow2")
}

source "qemu" "astra" {
  qemu_binary = "qemu-system-x86_64"

  accelerator  = "tcg"
  machine_type = "pc"
  cpus         = 2
  memory       = 4096

  disk_image       = true
  iso_url          = local.source_image
  iso_checksum     = "sha256:${var.source_sha256}"
  format           = "qcow2"
  disk_interface   = "ide"
  skip_resize_disk = true

  output_directory = abspath("${path.root}/.work/packer-final")
  vm_name          = "astra.qcow2"

  net_device = "e1000"
  headless   = true

  qemuargs = [
    ["-cpu", "max"]
  ]

  ssh_username = "user"
  ssh_password = var.astra_password
  ssh_timeout  = "60m"

  shutdown_command = "sudo -n /sbin/shutdown -P now"
  shutdown_timeout = "10m"
}

build {
  sources = ["source.qemu.astra"]

  provisioner "file" {
    source      = "${path.root}/.work/id_ed25519.pub"
    destination = "/tmp/lab3-authorized-key.pub"
  }

  provisioner "shell" {
    script = "${path.root}/scripts/prepare-vagrant.sh"

    execute_command = "printf '%s\\n' '${var.astra_password}' | sudo -S -p '' /bin/bash '{{ .Path }}'"
  }

  provisioner "shell" {
    inline = [
      "sudo -k",
      "sudo -n /usr/bin/true"
    ]
  }
}
