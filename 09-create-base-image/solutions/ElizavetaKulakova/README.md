# Лабораторная работа №1 (Вариант 1, кейс №9). Базовый уровень

## Подготовка к установке и настройке ВМ
Для установки виртуальной машины были скачаны следующие библиотеки:
```
sudo apt update && sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst bridge-utils virt-viewer
```
Проверим, что все установилось корректно:
```
virsh list --all
 Id   Name   State
--------------------

```

Добавим пользователя в необходимые для предстоящей работы группы
```
sudo usermod -aG libvirt,kvm,libvirt-qemu
```
После перезагрузки устройства проверим, все ли добавления получились
```
liza@liza-ai-pc:~$ groups
liza adm cdrom sudo dip plugdev lpadmin lxd libvirt kvm libvirt-qemu
```

## Установка и настройка ВМ
Перенесем образ в системную папку:
```
liza@liza-ai-pc:~$ tar -xvf ~/Downloads/Astra-Linux-1.8.5.46-SE-orel-noGUI.ova
Astra-Linux-1.8.5.46-SE-orel-noGUI.ovf
Astra-Linux-1.8.5.46-SE-orel-noGUI-disk001.vmdk
Astra-Linux-1.8.5.46-SE-orel-noGUI.mf
liza@liza-ai-pc:~$ sudo qemu-img convert -O qcow2 Astra-Linux-1.8.5.46-SE-orel-noGUI-disk001.vmdk /var/lib/libvirt/images/astra.qcow2
[sudo] password for liza: 
liza@liza-ai-pc:~$ sudo chown libvirt-qemu:libvirt /var/lib/libvirt/images/astra.qcow2
```

И теперь можно переходить к установке виртуальной машины:

- Проверка активности виртуальной сети, чтобы у ВМ сразу был интернет:
  ```
  liza@liza-ai-pc:~$ sudo virsh net-list --all
  Name      State    Autostart   Persistent
  --------------------------------------------
  default   active   yes         yes
  ```
- Создание директории для обмена файлами между хостом и ВМ (Shared Folder):
  ```
  sudo mkdir -p /var/lib/libvirt/images/share
  sudo chmod 777 /var/lib/libvirt/images/share
  ```
- Создание виртуальной машины с образом Astra Linux
  ```
  virt-install \
  --name astra-vm \
  --ram 2048 \
  --vcpus 2 \
  --os-variant debian11 \
  --disk path=/var/lib/libvirt/images/astra.qcow2,bus=virtio \
  --network network=default,model=virtio \
  --graphics vnc \
  --import \
  --noautoconsole \
  --memorybacking source.type=memfd,access.mode=shared \
  --filesystem source=/var/lib/libvirt/images/share,target=hostshare,type=mount,driver.type=virtiofs
  ```

- С помощью команды `virt-view astra-vm` заходим в виртульную машину и логинимся:
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/dbd5a034-577d-4f3f-8a1e-fdf023b3ccfd" />

- Устанавливаем и активируем SSH:
  ```
  sudo apt update && sudo apt install openssh-server
  sudo systemctl enable --now ssh
  ```

- Проверяем IP-адрес и активированность SSH:
  <img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/db01d4e3-7af8-484d-860c-c5392d5a2144" />

- И подключаемся к ВМ по SSH
  ```
  liza@liza-ai-pc:~$ ssh user@192.168.122.197
  The authenticity of host '192.168.122.197 (192.168.122.197)' can't be established.
  ED25519 key fingerprint is SHA256:oDyJK8FqO8hN9euLGxsP4vBh0OA2Wnna+xesIDaG0qo.
  This key is not known by any other names.
  Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
  Warning: Permanently added '192.168.122.197' (ED25519) to the list of known hosts.
  user@192.168.122.197's password: 
  Last login: Sun Mar 29 18:43:47 2026
  ```

- Устанавливаем нужные пакеты
  ```
  sudo apt update && sudo apt install -y docker.io debootstrap
  user@astra:~$ sudo docker run hello-world
  Unable to find image 'hello-world:latest' locally
  latest: Pulling from library/hello-world
  4f55086f7dd0: Pull complete 
  Digest: sha256:452a468a4bf985040037cb6d5392410206e47db9bf5b7278d281f94d1c2d0931
  Status: Downloaded newer image for hello-world:latest
  
  Hello from Docker!
  This message shows that your installation appears to be working correctly.
  
  To generate this message, Docker took the following steps:
   1. The Docker client contacted the Docker daemon.
   2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
      (amd64)
   3. The Docker daemon created a new container from that image which runs the
      executable that produces the output you are currently reading.
   4. The Docker daemon streamed that output to the Docker client, which sent it
      to your terminal.
  
  To try something more ambitious, you can run an Ubuntu container with:
   $ docker run -it ubuntu bash
  
  Share images, automate workflows, and more with a free Docker ID:
   https://hub.docker.com/
  
  For more examples and ideas, visit:
   https://docs.docker.com/get-started/
  ```

