#!/bin/bash
set -euo pipefail
sudo debootstrap --arch=amd64 --include=ncurses-term,nano,locales \
  orel /tmp/astra-chroot \
  https://dl.astralinux.ru/astra/stable/2.12_x86-64/repository/
sudo chroot /tmp/astra-chroot apt-get clean
sudo sh -c "tar -C /tmp/astra-chroot -c . > /tmp/astra-rootfs.tar"
sha256sum /tmp/astra-rootfs.tar
