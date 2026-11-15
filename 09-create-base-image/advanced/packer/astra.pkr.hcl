packer {
  required_plugins {
    docker = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "astra" {
  image  = "ubuntu:22.04" # База для демонстрации
  commit = true
}

build {
  sources = ["source.docker.astra"]

  provisioner "shell" {
    scripts = [
      "scripts/01-install-prereqs.sh",
      "scripts/02-install-docker-debootstrap.sh"
    ]
  }

  post-processor "docker-import" {
    repository = "astra-base"
    tag        = "advanced"
  }
}
