# Case-7
## the case was done by
- Журавлева Анна
- Мошкина Галина
- Левчук Софья
- Суханова Мария
#
Before the beginning of the task we had to download docker desktop to easily monitor our containers and wsl to work with docker on Windows.
After everything had been installed we were ready to start

## docker-compose file
We had to create a docker-compose file to connect all required programmes (ollama, redis, postgres, n8n)
```
services:
  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data 
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:8.4-alpine 
    restart: always
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 10s
      timeout: 5s
      retries: 5
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - EXECUTIONS_MODE=queue
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379

      - N8N_HOST=${N8N_HOST:-localhost}
      - N8N_PROTOCOL=http
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5678/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
    
volumes:
  postgres_data:
  redis_data:
  n8n_data:
  ollama_data:
```

We added healthchecks in each container to ensure that everything works correctly. n8n won't start before postgres and redis aren't ready to work. Volumes were added for each container to save all the information about all sessions.
Each container restarts right after it was stopped if a computer restarts

After this we build our containers with 
```
docker-compose up -d
```
<img width="1480" height="726" alt="2025-12-23_12-30-03" src="https://github.com/user-attachments/assets/2991afb4-b744-4af8-9832-f0aab3f6c6ce" />


We can open docker desktop to check if everything runs correctly

<img width="1573" height="826" alt="2025-12-23_14-32-58" src="https://github.com/user-attachments/assets/7ecb84fb-9f1c-402e-b951-9db8a28289f7" />

and it actually is)

Then we had to choose LLM and download it. llama3.2 was chosen due to its light weight and efficiency.
```
docker-compose exec ollama ollama pull llama3.2:1b
```
<img width="1473" height="299" alt="2025-12-23_12-32-26" src="https://github.com/user-attachments/assets/c8b371ec-cb04-4aba-bcd8-ed09ac35bc3f" />

## getting started with n8n 

We can acces n8n via http://localhost:5678

<img width="1835" height="986" alt="2025-12-23_10-46-42" src="https://github.com/user-attachments/assets/a4376ece-469d-49ae-8988-433c39c33d0b" />

After registration and before creating the workflow we had to add credentials to ollama, redis, postgres to work with them

<img width="1311" height="756" alt="2025-12-23_13-04-02" src="https://github.com/user-attachments/assets/7bf253e0-7b0a-496b-bcf7-c7d3ff91fe71" />
(api can be any value)

<img width="1308" height="749" alt="2025-12-23_13-45-09" src="https://github.com/user-attachments/assets/f17482ca-1009-44f8-b076-0f3689bfaa34" />
<img width="1311" height="756" alt="2025-12-23_13-48-50" src="https://github.com/user-attachments/assets/9856e4c7-3608-4371-ab8b-77a09afe6a8c" />

We just used all the information mentioned in the docker-compose file

Now we are ready to create our first workflow

First we had to add a trigger (in our case it was a recieved message). Then we added a second node, an ai-agent, which is the main part in this workflow.

<img width="525" height="655" alt="2025-12-23_17-12-06" src="https://github.com/user-attachments/assets/a603b20c-ffa2-487f-8ae0-ee4332f6524a" />

In settings we added this. Conversational agent seemed the most suitable type for this task.

We also added a chat-model using our ollama account and memory (redis) so our model can remember the context of the previous 5 messages.

<img width="535" height="783" alt="2025-12-23_13-43-21" src="https://github.com/user-attachments/assets/b37fc72d-9d22-4f4e-bd36-9435a8b3dc33" />
<img width="534" height="802" alt="2025-12-23_13-46-21" src="https://github.com/user-attachments/assets/640513b6-9ae6-4a03-ba40-a6a294929644" />

Out of curiosity let's check if it really works

<img width="473" height="231" alt="2025-12-23_14-32-34" src="https://github.com/user-attachments/assets/d7ec2d00-9945-405a-aea7-10818460313e" />

Nice)

The next step was to connect postgres to store information on a long-term basis

We had to create a table first

<img width="1301" height="859" alt="2025-12-23_16-50-51" src="https://github.com/user-attachments/assets/7781f401-fbf1-461b-b23b-ed96239798d5" />

Then we choose our created table and manually map values for each column (we choose a name of the field from the model we want to store in the particualr column and put it there:))
In the end it looks like this
<img width="1842" height="901" alt="2025-12-23_17-02-14" src="https://github.com/user-attachments/assets/5291de4b-62d4-412d-a5b2-103ca6f5494e" />
We can also see that the message from the agent was successfully processed and stored in our table

<img width="1840" height="934" alt="2025-12-23_17-08-49" src="https://github.com/user-attachments/assets/10a98e62-27ae-4b47-bb09-2c287eaeee1b" />

That's how our workflow looks like. Everything works, we are happy

![funny-animal-dancing-cat](https://github.com/user-attachments/assets/07ede9e0-6a8a-4e1b-95d7-f6eee20122b1)

