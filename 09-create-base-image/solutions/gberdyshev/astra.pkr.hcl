packer {
    required_plugins {
        qemu = {
            version = ">= 1.1.4"
            source = "github.com/hashicorp/qemu"
        }
        vagrant = {
            version = ">= 1.1.6"
            source = "github.com/hashicorp/vagrant"
        }
    }
}

source "qemu" "astra" {
    disk_image        = true
    iso_url           = "output.qcow2"
    iso_checksum      = "md5:3880676c92b388f924d9a9923305082e"
    format            = "qcow2"
    ssh_username      = "vagrant"
    ssh_password      = "vagrant"
    skip_resize_disk  = true
    headless          = true
    shutdown_command = "sudo shutdown -P now"

}

build {
    sources = ["source.qemu.astra"]
    post-processor "vagrant" {
        output = "astra.box"
        keep_input_artifact = true
    }
}