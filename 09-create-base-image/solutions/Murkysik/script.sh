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