## Создание Docker-образа в .tar формате через debootstrap
- Создадим корневой каталог в нашей ВМ:
  ```
  mkdir ~/astra-rootfs
  ```
- Разворачиваем минимально рабочую файловую систему Astra Linux внутри папки ~/astra-rootfs
  ```
  sudo debootstrap --no-check-gpg --variant=minbase --include=vim,locales orel ~/astra-rootfs https://download.astralinux.ru/astra/stable/2.12_x86-64/repository
  sudo chroot ~/astra-rootfs /bin/bash

  export LC_ALL=C
  apt update 
  apt install -y ncurses-term
  dpkg-reconfigure locales 

  exit
  ```
- Упаковываем систему в архив
  ```
  sudo tar -C ~/astra-rootfs -c . -f ~/astra-base.tar
  ```
- Перекидываем образ на хост (мой компьютер)
  ```
  liza@liza-ai-pc:~/work/itmo/devops/devops-cases$ scp user@192.168.122.197:~/astra-base.tar .
  user@192.168.122.197's password: 
  astra-base.tar                                100%  258MB 863.7MB/s   00:00
  ```
- Создаем из архива образ, разворачиваем образ и наслаждаемся!
  ```
  liza@liza-ai-pc:~/work/itmo/devops/devops-cases$ sudo docker import astra-base.tar astra-linux:base
  sha256:450ba603cc61818205ab73eafd244effadc8f3b2b495c65ff5e6bed840740002
  liza@liza-ai-pc:~/work/itmo/devops/devops-cases$ sudo docker images
  REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
  astra-linux   base      450ba603cc61   24 seconds ago   263MB
  liza@liza-ai-pc:~/work/itmo/devops/devops-cases$ sudo docker run -it astra-linux:base cat /etc/astra_version
  CE 2.12.46 (orel)
  liza@liza-ai-pc:~/work/itmo/devops/devops-cases/09-create-base-image/solution$ sudo docker run -it astra-linux:base /bin/bash
  root@caa97378671e:/# ls -al
  total 72
  drwxr-xr-x   1 root root 4096 Mar 29 21:19 .
  drwxr-xr-x   1 root root 4096 Mar 29 21:19 ..
  -rwxr-xr-x   1 root root    0 Mar 29 21:19 .dockerenv
  drwxr-xr-x   2 root root 4096 Mar 29 16:24 bin
  drwxr-xr-x   2 root root 4096 Apr  7  2023 boot
  drwxr-xr-x   5 root root  360 Mar 29 21:19 dev
  drwxr-xr-x   1 root root 4096 Mar 29 21:19 etc
  drwxr-xr-x   2 root root 4096 Apr  7  2023 home
  drwxr-xr-x   8 root root 4096 Mar 29 16:24 lib
  drwxr-xr-x   2 root root 4096 Mar 29 16:24 lib64
  drwxr-xr-x   2 root root 4096 Mar 29 16:24 media
  drwxr-xr-x   2 root root 4096 Apr  7  2023 mnt
  drwxr-xr-x   2 root root 4096 Mar 29 16:24 opt
  dr-xr-xr-x 691 root root    0 Mar 29 21:19 proc
  drwxr-x---   2 root root 4096 Mar 29 16:24 root
  drwxr-xr-x   4 root root 4096 Mar 29 16:24 run
  drwxr-xr-x   2 root root 4096 Mar 29 16:24 sbin
  drwxr-xr-x   2 root root 4096 Mar 29 16:24 srv
  dr-xr-xr-x  13 root root    0 Mar 29 21:19 sys
  drwxrwxrwt   2 root root 4096 Mar 29 16:24 tmp
  drwxr-xr-x  10 root root 4096 Mar 29 16:24 usr
  drwxr-xr-x  11 root root 4096 Mar 29 16:24 var
  root@caa97378671e:/# vim --version
  VIM - Vi IMproved 9.0 (2022 Jun 28, compiled Oct 15 2020 16:00:06)
  Included patches: 1-1000, 1087, 1117-1118, 1129, 1165
  Modified by team+vim@tracker.debian.org
  Compiled by team+vim@tracker.debian.org
  Huge version without GUI.  Features included (+) or not (-):
  +acl               +file_in_path      +mouse_urxvt       -tag_any_white
  +arabic            +find_in_path      +mouse_xterm       -tcl
  +autocmd           +float             +multi_byte        +termguicolors
  +autochdir         +folding           +multi_lang        +terminal
  -autoservername    -footer            -mzscheme          +terminfo
  -balloon_eval      +fork()            +netbeans_intg     +termresponse
  +balloon_eval_term +gettext           +num64             +textobjects
  -browse            -hangul_input      +packages          +textprop
  ++builtin_terms    +iconv             +path_extra        +timers
  +byte_offset       +insert_expand     -perl              +title
  +channel           +ipv6              +persistent_undo   -toolbar
  +cindent           +job               +popupwin          +user_commands
  -clientserver      +jumplist          +postscript        +vartabs
  -clipboard         +keymap            +printer           +vertsplit
  +cmdline_compl     +lambda            +profile           +vim9script
  +cmdline_hist      +langmap           -python            +viminfo
  +cmdline_info      +libcall           -python3           +virtualedit
  +comments          +linebreak         +quickfix          +visual
  +conceal           +lispindent        +reltime           +visualextra
  +cryptv            +listcmds          +rightleft         +vreplace
  +cscope            +localmap          -ruby              +wildignore
  +cursorbind        -lua               +scrollbind        +wildmenu
  +cursorshape       +menu              +signs             +windows
  +dialog_con        +mksession         +smartindent       +writebackup
  +diff              +modify_fname      +sodium            -X11
  +digraphs          +mouse             -sound             -xfontset
  -dnd               -mouseshape        +spell             -xim
  -ebcdic            +mouse_dec         +startuptime       -xpm
  +emacs_tags        +mouse_gpm         +statusline        -xsmp
  +eval              -mouse_jsbterm     -sun_workshop      -xterm_clipboard
  +ex_extra          +mouse_netterm     +syntax            -xterm_save
  +extra_search      +mouse_sgr         +tag_binary        
  -farsi             -mouse_sysmouse    -tag_old_static    
     system vimrc file: "/etc/vim/vimrc"
       user vimrc file: "$HOME/.vimrc"
   2nd user vimrc file: "~/.vim/vimrc"
        user exrc file: "$HOME/.exrc"
         defaults file: "$VIMRUNTIME/defaults.vim"
    fall-back for $VIM: "/usr/share/vim"
  Compilation: gcc -c -I. -Iproto -DHAVE_CONFIG_H -Wdate-time -g -O2 -fdebug-prefix-map=/opt/build/vim-9.0.1000=. -fstack-protector-strong -Wformat -Werror=format-security -DSYS_VIMRC_FILE=\"/etc/vim/vimrc\" -DSYS_GVIMRC_FILE=\"/etc/vim/gvimrc\" -D_REENTRANT -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1 
  Linking: gcc -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -o vim -lm -ltinfo -lsodium -lrt -lacl -lattr -lgpm -ldl 
  ```

## Проблемы
- Проблема с Live-образом: Изначально использованный образ alse-1.7.8.6-6.1.livecd.iso предназначен для запуска системы без установки. В его загрузочном меню отсутствовали пункты Install / Graphical Install, а запуск astra-install из терминала внутри Live-сессии не сработал из-за отсутствия необходимых скриптов установки в данной сборке.
- Ошибка «No bootable device»: Возникала при попытке повторного запуска ВМ после сброса, так как приоритет загрузки смещался на пустой виртуальный диск. Решено добавлением флага --boot cdrom,hd в команду virt-install.
- Отсутствие virtiofsd: При попытке настроить shared folder через virtiofs возникла ошибка отсутствия системного демона. Требуется предварительная установка пакета virtiofsd (или qemu-system-common) на хосте.
- В Astra все автоматически писалось капслоком.

# Выводы
В хостовой ОС присутствует Docker-образ на основе Astra Linux. Образ можно запустить, в нем есть командная оболочка.
При создании Docker-образа надо быть внимательным и терпиливым, и все получится почти сразу :) Продвинутый уровень мне не поддался, к сожалению, из-за SSH Timeout, буду биться уже вне рамок факультатива с ним.
