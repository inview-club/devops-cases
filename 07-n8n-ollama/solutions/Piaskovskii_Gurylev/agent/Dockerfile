FROM python:3.13-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Зависимости отдельным слоем: пересборка при правке app.py не тянет pip заново
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py .
COPY static ./static

RUN useradd --create-home --uid 1000 appuser
USER appuser

EXPOSE 8000

# --host 0.0.0.0 обязателен: на 127.0.0.1 внутри контейнера порт снаружи не виден
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
