# Установка виртуальной машины
Для установки виртуальной машины был скачаны следующие библиотеки:
```
sudo apt update && sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst bridge-utils virt-viewer
```

Проверим, что все установилось корректно:
```
virsh list --all
 Id   Name   State
--------------------

```
