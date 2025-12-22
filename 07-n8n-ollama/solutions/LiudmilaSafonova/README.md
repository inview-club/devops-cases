# Case №7 - n8n & Ollama

## Описание кейса
### Цель

Дать команде ML-инженеров возможность не зависеть от внешних веб-сервисов, а также модифицировать и устанавливать свои локальные модели и работать с ними.

### Стэк

![n8n](https://img.shields.io/badge/n8n-EA4B71.svg?style=for-the-badge&logo=n8n&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000.svg?style=for-the-badge&logo=ollama&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-FF4438.svg?style=for-the-badge&logo=redis&logoColor=white)

### Результат

Настроен локальный чат-бот-агент, развернутый в n8n, который обращается к LLM через Ollama и сохраняет диалог в базе/Redis.

## Решение

Сначала прописываем docker-compose, в котором создаются контейнеры с Postgres, Redis, Ollama и самим n8n
```
version: '3.8'

services:
  postgres:
    image: postgres:16
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5


  redis:
    image: redis:alpine
    restart: always
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  ollama:
    image: ollama/ollama:0.13.4-rocm
    restart: always
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama

  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    ports:
      - "5678:5678"
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: ${POSTGRES_DB}
      DB_POSTGRESDB_USER: ${POSTGRES_USER}
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      N8N_SECURE_COOKIE: "false" # без этого выдавало ошибку о небезопасности подключения и не давало работать с платформой
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      ollama:
        condition: service_started
    volumes:
      - ./n8n_data:/home/node/.n8n

volumes:
  postgres_data:
    driver: local
  n8n_data:
  ollama_data:
```
секреты через переменные среды в файле .env 

Далее собираем всё командой 

```
docker-compose up -d
```
<img width="3204" height="254" alt="image" src="https://github.com/user-attachments/assets/ec19acac-c944-43cc-8acc-819a0b87579d" />

в другом окне открыла терминал и провериа, работают ли контейнеры

<img width="3134" height="220" alt="image" src="https://github.com/user-attachments/assets/5a8bda0f-7aa0-47fd-84f0-c311844ffa36" />

## n8n
Загрузили модель внутрь контейнера Ollama. После попадаем в терминал контейнера, но сразу после установки выходим

<img width="3082" height="458" alt="image" src="https://github.com/user-attachments/assets/a55ca66c-b690-4a41-841c-478ca65ea67a" />

По адресу `http://localhost:5678` попадаем сначала на страницу регистрации и после уже в среду разработки

<img width="1406" height="810" alt="image" src="https://github.com/user-attachments/assets/612be0d2-8c0c-445b-b66b-0bb201145418" />

Далее перешла в раздел Credentials -> Add Credential. Нашла в поисковике Ollama
 
<img width="2284" height="1256" alt="image" src="https://github.com/user-attachments/assets/e141270c-b87d-4324-a75b-ed3596865114" />

И Postgres. Указала те же параметры, что и в файле .env

<img width="1982" height="1048" alt="image" src="https://github.com/user-attachments/assets/e5d29394-266e-4887-afae-5930487989dd" />

<img width="2432" height="552" alt="image" src="https://github.com/user-attachments/assets/536aabb9-c153-4260-9829-90ce9b19a32c" />

## n8n - чат

Далее создала новый workflow. Первым узлом стал Chat Trigger, вторым - AI Agent, к кторому подключила модель чата и базу

<img width="1770" height="854" alt="image" src="https://github.com/user-attachments/assets/f853ea9f-7396-4ce9-a137-7c01d349241e" />

Диалог, который состоялся. К сожалению, у ollama не получилось в морскую терминологию :(, но главное контекст диалога сохранился: имя запомнил и в принципе по узлу ответил

<img width="1068" height="1178" alt="image" src="https://github.com/user-attachments/assets/462d49fb-2818-4a15-948f-799bbcf0923c" />

Файл из n8n

<img width="1160" height="1462" alt="image" src="https://github.com/user-attachments/assets/c4109cfb-19b3-4edb-9830-df8552454b7b" />


Попробовала через терминал посмотреть внутрь контейнера с базой
```
$ docker exec -it liudmilasafonova-postgres-1 psql -U admin -d n8n

psql (16.11 (Debian 16.11-1.pgdg13+1))
Type "help" for help.

n8n=# SELECT * FROM n8n_chat_histories;
```

<img width="3802" height="886" alt="image" src="https://github.com/user-attachments/assets/a82b02e6-d7a3-40a5-83c2-4ca4d685789a" />

## Вывод 
В итоге получился локальный llm-agent chat, в котором может сохраняться контекст диалога. Ура ура
