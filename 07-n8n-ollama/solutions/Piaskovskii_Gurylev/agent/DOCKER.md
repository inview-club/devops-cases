# Запуск в Docker Compose

Одна команда поднимает всё: приложение, Postgres, Redis и Ollama. Python, базы и Ollama на хосте ставить не нужно.

## Что нужно

- Docker Desktop (Windows: с WSL2-бэкендом) или Docker Engine + Compose v2 на Linux
- GPU: свежий драйвер NVIDIA. На Windows Docker Desktop сам пробрасывает видеокарту через WSL2
- ~10 ГБ на диске: образы + модель `qwen3:8b` (~5 ГБ)
- Остановить локальный `uvicorn`, если запущен: он занимает порт 8000

Локальные Postgres, Redis и Ollama выключать не нужно: порты контейнеров наружу не публикуются, конфликта нет.

## Запуск

Из папки проекта (PowerShell / терминал):

```bash
# с GPU NVIDIA
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build

# без GPU (CPU, медленно)
docker compose up -d --build
```

Первый запуск долгий: собирается образ и качается модель. Прогресс закачки:

```bash
docker compose logs -f ollama-pull
```

Закачка закончилась, когда `ollama-pull` в `docker compose ps -a` имеет статус `Exited (0)`. До этого `/chat` отвечает ошибкой: модели ещё нет.

Чат: http://127.0.0.1:8000, API: http://127.0.0.1:8000/docs

## Проверка

Чек-лист повторяет раздел «Проверка работы» из `REPORT.md`.

| # | Что проверяем | Как |
|---|---|---|
| 1 | Все сервисы живы | `docker compose ps`: у `app`, `postgres`, `redis`, `ollama` статус `healthy` |
| 2 | Приложение подключилось к Postgres | http://127.0.0.1:8000/health отвечает `{"status":"ok","model":"qwen3:8b"}` (порт слушается только после подключения к БД) |
| 3 | Модель на GPU | `docker compose exec ollama ollama ps`: колонка PROCESSOR `100% GPU` |
| 4 | Агент помнит контекст | в чате: «Меня зовут Иван», затем «Как меня зовут?» |
| 5 | Вызов инструмента | в чате: «Который час?» |
| 6 | Кеш в Redis | `docker compose exec redis redis-cli keys 'llm_cache:*'` |
| 7 | История переживает перезапуск | `docker compose down`, затем `docker compose up -d`, обновить страницу: переписка на месте |

### Быстрая проверка без модели и GPU

Проверяет сборку образа и связку с базами, Ollama не нужен:

```bash
docker compose up -d --build app
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:8000/history/test
docker compose exec app python -c "import os,redis; print(redis.Redis.from_url(os.environ['REDIS_URL']).ping())"
```

Ожидается: `{"status":"ok",...}`, затем `[]`, затем `True`. (На Windows в PowerShell вместо `curl` используй `curl.exe` или браузер.)

## Варианты запуска

| Где крутится LLM | Команда |
|---|---|
| CPU в контейнере (работает везде, медленно) | `docker compose up -d --build` |
| NVIDIA GPU | `docker compose -f docker-compose.yml -f docker-compose.gpu.yml up -d --build` |
| Ollama нативно на хосте (macOS: Docker не видит Metal, так в разы быстрее) | `ollama pull qwen3:8b`, затем `OLLAMA_URL=http://host.docker.internal:11434 docker compose up -d --build app` |

## Параметры

Задаются переменными окружения или файлом `.env` рядом с `docker-compose.yml` (если создаёшь `.env`, добавь его в `.gitignore`).

| Переменная | По умолчанию |
|---|---|
| `OLLAMA_MODEL` | `qwen3:8b` |
| `OLLAMA_URL` | `http://ollama:11434` |
| `POSTGRES_PASSWORD` | `agent_pass` |

## Как это собрано

Принцип: один сервис на каждую зависимость из `README.md`, адреса передаются через те же переменные окружения, которые уже читает `app.py`. Код приложения не менялся.

- **`Dockerfile`**: образ `python:3.13-slim`, зависимости отдельным слоем (пересборка после правки `app.py` не качает пакеты заново), запуск `uvicorn --host 0.0.0.0`. Без `0.0.0.0` порт внутри контейнера снаружи не виден.
- **Адреса баз** это имена сервисов: `postgres:5432`, `redis:6379`, `ollama:11434`. `localhost` из контейнера смотрит на сам контейнер.
- **`depends_on` + проверка работоспособности (healthcheck)**: `app` стартует только когда Postgres и Redis здоровы. У Postgres проверка идёт с `-h 127.0.0.1`: при первой инициализации временный сервер слушает только unix-сокет, и проверка без `-h` докладывает «готов» раньше времени.
- **`app` не зависит от `ollama`**: клиент подключается к модели лениво, при первом запросе. Поэтому можно запустить `app` с внешним Ollama (вариант для macOS).
- **Тома (volumes)**: `pgdata` (история чатов), `redisdata`, `ollama` (модель, чтобы не качать 5 ГБ при каждом пересоздании).
- **`ollama-pull`**: одноразовый контейнер, который после старта Ollama делает `ollama pull`. Статус `Exited (0)` у него нормальный.
- **GPU** вынесен в отдельный `docker-compose.gpu.yml`, который накладывается поверх основного. Так тот же compose работает и на машинах без NVIDIA.
- **Порт 8000** привязан к `127.0.0.1`: у чата нет авторизации.

## Если что-то не так

| Симптом | Причина и решение |
|---|---|
| `/chat` отвечает 500, в логах «model not found» | Модель ещё качается: `docker compose logs -f ollama-pull` |
| `ollama ps` показывает CPU, а не GPU | Запущено без `docker-compose.gpu.yml`, либо Docker Desktop не видит видеокарту. Проверка: `docker run --rm --gpus all ubuntu nvidia-smi` |
| `port is already allocated` на 8000 | Остановить локальный `uvicorn` |
| `password authentication failed` после смены `POSTGRES_PASSWORD` | Пароль применяется только при первом создании тома: `docker compose down -v` (сотрёт историю) и поднять заново |
| Нужно всё сбросить | `docker compose down -v` |

## Управление

```bash
docker compose logs -f app      # логи приложения
docker compose down             # остановить, данные сохраняются
docker compose down -v          # остановить и стереть историю, кеш и модель
```
