# Case №7 - n8n & Ollama

<div align="center">

  ![Result diagram dark](img/07-n8n-ollama-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/07-n8n-ollama-light.png#gh-light-mode-only)

</div>

- [Case №7 - n8n \& Ollama](#case-7---n8n--ollama)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

Deploy a fully local infrastructure (Postgres + Redis + n8n + Ollama), connect an LLM to n8n, and create a workflow that enables chatting with an agent while preserving conversation context (memory) in the database.

## Stack

![n8n](https://img.shields.io/badge/n8n-EA4B71.svg?style=for-the-badge&logo=n8n&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000.svg?style=for-the-badge&logo=ollama&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-FF4438.svg?style=for-the-badge&logo=redis&logoColor=white)

## Checkpoints

1. Install [Postgres](https://www.postgresql.org/docs):
   - Used for storing n8n workflows and credentials.
2. Install [Redis](https://redis.io/docs/):
   - Used by n8n for task queues, retries, and scaling.
3. Install [n8n](https://docs.n8n.io):
   - Connect it to the installed Postgres and Redis.
   - You can use Docker Compose for the setup.
4. Install [Ollama](https://ollama.ai/docs):
   - If you’re using Docker Compose, add an Ollama container to your manifest.
   - Download a suitable LLM model from the [library](https://ollama.com/library).
5. Configure credentials in n8n:
   - Add Ollama under n8n Credentials.
   - Use the OpenAI Chat Model node, specify the Ollama endpoint, and select the downloaded model.
6. Create a new workflow:
   - Flow: Chat Message → AI Agent → Chat Model (Ollama).
   - Store chat sessions in external storage (Redis or database) so the agent can retain context between requests.

## Result

A local chatbot agent is set up inside n8n, connected to the LLM through Ollama, with the conversation stored in Redis or the PostgreSQL database.

![Result](img/07-result.png)

## Contacts

Need help? Message us in [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)!
