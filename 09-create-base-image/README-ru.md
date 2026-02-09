# Case №9 - Создание Docker-образа на основе виртуальной машины Astra Linux

- [Case №9 - Создание Docker-образа на основе виртуальной машины Astra Linux](#case-9---создание-docker-образа-на-основе-виртуальной-машины-astra-linux-18)
  - [Цель](#цель)
  - [Стэк](#стэк)
  - [Контрольные точки](#контрольные-точки)
  - [Результат](#результат)
  - [Контакты](#контакты)

## Цель

Docker-образы удобно использовать для сборки или деплоя приложения - но как они появляются на свет, если дистрибутива нет в Docker Hub и прочих источниках? Рассмотрим этапы создания образа на основе файловой системы, стандартных утилит Debian-like систем и архивирования.

## Стэк

![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=fff)
![bash](https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=fff)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff)
![Packer](https://img.shields.io/badge/packer-%23E7EEF0.svg?logo=packer&logoColor=fff)
![Vagrant](https://img.shields.io/badge/vagrant-%231563FF.svg?logo=vagrant&logoColor=fff)

## Контрольные точки (стандарт)

1. **Настройте инфраструктуру создания и запуска виртуальных машин:**
   - Нам потребуются пакеты `virt-install`, `qemu-kvm`, `libvirt-daemon-system` и их аналоги, если используются другие дистрибутивы.
   - Образ Astra Linux в формате .iso (только 1.7) или .ova (1.8, нужно будет конвертировать его в образ диска .qcow2) - например, с портала [Easy Astra](https://easyastra.ru/resources/astralinux.php)
   - Альтернатива - `HashiCorp Packer`, позволяющий описать создание образа виртуальной машины с помощью HashiCorp Configuration Language Language (используется также в Terraform), а также `HashiCorp Vagrant`, позволяющий описать настройку виртуальной машины с помощью Vagrantfile на HCL.
2. **Создайте виртуальную машину и установите в нее необходимые пакеты:**
   - Для работы с ВМ через `qemu` используется `virt-install`, подключиться к ней можно по ssh (получение IP-адреса - `virsh`). Необходимые параметры для `virt-install` можно посмотреть в любом доступном источнике, нас интересует стандартный Debian-like дистрибутив, устройства периферии необязательны, но желательно настроить shared folders через `virtiofs`. В `Vagrant` можно смаппить `sharedfolder`. Через пакетный менеджер поставим `docker.io` (или по инструкции с официального сайта) и `debootstrap`.
3. **Создайте Docker-образ в .tar формате через debootstrap:**
   - Используя `debootstrap`, внутри виртуальной машины настройте изолированное окружение `chroot` с базовыми для работы пакетами (например `ncurses-term`, `nano`, `locales`).
   - Создайте образ файловой системы с помощью `tar`.
   - Отправьте `tar` в хостовую операционную систему и смонтируйте его через `docker import`.

## Контрольные точки (продвинутый)

1. После установки необходимых пакетов используем `HashiCorp Packer`, который позволяет описать создание образа виртуальной машины с помощью HashiCorp Configuration Language Language (используется также в Terraform).
2. Вместо `virt-install` используем `HashiCorp Vagrant`, который позволяет описать настройку виртуальной машины с помощью Vagrantfile на HCL. В `Vagrant` можно смаппить `sharedfolder`, если нужно использовать внешнюю память.
3. Все то же самое, что и в стандартной версии.

## Результат

В хостовой ОС присутствует Docker-образ на основе Astra Linux. Образ можно запустить, в нем есть командная оболочка.

## Контакты

Нужна помощь? Пиши в [наш Telegram чат](https://t.me/+nSELCyIX8ltlNjU6)!
