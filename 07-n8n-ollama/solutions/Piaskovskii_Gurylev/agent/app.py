import hashlib
import json
import os
import warnings
from contextlib import asynccontextmanager
from datetime import datetime
from pathlib import Path

import redis
from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel
from psycopg_pool import ConnectionPool

from langchain.agents import create_agent
from langchain_core.caches import BaseCache
from langchain_core.globals import set_llm_cache
from langchain_core.load import dumps, loads
from langchain_core.tools import tool
from langchain_ollama import ChatOllama
from langgraph.checkpoint.postgres import PostgresSaver


warnings.filterwarnings("ignore", message=".*`loads` is in beta.*")

# --- Конфигурация через переменные окружения ---
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen3:8b")
DB_URI = os.getenv("DB_URI", "postgresql://agent:agent_pass@localhost:5432/agent")
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")

SYSTEM_PROMPT = (
    "Ты полезный ассистент команды ML-инженеров. "
    "Отвечай кратко и по делу. Если нужен инструмент, используй его."
)


# --- Инструменты агента ---
@tool
def current_time() -> str:
    """Возвращает текущие дату и время на сервере."""
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


TOOLS = [current_time]


# --- Кеш ответов LLM в Redis ---
class RedisLLMCache(BaseCache):
    """Хранит ответы модели в Redis"""

    def __init__(self, url: str, ttl_seconds: int = 24 * 3600):
        self.client = redis.Redis.from_url(url)
        self.ttl = ttl_seconds

    @staticmethod
    def _key(prompt: str, llm_string: str) -> str:
        digest = hashlib.sha256(f"{llm_string}|{prompt}".encode()).hexdigest()
        return f"llm_cache:{digest}"

    def lookup(self, prompt, llm_string):
        raw = self.client.get(self._key(prompt, llm_string))
        if raw is None:
            return None
        # Каждый ответ сохранён как сериализованный объект LangChain
        return [loads(item, allowed_objects="core") for item in json.loads(raw)]

    def update(self, prompt, llm_string, return_val):
        payload = json.dumps([dumps(gen) for gen in return_val])
        self.client.set(self._key(prompt, llm_string), payload, ex=self.ttl)

    def clear(self, **kwargs):
        for key in self.client.scan_iter("llm_cache:*"):
            self.client.delete(key)



@asynccontextmanager
async def lifespan(app: FastAPI):
    # Кеш ответов LLM в Redis
    set_llm_cache(RedisLLMCache(REDIS_URL))

    # Пул соединений к Postgres
    pool = ConnectionPool(
        conninfo=DB_URI,
        max_size=10,
        kwargs={"autocommit": True, "prepare_threshold": 0},
    )
    checkpointer = PostgresSaver(pool)
    checkpointer.setup()  

    model = ChatOllama(model=OLLAMA_MODEL, base_url=OLLAMA_URL, temperature=0.2)

    app.state.agent = create_agent(
        model=model,
        tools=TOOLS,
        system_prompt=SYSTEM_PROMPT,
        checkpointer=checkpointer,
    )
    yield
    pool.close()


app = FastAPI(title="Local LLM Agent", lifespan=lifespan)


class ChatRequest(BaseModel):
    session_id: str  
    message: str


class ChatResponse(BaseModel):
    session_id: str
    answer: str


class HistoryMessage(BaseModel):
    role: str  # "user" или "assistant"
    content: str


STATIC_DIR = Path(__file__).parent / "static"


@app.get("/", include_in_schema=False)
def index():
    return FileResponse(STATIC_DIR / "index.html")


@app.get("/health")
def health():
    return {"status": "ok", "model": OLLAMA_MODEL}


@app.get("/history/{session_id}", response_model=list[HistoryMessage])
def history(session_id: str):
    config = {"configurable": {"thread_id": session_id}}
    state = app.state.agent.get_state(config)
    result = []
    for msg in state.values.get("messages", []):
        if msg.type == "human":
            result.append(HistoryMessage(role="user", content=msg.content))
        elif msg.type == "ai" and msg.content and not msg.tool_calls:
            result.append(HistoryMessage(role="assistant", content=msg.content))
    return result


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    config = {"configurable": {"thread_id": req.session_id}}
    result = app.state.agent.invoke(
        {"messages": [{"role": "user", "content": req.message}]},
        config=config,
    )
    return ChatResponse(session_id=req.session_id, answer=result["messages"][-1].content)
