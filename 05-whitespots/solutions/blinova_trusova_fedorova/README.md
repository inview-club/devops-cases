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
### Установка Auditor
1. Для начала выполнения задания нужно склонировать вот этот репозиторий `https://gitlab.inview.team/whitespots-public-fork/auditor.git`
2. Выполняем `docker compose up -d`
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



