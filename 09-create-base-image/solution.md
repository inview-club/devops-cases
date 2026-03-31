На момент выполнения кейса VirtualBox на Linux почему-то отказался работать, а времени было в обрез, поэтому было решено использовать в качестве хост-системы Windows и перебросить получившийся образ по SSH.

Загружаем образ Astra Linux для Virtualbox:

![Сайт загрузки](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case1.PNG)

Импортируем виртуалку:

![Импорт](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case2.PNG)

Пробрасываем порт для SSH:

![Проброс порта](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case2b.PNG)

Запускаем виртуалку и убеждаемся, что сработал DHCP (с этим бывают проблемы):

![Запуск](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case3.PNG)

Устанавливаем пакет debootstrap:

![Установка](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case4.PNG)

Создаем директорию с файловой системой контейнера:

![Подготовка файловой системы](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case5.PNG)


![Проверка файловой системы](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case6.PNG)

Запаковываем её в tar-архив:

![Архивация файловой системы](https://raw.githubusercontent.com/warmike01/devops-cases/refs/heads/main/09-create-base-image/img/case7.PNG)
