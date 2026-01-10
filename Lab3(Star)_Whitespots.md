# Лабораторная 3 (Звездочка)

## Раюботу выполнили: 
1) Дегтярь Глеб Сергеевич
2) Кулиш Ксения Владимировна
3) Уланова Елизавета Эдуардовна
4) Матюков Дмитрий Владимирович

## Auditor
1. Клонируем репозиторий: ```https://gitlab.inview.team/whitespots-public-fork/auditor.git```
2. Запускаем контейнеры: 
```
cd auditor
docker compose up -d
```
3. Теперь сохраняем токен и перезапускаем контейнер: 
```
docker compose down
docker compose up -d
```

## AppSec Portal
1. Клонируем репозиторий: ```https://gitlab.inview.team/whitespots-public-fork/appsec-portal.git```
   
2. Выполняем все команды, как в инструкции воркшопа:
```
./set_vars.sh
echo IMAGE_VERSION=release_v25.11.3 >> .env
sh run.sh
docker compose exec back python3 manage.py createsuperuser --username admin
```
3. Далее переходим на ```127.0.0.1:80```, вводим ключ и заходим на портал
<div align="center">
  <img width="1455" height="911" alt="1" src="https://github.com/user-attachments/assets/c4f5d576-9e5c-49b1-bdd7-20edb6fa030e" />
</div>

4. В  Auditor - Config указываем адрес аудитора: ```http://host.docker.internal:8080/```

5. Изменяем Internal Portal URL на ```http://host.docker.internal/```
   
6. И генерируем наш приватный ключ (эту команду я подсмотрел): ```ssh-keygen -t rsa -b 4096```

## Добавление репозиториев и сканирование
1. На вкладке Assets - Repositories доббавляем новый репозиторий: ```git@gitlab.com:whitespots-public/vulnerable-apps/vulnerable-python-app.git``` (репа также взята из воркшопа)
<div align="center">
  <img width="1055" height="1109" alt="image" src="https://github.com/user-attachments/assets/61e111b3-0c1b-4628-b339-bf472b8cb154" />
</div>
2. запускаем сканирование и после переходим на вкладку результатов для анализа критических уязвимостей
<div align="center">
  <img width="1363" height="1141" alt="6" src="https://github.com/user-attachments/assets/c2ac2a4c-22b8-4ea8-8073-b21aecde7f40" />
</div>

## Интеграция с IDE
1. Сначала устанавливаем расширение для VsCode (будем делать в вскоде потому что так исторически сложилось, что в этом семестре я работаю чисто в нем)
2. Залезаем в настройки расширения и указываем URL портала и API токен
3. Открываем клонированный репозиторий у себя и наслаждаемся результатом: 
<div align="center">
  <img width="1492" height="620" alt="image" src="https://github.com/user-attachments/assets/4eadcf4e-cc10-4f9a-9423-e2fabe1cc8f9" />
</div>

## Вывод
Я решил не вкладывать в отчет все ошибки и проблемы, которые возникали во время выполнения ЛР т.к отчет бы получился чересчур огромным. Лабораторная работа изначально кажется простой, но на деле даже на этапе установке Auditor и AppSec Portal возникали трудности, однако у нас все же получилось все установить, разобраться с ключом и настройкой приложения, прогнать через него тестовый репозиторий и интегрировать прогу в IDE! Whitespots классная утилита и все ребята в команде сказали, что будут пользоваться ей в дальнейшем т.к она действительно очень удобна в выявлении проблем с кодом, особенно в интеграции с IDE.
