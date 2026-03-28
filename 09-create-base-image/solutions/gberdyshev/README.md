# Решение кейса № 9 (ЛР-1 advanced трек)

Выполнил: Григорий Бердышев

## Артефакты решения:

- [astra.pkr.hcl](./astra.pkr.hcl) - Packer шаблон
- [Vagrantfile](./Vagrantfile)

## Сборка Box (Packer)

С сайта EasyAstra был скачен образ Astra Linux 1.8.5.46 в формате `.ova`. Т.к. этот формат используется в VirtualBox, а я использую `qemu-libvirtd`, то необходимо было выполнить его распаковку и конвертацию `.vmdk` образа в `.qcow2`:

```bash
qemu-img convert -f vmdk -O qcow2 Astra-Linux-1.8.5.46-SE-orel-noGUI-disk001.vmdk output.qcow2
```

Далее была выполнена загрузка в гостевую ОС и добавление пользователя `vagrant`, а также настройка ssh (чтобы Packer смог выполнить подключение к ВМ).

Затем был написан шаблон для Packer - [astra.pkr.hcl](./astra.pkr.hcl), в котором указан плагин qemu - для запуска ВМ и плагин Vagrant - для пост-процессинга и сборки box файла.

После выполнения `packer build astra.pkr.hcl` имеем box-файл `astra.box`.

## Создание и запуск ВМ (Vagrant)

Добавляем полученный выше box-файл в vagrant: `vagrant box add --name astra18 astra.box`

```
grigory@thinkpad:~$ vagrant box list
astra18 (libvirt, 0, (amd64))
```

Теперь мы можем использовать его для создания наших ВМ.

Устанавливаем плагин для работы с libvirtd (+ запускаем сам демон libvirtd): `vagrant plugin install vagrant-libvirt`.



Инициализируем окружение - `vagrant init`. В [Vagrantfile](./Vagrantfile) добавляем сведения о нашем боксе, параметры libvirtd (опционально), сведения об общей директории (для передачи файлов из гостевой машины в хост-машину).

В секции provision добавлены команды для установки необходимых пакетов (`debootstrap`, `docker.io`), а также команда для сборки chroot-окружения, его архивирования и переноса в общую директорию. Запуск этой секции осуществляется командой `vagrant provision`.

## Создание Docker образа

После упаковки архива он был распакован на хост-машине и окружение было проверено на работоспособность.

Далее был собран Docker образ с помощью команды:

```bash
sudo docker import chroot.tar gberdyshev/astralinux:1.8  --change "ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"  --change 'CMD ["/bin/bash"]'  --change "ENV LANG=ru_RU.UTF-8"
```

*Здесь дополнительно указаны переменные окружения `PATH` и `LANG`*

Готовый образ:

```bash
grigory@thinkpad:~$ docker images --filter "reference=gberdyshev/astralinux"
                                                                                                        
IMAGE                       ID             DISK USAGE   CONTENT SIZE   EXTRA
gberdyshev/astralinux:1.8   1bf37567d151        572MB             0B
```

Войдем в созданный образ:

```
grigory@thinkpad:~$ docker run -it gberdyshev/astralinux:1.8 /bin/bash
root@458710b8f42c:/# ls
bin  boot  dev	etc  home  lib	lib64  media  mnt  opt	parsec	proc  root  run  sbin  srv  sys  tmp  usr  var
root@458710b8f42c:/# apt --version
apt 2.6.1 (amd64)
root@458710b8f42c:/# python3 --version
Python 3.11.2
root@458710b8f42c:/#
```

## Результат

Получен Docker-образ на базе Astra Linux 1.8, в нем есть командная оболочка и базовое окружение. Объем образа получился достаточно большим, думаю, его можно сократить, если исключить лишние пакеты.

Теперь я знаю как использовать Vagrant и Packer, а ещё узнал про preseed и автоматизированную установку =).

Указанный подход сборки образов можно масштабировать на любые ОС, т.к. собрать Box можно вручную, просто установив ОС на ВМ, а затем снять образ диска с помощью Packer.

## Возникшие проблемы

- Сначала я хотел собрать образ Astra вручную, используя preseed (у них свой формат), но быстро одумался)

- Изначально поставил для Vagrant плагин `vagrant-qemu`, а он оказался плагином для MacOS и пытался найти директорию qemu по пути HomeBrew.

## Источники

- [Сборка образа через debootstrap в Astra](https://wiki.astralinux.ru/pages/viewpage.action?pageId=120651784)
- [Использование Vagrant + сборка Box](https://grimoire.carcano.ch/blog/vagrant-installing-and-operating/)