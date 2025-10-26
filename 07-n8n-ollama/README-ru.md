# Кейс №7 - n8n & Ollama

<div align="center">

  ![Result diagram dark](img/07-n8n-ollama-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/07-n8n-ollama-light.png#gh-light-mode-only)

</div>

- [Кейс №7 - n8n \& Ollama](#кейс-7---n8n--ollama)
  - [Цель](#цель)
  - [Стэк](#стэк)
  - [Чекпоинты](#чекпоинты)
  - [Результат](#результат)
  - [Контакты](#контакты)

## Цель

Дать команде ML-инженеров возможность не зависеть от внешних веб-сервисов, а также модифицировать и устанавливать свои локальные модели и работать с ними.

## Стэк

![n8n](https://img.shields.io/badge/n8n-EA4B71.svg?style=for-the-badge&logo=n8n&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000.svg?style=for-the-badge&logo=ollama&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-FF4438.svg?style=for-the-badge&logo=redis&logoColor=white)

## Чекпоинты

1. Установить [Postgres](https://www.postgresql.org/docs):
   - Используется для хранения воркфлоу и кредов n8n.
2. Установить [Redis](https://redis.io/docs/):
   - Используется n8n для очередей задач, ретраев и масштабирования.
3. Установить [n8n](https://docs.n8n.io):
   - Подключите к n8n установленные Postgres и Redis.
   - Для решения задачи может подойти Docker Compose.
4. Установить [Ollama](https://ollama.ai/docs):
   - Если вы начали решать задачу с помощью Docker Compose, добавьте контейнер с ollama в ваш манифест.
   - Скачайте любую подходящую LLM из [библиотеки](https://ollama.com/library).
5. Нaстроить креды в n8n:
   - Добавить Ollama в Credential n8n.
   - Использовать узел OpenAI Chat Model, указав endpoint Ollama и выбрать скачанную ранее модель.
6. Создать новый воркфлоу:
   - Вокрфлоу: Chat Message → AI Agent → Chat Model (Ollama).
   - Сессии чата сохранять во внешнем хранилище (Redis/БД), чтобы агент «помнил» контекст и между запросами.

## Результат

Настроен локальный чат-бот-агент, развернутый в n8n, который обращается к LLM через Ollama и сохраняет диалог в базе/Redis.

![Result](img/07-result.png)

## Контакты

Нужна помощь? Пиши в [наш Telegram чат](https://t.me/+nSELCyIX8ltlNjU6)!
