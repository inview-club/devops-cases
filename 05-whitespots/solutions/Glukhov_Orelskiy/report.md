# Лабораторная работа 3*

Выполняли:
- Глухов Влад 
- Орельский Никита

---

## **Установка AppSec**

1. Склонировали репозиторий:

```
git clone https://gitlab.com/whitespots-public/appsec-portal
```

2. Поднимаем контейнеры в докере:

```   
docker compose up -d
```

3. Выполнили миграции:

```
docker exec portal-portal-1 python manage.py migrate
```

4. Создали пользователя

```
docker exec -it portal-portal-1 python manage.py
```

5. Открыли  http://localhost  и авторизовались

![alt text](telegram-cloud-photo-size-2-5359362571544236388-y.jpg)

## **Установка Auditor**

1. Склонировали репозиторий


```
git clone https://gitlab.inview.team/whitespots-public-fork/auditor.git
```

потом сделали такой же запуск, дальше сгенерировали токен и настроили

![alt text](telegram-cloud-photo-size-2-5359362571544236389-y.jpg)

## **Создали Asset**
В Portal перешли в раздел **Assets** и создали новый Asset со следующими параметрами:
- **Name**: DVWA
- **Type**: Repository
- **URL**: `https://github.com/digininja/DVWA.git`

все успешно заработало

![alt text](telegram-cloud-photo-size-2-5359362571544236387-y.jpg)

![alt text](image.png)

## **Интеграция IDE**

![alt text](image-1.png)

# Вывод

Теперь есть возможность добавлять репозитории через веб-интерфейс портала и запускать для них аудиты. Или запускать аудиты для локальных репозиториев с помощью настроенного расширения в IDE.