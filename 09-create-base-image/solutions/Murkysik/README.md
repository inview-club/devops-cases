## Решение:
### Схема моей реализации: 

```

+-------------------------+
|      Windows 11/10      |
|  (хостовая система)     |
+-----------+------------+
            |
            |  Orаcle  VirtualBox
            v
+-------------------------+
|        Debian           |
|     (гостевая VM)       |
+-----------+-------------+
            |
            | QEMU/KVM + libvirt + virtiofs
            v
+-------------------------+
|      Astra Linux SE     |
|   (гостевая VM внутри   |
|        Debian)          |
+-------------------------+
            |
            | debootstrap → rootfs.tar → docker import
            v
+-------------------------+
|   Docker-образ Astra    |
+-------------------------+
```

После того как debian гостевая работает, настроены общие папки преступим к основной части работы.
### 1. Создание и запуск Astra linux с общей папкой 
1. Установим все необходимые пакеты: 
``` bash
	sudo apt update
	sudo apt install -y qemu-kvm libvirt-daemon-system virt-manager virtinst
```
2. Для создания виртуальной машины я написал скрипт:
``` bash
	#!/usr/bin/env bash
	set -euo pipefail
	
	VM_NAME="astra-no-kvm"
	RAM_MB=2048
	CPU=2
	DISK_PATH="/var/lib/libvirt/images/${VM_NAME}.qcow2"
	DISK_SIZE="20"
	ISO_PATH="/mnt/share/astra.iso"
	SHARE_PATH="/srv/vmshare"
	SHARE_TAG="hostshare"
	OS_VARIANT="generic"
	
	sudo mkdir -p /var/lib/libvirt/images
	sudo mkdir -p "$SHARE_PATH"
	sudo chmod 777 "$SHARE_PATH"
	
	sudo qemu-img create -f qcow2 "$DISK_PATH" "${DISK_SIZE}G"
	
	sudo virt-install \
	  --connect qemu:///system \
	  --name "$VM_NAME" \
	  --memory "$RAM_MB" \
	  --vcpus "$CPU" \
	  --disk path="$DISK_PATH",format=qcow2,bus=virtio \
	  --cdrom "$ISO_PATH" \
	  --network network=default,model=virtio \
	  --graphics vnc \
	  --os-variant "$OS_VARIANT" \
	  --virt-type qemu \
	  --boot cdrom,hd \
	  --filesystem "${SHARE_PATH},${SHARE_TAG},driver.type=virtiofs" \
	  --memorybacking source.type=memfd,access.mode=shared

```
Таким образом мы поднимаем виртуальную машину Astra linux 1.7.8
<img width="1280" height="354" alt="image" src="https://github.com/user-attachments/assets/3ad0dbda-59a2-441f-86c7-6baa459703b6" />

### 2. Работа в Astra linux
1. Настройка общих папок:
``` bash
	sudo mkdir -p /mnt/hostshare 
	sudo mount -t virtiofs hostshare /mnt/hostshare
```
2. Установим необходимые утилиты: внутри Astra
``` bash
	sudo apt update 
	sudo apt install -y debootstrap
```
3. Создадим папку для работы и используем debootstap с репозиториями Astra linux
``` bash
	sudo mkdir /srv/rootfs
	sudo debootstrap \
	  --arch=amd64 \
	  --variant=minbase \
	  --components=main,contrib,non-free \
	  1.7_x86-64 \
	  /srv/rootfs \
	  https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/

```
<img width="1280" height="88" alt="image" src="https://github.com/user-attachments/assets/8c3088df-e853-4819-a5a4-48f7f92c0a77" />

На данный момент создана в `/srv/rootfs` корневая файловая система Astra и также скачены минимальные пакеты из репозитория. 
==Примечание==: я использовал stable версию репозиториев поэтому образ получился с версией Astra linux 1.7.9. 
### 3. Создание и проверка образа
1. Смонтируем виртуальную файловую систему:
 ``` bash
	sudo mount --bind /dev /srv/rootfs/dev
	sudo mount --bind /dev/pts /srv/rootfs/dev/pts 
	sudo mount -t proc proc /srv/rootfs/proc 
	sudo mount -t sysfs sys /srv/rootfs/sys
 ```
2. Войдем в chroot и скачаем необходимые пакеты
``` bash
	sudo chroot /srv/rootfs /bin/bash
	apt update apt install -y nano locales ncurses-term
	apt clean
```
<img width="1086" height="59" alt="image" src="https://github.com/user-attachments/assets/d8976616-fa3e-453b-912d-3d59431f8d14" />

3. Теперь создадим tar файл, но перед этим размонтируем виртуальные файловые системы 
``` bash
	sudo umount -l /srv/rootfs/dev/pts 
	sudo umount -l /srv/rootfs/dev 
	sudo umount -l /srv/rootfs/proc 
	sudo umount -l /srv/rootfs/sys
	sudo tar -C /srv/rootfs -c . -f /mnt/hostshare/rootfs.tar
```
4. Создадим образ из tar файла и запустим контейнер
``` bash
	docker import ./rootfs.tar astra:latest
	docker run --rm -it astra:latest /bin/bash
```
<img width="949" height="151" alt="image" src="https://github.com/user-attachments/assets/7e91f967-c7c1-4797-8e41-a2629b25fb7a" />


## Сложности и их решения.
Сложности начались с самого начала)
1. К сожалению windows очень жадный и не захотел никакими моими мольбами(командами) передавать управление гипервизором VirtualBoxб по этой причине пришлось запускать без kvm.
2. Чтобы установить соединение с Astra по ssh нужно было настроить ssh вход по паролю. Также возникла необходимость изменить `/etc/pam.d/sshd`, закомментировать:
```
	pam_parsec_cap.so 
	pam_parsec_aud.so
```
