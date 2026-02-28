# Case #7 - n8n & Ollama

<div align="center">

  ![Result diagram dark](img/07-n8n-ollama-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/07-n8n-ollama-light.png#gh-light-mode-only)

</div>

- [Case #7 - n8n \& Ollama](#case-7---n8n--ollama)
  - [Goal](#goal)
  - [Stack](#stack)
  - [Checkpoints](#checkpoints)
    - [Basic](#basic)
    - [Advanced](#advanced)
  - [Result](#result)
  - [Contacts](#contacts)

## Goal

Give the ML engineering team the opportunity not to depend on external web services, as well as to modify, install and work with their local models.

## Stack

![n8n](https://img.shields.io/badge/n8n-EA4B71.svg?style=for-the-badge&logo=n8n&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000.svg?style=for-the-badge&logo=ollama&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-FF4438.svg?style=for-the-badge&logo=redis&logoColor=white)

## Checkpoints

### Basic

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

### Advanced

<div align="center">

  ![Result diagram dark](img/07-n8n-aiops-dark.png#gh-dark-mode-only)

</div>

<div align="center">

  ![Result diagram light](img/07-n8n-aiops-light.png#gh-light-mode-only)

</div>

1. Install [Prometheus](https://prometheus.io/docs/prometheus/latest/installation/), [Alertmanager](https://github.com/prometheus/alertmanager), [Node Exporter](https://prometheus.io/docs/guides/node-exporter/)
2. Configure some basic alerting rules:
   - For inspiration, you can use sources like:
     - [Alert and route testing for Alertmanager](https://prometheus.io/webtools/alerting/routing-tree-editor/).
     - A huge [list](https://samber.github.io/awesome-prometheus-alerts/rules) of alerts covering many domains.
     - [The same](https://github.com/monitoring-mixins/website/tree/master/assets) as the previous, but with more examples.
4. Configure Alertmanager to send alerts to the n8n Webhook.
5. Create a new workflow:
   - Add Webhook node that accepts the payload from Alertmanager.
   - Add a step that parses the alert payload and extracts the key parameters.
   - Add an LLM node that generates a human‑readable incident description and a brief summary for a chat message.
   - Add a step that creates a Incidents in GitLab with the required fields and context.

## Result

A local chatbot agent is set up inside n8n, connected to the LLM through Ollama, with the conversation stored in Redis or the PostgreSQL database.

![Result](img/07-result.png)

## Contacts

Need help? Message us in [our Telegram chat](https://t.me/+nSELCyIX8ltlNjU6)!
