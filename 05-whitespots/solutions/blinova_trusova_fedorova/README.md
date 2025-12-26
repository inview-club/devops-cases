# Лабораторная работа №3 (Версия со звездочкой)

Выполнили:
- Блинова Полина Вячеславовна, ису: 465232, К3239
- Федорова Мария Витальевна, ису: 410542, К3239
- Трусова Светлана Викторовна, ису: 467766, К3240

## Цель
Для улучшения безопасности проектов и ускоренного обнаружения уязвимостей необходимо настроить платформу, включающую в себя различные инструменты статического анализа и провести её интеграцию с существующими системами.

## Стэк
![WhiteSpots Badge](https://img.shields.io/badge/Whitespots-b048d9.png?style=for-the-badge)
![Gitlab](https://img.shields.io/badge/Gitlab-FC6D26.svg?style=for-the-badge&logo=gitlab&logoColor=white)
![IDE](https://img.shields.io/badge/IDE-8a8a8a.svg?style=for-the-badge)

## Выполнение работы
## Пункт 1
### Установка Auditor
1. Для начала выполнения задания нужно склонировать вот этот репозиторий `https://gitlab.inview.team/whitespots-public-fork/auditor.git`
2. Выполняем
   ```
   docker compose up -d
   ```
   <img width="1236" height="547" alt="Screenshot 2025-12-25 at 12 54 39" src="https://github.com/user-attachments/assets/87f37dfb-1a0a-42a2-a6a0-7c7c07cc1832" />
4. Переходим по адресу `127.0.0.1:8080` и генерим новый Access Token (его не покажу). Затем видим это
   <img width="1326" height="869" alt="Screenshot 2025-12-25 at 17 15 11" src="https://github.com/user-attachments/assets/238e41e7-6775-4072-80cf-d1a2ce68e5c1" />
6. Добавляем этот токен в переменную `ACCESS_TOKEN` в .env файл в директории `auditor` (тут тоже не покажу)
7. Перезапускаем контейнеры
    ```
    docker compose down
    docker compose up -d
    ```
    <img width="1255" height="532" alt="Screenshot 2025-12-25 at 17 10 25" src="https://github.com/user-attachments/assets/a2a890ff-cb33-4289-b228-e4e02898798f" />

### Установка AppSec Portal
1. Клонируем новый репозиторий `https://gitlab.inview.team/whitespots-public-fork/appsec-portal.git`
2. Выполняем
   ```
   ./set_vars.sh
   ```
   <img width="857" height="369" alt="Screenshot 2025-12-25 at 17 20 04" src="https://github.com/user-attachments/assets/fecda9ef-fb9c-4a8b-90b1-2140c69f290b" />
4. Добавляем версию
   ```
   echo IMAGE_VERSION=release_v25.11.3 >> .env
   ```
   (скрин выше)
6. Запускаем портал
   ```
   sh run.sh
   ```
   <img width="1247" height="615" alt="Screenshot 2025-12-25 at 17 20 45" src="https://github.com/user-attachments/assets/52580e30-f510-494e-9d6f-05b23ce63135" />
8. Создаем пароль суперпользователя
    ```
   docker compose exec back python3 manage.py createsuperuser --username admin
   ```
    <img width="1243" height="274" alt="Screenshot 2025-12-25 at 17 28 39" src="https://github.com/user-attachments/assets/076c4bbb-e12e-403b-b5ff-fdced754cae8" />
   (тут сначала ввела слишком короткий пароль)
10. Переходим по адресу `127.0.0.1:80` и вводим лицензионный ключ
    <img width="1318" height="864" alt="Screenshot 2025-12-25 at 17 29 40" src="https://github.com/user-attachments/assets/4085c342-b295-4d1b-8410-5838cbddb61a" />
12. Переходим в раздел Auditor - Config. Нужно указать адрес аудитора `http://host.docker.internal:8080/` и наш Access Token.
    <img width="1321" height="867" alt="image" src="https://github.com/user-attachments/assets/fe50c707-50f8-4734-8ad0-6a8e89245521" />
14. Меняем Internal Portal URL на `http://host.docker.internal/`, кликнув на Workflow Settings.
    
## Пункт 2
1. Добавляем приватный ключ (БЕЗ ПАРОЛЯ, иначе в findings ничего не будет видно, это было выявлено при многократных попытках сделать лабу...).
    <img width="1126" height="687" alt="Screenshot 2025-12-25 at 17 51 42" src="https://github.com/user-attachments/assets/9d482e9b-2f6c-4402-8a28-f648e28630be" />
    <img width="1512" height="912" alt="Screenshot 2025-12-25 at 17 49 07" src="https://github.com/user-attachments/assets/65d9305d-3bf3-41c1-a1ec-7386e0f9239e" />
(вот это покажу, а ключи нет)


    





