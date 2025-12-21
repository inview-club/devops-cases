# Кейс №7  
## n8n и Ollama

## 1. Цель работы
Дать команде ML-инженеров возможность не зависеть от внешних веб-сервисов, а также модифицировать и устанавливать свои локальные модели и работать с ними

## 2. Стек технологий

 
- n8n  
- Ollama  
- PostgreSQL  
- Redis  

## 3. Выполнения работы

### 3.1 Подготовка Docker Compose

Для развёртывания сервисов был написан файл `docker-compose.yml`, включающий сервисы PostgreSQL, Redis, Ollama и n8n.


### 3.2 Запуск контейнеров

Запуск системы осуществлялся командой:

```bash
docker compose up -d
```
<img width="869" height="185" alt="Снимок экрана 2025-12-21 в 9 30 11 AM" src="https://github.com/user-attachments/assets/3346af46-f4a1-4165-81ea-37953c4d9dff" />

### 3.3 В контейнер Ollama была загружена модель llama3.2:
<img width="647" height="99" alt="Снимок экрана 2025-12-21 в 9 40 04 AM" src="https://github.com/user-attachments/assets/9ac26711-a467-4e8b-82fa-06b70b2a74c0" />
<img width="584" height="44" alt="Снимок экрана 2025-12-21 в 9 40 21 AM" src="https://github.com/user-attachments/assets/7c6c4f6d-72c0-4207-bd39-ff6692f6438c" />


### 3.4 Настройка данных Ollama и n8n
В интерфейсе n8n были добавлены credentials для Ollama со следующими параметрами:
	•	Base URL: http://ollama:11434

Соединение было успешно протестировано.
<img width="482" height="266" alt="Снимок экрана 2025-12-21 в 9 35 00 AM" src="https://github.com/user-attachments/assets/3cc74ae8-cb74-4941-afec-1d06ab68ca24" />

<img width="497" height="577" alt="Снимок экрана 2025-12-21 в 9 35 21 AM" src="https://github.com/user-attachments/assets/4f03267b-df51-466f-869c-022fe31a230e" />

### 3.5 Настройка
Был настроен workflow включающий в себя AI Agent, Ollama Chat Model, Redis
<img width="608" height="479" alt="Снимок экрана 2025-12-21 в 9 36 49 AM" src="https://github.com/user-attachments/assets/1bb3406e-0f6e-4db5-bed8-cd819d633e17" />

### 3.6 Проверка системы
Мы сообщили информацию о себе, а в последующем сообщении агент корректно использовал ранее сохраненный контекст
<img width="649" height="288" alt="Снимок экрана 2025-12-21 в 9 38 18 AM" src="https://github.com/user-attachments/assets/68ead111-9e63-46d1-9876-e37794aae943" />

## Результат
В результате выполнения лабораторной работы был успешно развёрнут локальный чат-агент:
	•	система полностью автономна и не использует внешние API
	•	LLM запускается локально через Ollama
	•	контекст диалога сохраняется в Redis
	•	workflow и конфигурация хранятся в PostgreSQL
	•	взаимодействие осуществляется через интерфейс n8n

 Полученное решение позволяет ML-инженерам работать с локальными LLM-моделями, гибко настраивать поведение агента и не зависеть от внешних облачных сервисов.
