# Case №9 - Creating a Docker Image Based on Astra Linux Virtual Machine

- [Case №9 - Creating a Docker Image Based on Astra Linux Virtual Machine](#case-9---creating-a-docker-image-based-on-astra-linux-virtual-machine)
  - [Purpose](#purpose)
  - [Tech Stack](#tech-stack)
  - [Milestones](#milestones)
  - [Outcome](#outcome)
  - [Contacts](#contacts)

## Purpose

Docker images are convenient for building or deploying applications—but how are they created if the distribution isn't available on Docker Hub or other sources? Let's explore the steps to create an image using a file system, standard Debian-like utilities, and archiving.

## Tech Stack

![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)
![bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=fff)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)

## Milestones

1. **Set up infrastructure for creating and running virtual machines:**
   - Required packages: `virt-install`, `qemu-kvm`, `libvirt-daemon-system` or equivalents if using other distributions.
   - Astra Linux image in .iso format (only version 1.7) or .ova (version 1.8, which will need to be converted to a .qcow2 disk image)—for example, from the [Easy Astra](https://easyastra.ru/resources/astralinux.php) portal.
   - Alternative: Use `HashiCorp Packer`, which allows you to describe virtual machine creation using HashiCorp Configuration Language (also used in Terraform).
2. **Create a virtual machine and install necessary packages:**
   - For working with VMs via `qemu` use `virt-install`. You can connect to the VM via SSH (to obtain the IP address, use `virsh`). Necessary parameters for `virt-install` can be found in any available source. We are dealing with a standard Debian-like distribution. Peripheral devices are optional, but it's advisable to configure shared folders via `virtiofs`. In `Packer` you can map a `sharedfolder`. Install `docker.io` (or follow the official website instructions) and `debootstrap`.
3. **Create a Docker image in .tar format using debootstrap:**
   - Using `debootstrap`, set up an isolated `chroot` environment with basic packages (e.g. `ncurses-term`, `nano`, `locales`).
   - Create a file system image using `tar`.
   - Transfer the `tar` file to the host operating system and mount it via `docker import`.

## Outcome

The host operating system contains a Docker image based on Astra Linux. The image can be run and includes a command shell.

## Contacts

Need help? Write to [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)!
