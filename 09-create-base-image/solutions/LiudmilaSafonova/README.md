# Case solution
For this case I made a new Ubuntu VM with access to the Internet.

## Base
### **1. Set up infrastructure for creating and running virtual machines**
Firstly, I installed packages for working with VMs on linux (where Linux acts as a hypervisor):

```
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst bridge-utils
```
I also ensured that the user could run commands without constant use of sudo command
<img width="1968" height="246" alt="image" src="https://github.com/user-attachments/assets/69c7280c-d720-4f51-a44f-61ed7491cddd" />

At first, unfortunately, my VM was not supporting nested virtualization, which is critical for KVM. I modified the VM configuration parameters to enable virtualization support.
<img width="2626" height="416" alt="image" src="https://github.com/user-attachments/assets/0fe83151-3175-43dc-9962-9dee76b930bd" />

I added parameters to VMs config and ended up having VM suppurting virtualization
<img width="1763" height="313" alt="Снимок экрана 2026-03-24 225808" src="https://github.com/user-attachments/assets/b88992fe-0712-4132-b420-79e74ad78b0c" />
<img width="1483" height="164" alt="Снимок экрана 2026-03-24 230025" src="https://github.com/user-attachments/assets/d0496884-9c08-48c9-af54-44ab81261e3f" />
<img width="1741" height="214" alt="Снимок экрана 2026-03-24 231918" src="https://github.com/user-attachments/assets/f2fcf8b5-cf3d-4fa9-982c-296d77e7209d" />
<img width="1230" height="112" alt="image" src="https://github.com/user-attachments/assets/6e8de77b-5874-4f0e-ac32-87e3f36257f2" />
module kvm was successfilly installed 
<img width="1848" height="272" alt="image" src="https://github.com/user-attachments/assets/25caa81c-35d6-4ac7-863b-6537edc0c509" />

The kvm module was successfully installed and verified. I also downloaded the Astra Linux SE 1.7.6 ISO.
### **2. Create a virtual machine and install necessary packages**
Installing the VM using `virt-install` command:
```
sudo virt-install \
  --name astra_vm \
  --ram 2048 \
  --vcpus 2 \
  --os-variant debian10 \
  --network network=default \
  --graphics vnc,listen=0.0.0.0 \
  --cdrom ~/Downloads/installation-1.7.6.11-26.08.24_17.26.iso \
  --disk path=/home/ludk/astra_disk.qcow2,size=12,format=qcow2,sparse=true \
  --check all=off \
  --filesystem /home/ludk/astra_share,astra_common,type=mount,accessmode=passthrough

```

Then set OS and via ssh got into astra from Ubuntu VM
<img width="2448" height="904" alt="image" src="https://github.com/user-attachments/assets/fb5edefb-0dde-4f0d-a805-af399bd8d2ef" />
installed `docker.io` and `debootstrap`

###  **3. Create a Docker image in .tar format using debootstrap**
I configured an isolated `chroot` environment with basic packages (`ncurses-term`, `nano`, `locales`)
<img width="2750" height="262" alt="image" src="https://github.com/user-attachments/assets/577ca8d6-8778-4349-9a3f-6b88cf9c80fc" />

made `.tar`  with flag `-p` to preserve original permissions for all directories
```
sudo tar -cpzf ~/astra-base.tar.gz .
```
using `scp` copied `.tar` file to original Ubuntu VM
<img width="2696" height="222" alt="image" src="https://github.com/user-attachments/assets/b619c334-f178-4e58-a4d2-10c185f71a56" />
and than 
<img width="2484" height="1528" alt="image" src="https://github.com/user-attachments/assets/cd8437cd-c342-4aeb-892c-60caf8bcae0b" />
`debootstrap` worked well
<img width="1874" height="352" alt="image" src="https://github.com/user-attachments/assets/f045b676-b208-4b11-9614-ab1e1072c12f" />

### Conclusion
I was happy to know that this custom-made image weights significantly less, than the original OS. While working on this case, I had to rebuild several times my Ubuntu VM Hard Disk, reinstall Astra Linux from .iso, because 8 GB wasn't enough at first. And after all manipulations docker container is only 224 MB!!
<img width="1510" height="182" alt="image" src="https://github.com/user-attachments/assets/e4282d39-c78e-45bb-84ec-022df9cf60a7" />
