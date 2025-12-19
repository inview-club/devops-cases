## Part 1
### docker-compose
In the beginning we write a docker-compose file, so that all 4 services see and work with each other

```
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}

  redis:
    image: redis:7.2-alpine

  ollama:
    image: ollama/ollama:0.5.2
    ports:
      - "11434:11434" 
    volumes:
      - ollama_data:/root/.ollama

  n8n:
    image: n8nio/n8n:1.43.1
    ports:
      - "5678:5678"
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_DATABASE: ${POSTGRES_DB}
      DB_POSTGRESDB_USER: ${POSTGRES_USER}
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}

      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      
      EXECUTIONS_MODE: queue
      QUEUE_BULL_REDIS_HOST: redis
      QUEUE_BULL_REDIS_PORT: 6379
    depends_on:
      - postgres
      - redis
      - ollama

volumes:
  ollama_data:
```
In summary
- there are 4 services: postgresql, redis, n8n, ollama
- n8n waits for everything else to build
- volume for llm
  
Nothing really special about that docker-compose (much of the same details were already written in another work about docker-compose) so moving on

Then we build containers 

```
docker-compose up -d
```
<img width="958" height="124" alt="Снимок экрана 2025-12-10 142924" src="https://github.com/user-attachments/assets/7e3458a5-5a46-45e7-83ba-4a10a3a668df" />

## Part 2
### llm
Now, it’s time to download LLM, llama3.2:1b was chosen for its stability and size 
```
docker-compose exec ollama ollama pull llama3.2:1b
```
<img width="1282" height="199" alt="Снимок экрана 2025-12-10 145414" src="https://github.com/user-attachments/assets/e71fdb8d-ba60-4497-9017-732c2889313c" />

After eternity we reached success 
## Part 3
### n8n
Moving on to the most interesting part - creating and connecting nodes. To do that we come to [http://localhost:5678](http://localhost:5678) and register 

Then we choose nodes from the right side of the page, choose settings for them and finally connect them

<img width="475" height="833" alt="Снимок экрана 2025-12-11 200850" src="https://github.com/user-attachments/assets/03393ca3-0664-4cdf-a627-505c41f72cbe" />

The first node is “Chat trigger” which is meant to trigger the workflow through the message which I send. It didn't need much settings (at all), so we just put it

Then we put AI Agent. At first we attempted to work with basic LLM chain but it was not convenient because to connect it to redis we had to also use 2 or even three Function Codes (and of course write the code itself), so AI Agent was the perfect choice as it is meant to complete tasks using given tools and services.
The special system message was put to get the correct output format

<img width="448" height="851" alt="Снимок экрана 2025-12-11 201403" src="https://github.com/user-attachments/assets/247a702c-bcf7-4001-8e16-13bf3db47ba4" />

For LLM we found Ollama chat bot 

<img width="1111" height="506" alt="Снимок экрана 2025-12-10 174750" src="https://github.com/user-attachments/assets/1425a484-b43d-46fe-887f-118b73eba4f3" />

OpenAI wasn’t used because it required API Key (which we don’t have)

And final node - Redis Chat Memory 

<img width="458" height="355" alt="Снимок экрана 2025-12-11 201722" src="https://github.com/user-attachments/assets/3d96c908-d7e2-4b5d-8cfb-75620dbf2e54" />

Done!

Let’s see how it works

<img width="926" height="572" alt="Снимок экрана 2025-12-11 122905" src="https://github.com/user-attachments/assets/98be32e9-ccca-4343-a9ef-0f5490b4798f" />

<img width="716" height="190" alt="Снимок экрана 2025-12-11 122858" src="https://github.com/user-attachments/assets/d1a63e31-0d2e-490f-ab79-27476ee1f854" />

As for redis 

<img width="667" height="785" alt="Снимок экрана 2025-12-11 124853" src="https://github.com/user-attachments/assets/334e52c7-2c92-4abc-a361-71e4ae6275da" />

Our dialog was saved 

Now we got our local ai-agent-chatbot 🤖
