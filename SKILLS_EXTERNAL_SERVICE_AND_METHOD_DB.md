# Skills как внешний сервис и база методов

**Дата:** 2026-01-28
**Концепции:** 2 революционных подхода
**Фокус:** Архитектура и реализация

---

## 📑 Содержание

1. [Вариант 1: Skills как внешний сервис](#вариант-1-skills-как-внешний-сервис)
2. [Вариант 2: Skills как база методов (Pseudo-RAG)](#вариант-2-skills-как-база-методов-pseudo-rag)
3. [Сравнение вариантов](#сравнение-вариантов)
4. [Гибридный подход](#гибридный-подход)

---

# Вариант 1: Skills как внешний сервис

## Концепция

**Skills работают ВНЕ Claude** - как отдельный микросервис/платформа, к которой Claude подключается через API.

```
┌─────────────────────────────────────────────────┐
│                 Claude / LLM                     │
│         (основной AI интеллект)                 │
└───────────────────┬─────────────────────────────┘
                    │ API calls
                    ↓
┌─────────────────────────────────────────────────┐
│          Skills Service (внешний)               │
│  • Хранение skills                              │
│  • Выполнение skills                            │
│  • Управление versions                          │
│  • Analytics                                    │
└─────────────────────────────────────────────────┘
```

### Преимущества подхода

✅ **Независимость от платформы**
- Работает с любым LLM (Claude, GPT, Gemini, etc.)
- Не привязан к конкретной реализации
- Можно менять LLM без изменения skills

✅ **Централизованное управление**
- Одна база skills для всех
- Единая точка обновления
- Версионирование и rollback

✅ **Масштабируемость**
- Горизонтальное масштабирование
- Load balancing
- Независимое scaling от LLM

✅ **Монетизация**
- API subscriptions
- Pay-per-use модель
- Enterprise licenses

✅ **Безопасность**
- Централизованный security
- Rate limiting
- Access control

---

## Архитектура

### High-Level Architecture

```
┌──────────────────────────────────────────────────────┐
│                  Client Layer                         │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐     │
│  │ Claude Code│  │   Web UI   │  │   Mobile   │     │
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘     │
└─────────┼────────────────┼────────────────┼──────────┘
          │                │                │
          └────────────────┴────────────────┘
                           ↓ HTTPS/WebSocket
┌──────────────────────────────────────────────────────┐
│               API Gateway (Kong/Nginx)                │
│  • Authentication (JWT)                               │
│  • Rate limiting                                      │
│  • Request routing                                    │
│  • Response caching                                   │
└────────────────────────┬─────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────┐
│              Skills Service Cluster                   │
│                                                       │
│  ┌─────────────────┐    ┌──────────────────┐        │
│  │ Skills Registry │    │  Skills Executor │        │
│  │  • Discovery    │    │  • Runtime       │        │
│  │  • Metadata     │    │  • Sandboxing    │        │
│  │  • Versioning   │    │  • Monitoring    │        │
│  └────────┬────────┘    └────────┬─────────┘        │
│           │                      │                    │
│  ┌────────▼───────────────────────▼────────┐        │
│  │      Skills Storage (S3/MinIO)          │        │
│  │  • Skill definitions                     │        │
│  │  • Examples                              │        │
│  │  • Assets                                │        │
│  └──────────────────────────────────────────┘        │
│                                                       │
│  ┌──────────────────┐    ┌─────────────────┐        │
│  │   Cache (Redis)  │    │  Queue (RabbitMQ)│       │
│  │  • Hot skills    │    │  • Async jobs    │       │
│  │  • Results       │    │  • Processing    │       │
│  └──────────────────┘    └─────────────────┘        │
└────────────────────────┬─────────────────────────────┘
                         ↓
┌──────────────────────────────────────────────────────┐
│                  Data Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │
│  │  PostgreSQL  │  │    MongoDB   │  │  ClickHouse│ │
│  │  • Users     │  │  • Skills    │  │  • Analytics│ │
│  │  • Subscr.   │  │  • Metadata  │  │  • Logs    │ │
│  └──────────────┘  └──────────────┘  └────────────┘ │
└──────────────────────────────────────────────────────┘
```

### Детальная архитектура Skills Service

```
Skills Service
├── API Layer
│   ├── REST API (FastAPI/Express)
│   ├── GraphQL API
│   └── WebSocket (real-time)
│
├── Core Services
│   ├── Skills Registry
│   │   ├── Registration
│   │   ├── Discovery
│   │   ├── Versioning
│   │   └── Validation
│   │
│   ├── Skills Executor
│   │   ├── Runtime Engine
│   │   ├── Sandboxing
│   │   ├── Resource Management
│   │   └── Error Handling
│   │
│   ├── Skills Optimizer
│   │   ├── Caching Strategy
│   │   ├── Prefetching
│   │   └── Performance Tuning
│   │
│   └── Skills Analytics
│       ├── Usage Tracking
│       ├── Performance Metrics
│       └── Cost Attribution
│
├── Support Services
│   ├── Authentication Service
│   ├── Authorization Service
│   ├── Billing Service
│   └── Notification Service
│
└── Storage Layer
    ├── Skills Store (S3/MinIO)
    ├── Metadata DB (MongoDB)
    ├── Relational DB (PostgreSQL)
    ├── Cache (Redis)
    └── Analytics DB (ClickHouse)
```

---

## Технические детали

### 1. Skills Format (новый формат)

**Вместо ZIP архивов - структурированный JSON/YAML:**

```yaml
# skill.yaml - Новый формат skill

apiVersion: skills.claude.ai/v1
kind: Skill
metadata:
  id: smart-file-organizer
  name: Smart File Organizer
  version: 2.1.0
  author: john@example.com
  license: MIT
  tags:
    - file-management
    - automation
    - productivity
  created: 2026-01-15T10:00:00Z
  updated: 2026-01-28T15:30:00Z

spec:
  description: |
    Intelligently organize files based on content, type, and metadata.
    Supports custom rules and automatic categorization.

  runtime:
    type: claude-executor  # или python, javascript
    version: "1.0"
    timeout: 30s
    memory: 256MB

  parameters:
    input:
      type: object
      required:
        - files_path
      properties:
        files_path:
          type: string
          description: Path to files to organize
        strategy:
          type: string
          enum: [by-type, by-date, by-content, custom]
          default: by-type
        rules:
          type: array
          items:
            type: object

    output:
      type: object
      properties:
        organized_count:
          type: integer
        categories:
          type: object
        report:
          type: string

  instructions: |
    You are a file organization assistant.

    Task: Organize files from {input.files_path} using {input.strategy} strategy.

    Steps:
    1. Scan the directory
    2. Analyze each file (type, date, content)
    3. Categorize based on strategy
    4. Create folder structure
    5. Move files
    6. Generate report

    Rules:
    - Preserve original timestamps
    - Handle duplicates gracefully
    - Create backups before moving
    - Log all operations

  examples:
    - name: Organize Downloads by type
      input:
        files_path: /Users/john/Downloads
        strategy: by-type
      expected_output:
        organized_count: 45
        categories:
          Documents: 20
          Images: 15
          Videos: 10

    - name: Organize by date
      input:
        files_path: /Users/john/Documents
        strategy: by-date
        rules:
          - year_folders: true
          - month_subfolders: true

  dependencies:
    - skill: file-analyzer
      version: ">=1.0.0"
    - skill: backup-creator
      version: "^2.0.0"

  permissions:
    required:
      - filesystem:read
      - filesystem:write
    optional:
      - cloud:upload  # для backup в cloud

  pricing:
    model: pay-per-execution
    cost: 0.01  # $0.01 per execution

  metrics:
    usage_count: 1543
    success_rate: 0.98
    avg_duration_ms: 2341
    rating: 4.7
```

### 2. API Endpoints

```python
# api.py - Skills Service API

from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer
from pydantic import BaseModel
from typing import Optional, Dict, Any
import asyncio

app = FastAPI(title="Skills Service API", version="1.0.0")
security = HTTPBearer()

# Models
class SkillExecuteRequest(BaseModel):
    skill_id: str
    skill_version: Optional[str] = "latest"
    input: Dict[str, Any]
    parameters: Optional[Dict[str, Any]] = {}
    async_execution: bool = False

class SkillExecuteResponse(BaseModel):
    job_id: str
    status: str  # pending, running, completed, failed
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    duration_ms: Optional[int] = None
    cost: Optional[float] = None

class SkillSearchRequest(BaseModel):
    query: Optional[str] = None
    tags: Optional[list[str]] = None
    category: Optional[str] = None
    min_rating: Optional[float] = None

# Authentication
async def verify_token(credentials = Depends(security)):
    token = credentials.credentials
    user = await auth_service.verify(token)
    if not user:
        raise HTTPException(status_code=401, detail="Invalid token")
    return user

# Endpoints

@app.get("/")
async def root():
    return {
        "service": "Skills Service",
        "version": "1.0.0",
        "status": "operational"
    }

@app.get("/skills")
async def list_skills(
    category: Optional[str] = None,
    tag: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
    user = Depends(verify_token)
):
    """Список доступных skills"""
    skills = await skills_registry.search(
        category=category,
        tag=tag,
        limit=limit,
        offset=offset
    )

    return {
        "skills": skills,
        "total": len(skills),
        "limit": limit,
        "offset": offset
    }

@app.get("/skills/{skill_id}")
async def get_skill(
    skill_id: str,
    version: Optional[str] = "latest",
    user = Depends(verify_token)
):
    """Получить информацию о skill"""
    skill = await skills_registry.get(skill_id, version)

    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found")

    return skill

@app.post("/skills/{skill_id}/execute")
async def execute_skill(
    skill_id: str,
    request: SkillExecuteRequest,
    user = Depends(verify_token)
):
    """Выполнить skill"""

    # Проверка доступа
    if not await access_control.can_execute(user, skill_id):
        raise HTTPException(status_code=403, detail="Access denied")

    # Проверка лимитов
    if not await rate_limiter.check(user):
        raise HTTPException(status_code=429, detail="Rate limit exceeded")

    # Загрузить skill
    skill = await skills_registry.get(skill_id, request.skill_version)

    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found")

    # Валидация input
    validation = skill.validate_input(request.input)
    if not validation.valid:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid input: {validation.errors}"
        )

    # Создать job
    job = await job_manager.create_job(
        user_id=user.id,
        skill_id=skill_id,
        skill_version=skill.version,
        input=request.input,
        parameters=request.parameters
    )

    if request.async_execution:
        # Асинхронное выполнение
        asyncio.create_task(
            executor.execute(job.id, skill, request.input)
        )

        return {
            "job_id": job.id,
            "status": "pending",
            "message": "Job queued for execution"
        }
    else:
        # Синхронное выполнение
        result = await executor.execute(job.id, skill, request.input)

        # Billing
        await billing_service.record_usage(
            user_id=user.id,
            skill_id=skill_id,
            cost=skill.pricing.cost
        )

        return {
            "job_id": job.id,
            "status": "completed",
            "result": result.output,
            "duration_ms": result.duration_ms,
            "cost": skill.pricing.cost
        }

@app.get("/jobs/{job_id}")
async def get_job_status(
    job_id: str,
    user = Depends(verify_token)
):
    """Получить статус job"""
    job = await job_manager.get(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    if job.user_id != user.id:
        raise HTTPException(status_code=403, detail="Access denied")

    return {
        "job_id": job.id,
        "status": job.status,
        "result": job.result if job.status == "completed" else None,
        "error": job.error if job.status == "failed" else None,
        "progress": job.progress,
        "duration_ms": job.duration_ms
    }

@app.post("/skills/search")
async def search_skills(
    request: SkillSearchRequest,
    user = Depends(verify_token)
):
    """Поиск skills"""
    results = await skills_registry.search(
        query=request.query,
        tags=request.tags,
        category=request.category,
        min_rating=request.min_rating
    )

    return {
        "results": results,
        "count": len(results)
    }

@app.post("/skills")
async def register_skill(
    skill_data: dict,
    user = Depends(verify_token)
):
    """Зарегистрировать новый skill"""

    # Валидация
    skill = Skill.parse(skill_data)

    if not skill.valid:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid skill: {skill.errors}"
        )

    # Проверка прав
    if not user.can_create_skills:
        raise HTTPException(status_code=403, detail="Access denied")

    # Регистрация
    registered = await skills_registry.register(
        skill=skill,
        author_id=user.id
    )

    return {
        "skill_id": registered.id,
        "version": registered.version,
        "status": "registered",
        "message": "Skill registered successfully"
    }

@app.delete("/skills/{skill_id}")
async def delete_skill(
    skill_id: str,
    user = Depends(verify_token)
):
    """Удалить skill"""
    skill = await skills_registry.get(skill_id)

    if not skill:
        raise HTTPException(status_code=404, detail="Skill not found")

    if skill.author_id != user.id and not user.is_admin:
        raise HTTPException(status_code=403, detail="Access denied")

    await skills_registry.delete(skill_id)

    return {"message": "Skill deleted successfully"}

# WebSocket для real-time execution
from fastapi import WebSocket

@app.websocket("/ws/execute")
async def websocket_execute(websocket: WebSocket):
    """WebSocket endpoint для streaming execution"""
    await websocket.accept()

    try:
        # Аутентификация
        auth_data = await websocket.receive_json()
        user = await auth_service.verify(auth_data['token'])

        if not user:
            await websocket.send_json({"error": "Authentication failed"})
            await websocket.close()
            return

        # Получить запрос
        request = await websocket.receive_json()

        skill_id = request['skill_id']
        input_data = request['input']

        # Загрузить skill
        skill = await skills_registry.get(skill_id)

        # Execute с streaming
        async for chunk in executor.execute_stream(skill, input_data):
            await websocket.send_json({
                "type": "chunk",
                "data": chunk
            })

        await websocket.send_json({
            "type": "complete",
            "message": "Execution completed"
        })

    except Exception as e:
        await websocket.send_json({
            "type": "error",
            "error": str(e)
        })
    finally:
        await websocket.close()
```

### 3. Skills Executor

```python
# executor.py - Skills execution engine

import asyncio
import docker
import resource
from typing import Any, Dict
import time

class SkillsExecutor:
    """Движок для выполнения skills"""

    def __init__(self):
        self.docker_client = docker.from_env()
        self.claude_client = Claude(api_key=settings.CLAUDE_API_KEY)

    async def execute(
        self,
        job_id: str,
        skill: Skill,
        input_data: Dict[str, Any]
    ) -> ExecutionResult:
        """Выполнить skill"""

        start_time = time.time()

        try:
            # Обновить статус
            await job_manager.update_status(job_id, "running")

            # Выбрать runtime
            if skill.runtime.type == "claude-executor":
                result = await self.execute_claude(skill, input_data)
            elif skill.runtime.type == "python":
                result = await self.execute_python(skill, input_data)
            elif skill.runtime.type == "javascript":
                result = await self.execute_javascript(skill, input_data)
            else:
                raise ValueError(f"Unsupported runtime: {skill.runtime.type}")

            duration_ms = int((time.time() - start_time) * 1000)

            # Сохранить результат
            exec_result = ExecutionResult(
                job_id=job_id,
                status="completed",
                output=result,
                duration_ms=duration_ms
            )

            await job_manager.update(job_id, exec_result)

            return exec_result

        except Exception as e:
            duration_ms = int((time.time() - start_time) * 1000)

            exec_result = ExecutionResult(
                job_id=job_id,
                status="failed",
                error=str(e),
                duration_ms=duration_ms
            )

            await job_manager.update(job_id, exec_result)

            raise

    async def execute_claude(
        self,
        skill: Skill,
        input_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Выполнить skill через Claude API"""

        # Построить промпт
        prompt = self.build_prompt(skill, input_data)

        # Вызвать Claude
        response = await self.claude_client.messages.create(
            model=skill.runtime.model or "claude-sonnet-4",
            max_tokens=skill.runtime.max_tokens or 4096,
            temperature=skill.runtime.temperature or 1.0,
            messages=[
                {"role": "user", "content": prompt}
            ]
        )

        # Парсить результат
        result = self.parse_claude_response(response, skill)

        return result

    def build_prompt(
        self,
        skill: Skill,
        input_data: Dict[str, Any]
    ) -> str:
        """Построить промпт для Claude"""

        # Базовые инструкции
        prompt = skill.instructions

        # Подставить input параметры
        for key, value in input_data.items():
            prompt = prompt.replace(f"{{input.{key}}}", str(value))

        # Добавить примеры
        if skill.examples:
            prompt += "\n\nExamples:\n"
            for example in skill.examples[:3]:  # Первые 3 примера
                prompt += f"\nInput: {example.input}"
                prompt += f"\nExpected Output: {example.expected_output}\n"

        # Добавить output format
        if skill.parameters.output:
            prompt += f"\n\nOutput format: {skill.parameters.output}"

        return prompt

    def parse_claude_response(
        self,
        response: Any,
        skill: Skill
    ) -> Dict[str, Any]:
        """Парсить ответ от Claude"""

        content = response.content[0].text

        # Попытаться извлечь JSON если output - объект
        if skill.parameters.output.get('type') == 'object':
            try:
                import json
                # Найти JSON в ответе
                start = content.find('{')
                end = content.rfind('}') + 1
                if start >= 0 and end > start:
                    json_str = content[start:end]
                    return json.loads(json_str)
            except:
                pass

        # Иначе вернуть как текст
        return {"output": content}

    async def execute_python(
        self,
        skill: Skill,
        input_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Выполнить Python skill в sandboxed environment"""

        # Запустить в Docker контейнере для изоляции
        container = self.docker_client.containers.run(
            image="python:3.11-slim",
            command=[
                "python", "-c",
                skill.code  # Python код skill
            ],
            environment={
                "SKILL_INPUT": json.dumps(input_data)
            },
            mem_limit=skill.runtime.memory,
            cpu_quota=int(skill.runtime.cpu * 100000),  # CPU limit
            network_mode="none",  # Без network доступа
            remove=True,
            detach=False,
            stdout=True,
            stderr=True
        )

        # Получить output
        output = container.decode('utf-8')

        return json.loads(output)

    async def execute_javascript(
        self,
        skill: Skill,
        input_data: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Выполнить JavaScript skill"""

        # Аналогично Python, но с Node.js контейнером
        container = self.docker_client.containers.run(
            image="node:18-slim",
            command=[
                "node", "-e",
                skill.code
            ],
            environment={
                "SKILL_INPUT": json.dumps(input_data)
            },
            mem_limit=skill.runtime.memory,
            remove=True,
            detach=False,
            stdout=True
        )

        output = container.decode('utf-8')

        return json.loads(output)

    async def execute_stream(
        self,
        skill: Skill,
        input_data: Dict[str, Any]
    ):
        """Streaming execution для long-running skills"""

        prompt = self.build_prompt(skill, input_data)

        # Stream от Claude
        async with self.claude_client.messages.stream(
            model="claude-sonnet-4",
            max_tokens=4096,
            messages=[{"role": "user", "content": prompt}]
        ) as stream:
            async for chunk in stream:
                if chunk.type == "content_block_delta":
                    yield chunk.delta.text

# Resource limits
class ResourceManager:
    """Управление ресурсами для execution"""

    @staticmethod
    def set_limits(memory_mb: int, cpu_percent: float):
        """Установить лимиты ресурсов"""

        # Memory limit
        memory_bytes = memory_mb * 1024 * 1024
        resource.setrlimit(
            resource.RLIMIT_AS,
            (memory_bytes, memory_bytes)
        )

        # CPU limit (через cgroups в Docker)
        pass

    @staticmethod
    def monitor_usage():
        """Мониторинг использования ресурсов"""
        import psutil

        return {
            "cpu_percent": psutil.cpu_percent(),
            "memory_mb": psutil.virtual_memory().used / 1024 / 1024,
            "disk_io": psutil.disk_io_counters()
        }
```

### 4. Подключение к Claude Code

```python
# claude_code_integration.py - Интеграция с Claude Code

from typing import Optional
import httpx

class SkillsServiceClient:
    """Client для Skills Service из Claude Code"""

    def __init__(
        self,
        api_url: str,
        api_key: str
    ):
        self.api_url = api_url
        self.api_key = api_key
        self.client = httpx.AsyncClient(
            base_url=api_url,
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json"
            },
            timeout=30.0
        )

    async def list_skills(
        self,
        category: Optional[str] = None,
        tag: Optional[str] = None
    ):
        """Получить список skills"""
        params = {}
        if category:
            params['category'] = category
        if tag:
            params['tag'] = tag

        response = await self.client.get("/skills", params=params)
        response.raise_for_status()

        return response.json()

    async def execute_skill(
        self,
        skill_id: str,
        input_data: dict,
        async_execution: bool = False
    ):
        """Выполнить skill"""
        payload = {
            "skill_id": skill_id,
            "input": input_data,
            "async_execution": async_execution
        }

        response = await self.client.post(
            f"/skills/{skill_id}/execute",
            json=payload
        )
        response.raise_for_status()

        return response.json()

    async def get_job_status(self, job_id: str):
        """Проверить статус job"""
        response = await self.client.get(f"/jobs/{job_id}")
        response.raise_for_status()

        return response.json()

    async def search_skills(self, query: str):
        """Поиск skills"""
        response = await self.client.post(
            "/skills/search",
            json={"query": query}
        )
        response.raise_for_status()

        return response.json()


# Использование в Claude Code
class SkillsTool:
    """Tool для использования Skills Service в Claude Code"""

    def __init__(self, config):
        self.client = SkillsServiceClient(
            api_url=config.get('skills_service_url', 'https://api.skills.com'),
            api_key=config.get('skills_api_key')
        )

    async def use_skill(
        self,
        skill_name: str,
        input_data: dict
    ) -> dict:
        """Использовать skill из Claude Code"""

        # Поиск skill по имени
        search_result = await self.client.search_skills(skill_name)

        if not search_result['results']:
            raise ValueError(f"Skill '{skill_name}' not found")

        skill = search_result['results'][0]

        # Выполнить
        result = await self.client.execute_skill(
            skill_id=skill['id'],
            input_data=input_data
        )

        return result

    async def list_available_skills(self, category: str = None):
        """Показать доступные skills"""
        skills = await self.client.list_skills(category=category)

        return skills['skills']

# Добавление в Claude Code MCP
class SkillsServiceMCP:
    """MCP сервер для Skills Service"""

    def __init__(self):
        self.tools = [
            {
                "name": "use_skill",
                "description": "Execute a skill from Skills Service",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "skill_name": {
                            "type": "string",
                            "description": "Name of the skill to execute"
                        },
                        "input_data": {
                            "type": "object",
                            "description": "Input data for the skill"
                        }
                    },
                    "required": ["skill_name", "input_data"]
                }
            },
            {
                "name": "list_skills",
                "description": "List available skills",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "category": {
                            "type": "string",
                            "description": "Filter by category"
                        }
                    }
                }
            },
            {
                "name": "search_skills",
                "description": "Search for skills",
                "input_schema": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "Search query"
                        }
                    },
                    "required": ["query"]
                }
            }
        ]

    async def call_tool(self, tool_name: str, arguments: dict):
        """Handle tool calls"""
        client = SkillsTool(config)

        if tool_name == "use_skill":
            return await client.use_skill(
                arguments['skill_name'],
                arguments['input_data']
            )
        elif tool_name == "list_skills":
            return await client.list_available_skills(
                arguments.get('category')
            )
        elif tool_name == "search_skills":
            return await client.client.search_skills(
                arguments['query']
            )
```

---

## Deployment

### Docker Compose

```yaml
# docker-compose.yml

version: '3.8'

services:
  # API Gateway
  kong:
    image: kong:3.4
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: postgres
      KONG_PG_DATABASE: kong
    ports:
      - "8000:8000"  # HTTP
      - "8443:8443"  # HTTPS
      - "8001:8001"  # Admin API
    depends_on:
      - postgres

  # Skills Service
  skills-api:
    build: ./skills-service
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/skills
      REDIS_URL: redis://redis:6379
      MONGO_URL: mongodb://mongo:27017
      S3_ENDPOINT: http://minio:9000
      CLAUDE_API_KEY: ${CLAUDE_API_KEY}
    deploy:
      replicas: 3
    depends_on:
      - postgres
      - redis
      - mongo
      - minio

  # PostgreSQL
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: skills
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Redis
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  # MongoDB
  mongo:
    image: mongo:7
    volumes:
      - mongo_data:/data/db

  # MinIO (S3-compatible)
  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data

  # RabbitMQ
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"

  # ClickHouse (Analytics)
  clickhouse:
    image: clickhouse/clickhouse-server
    ports:
      - "8123:8123"
      - "9000:9000"
    volumes:
      - clickhouse_data:/var/lib/clickhouse

volumes:
  postgres_data:
  redis_data:
  mongo_data:
  minio_data:
  clickhouse_data:
```

### Kubernetes

```yaml
# k8s-deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: skills-service
spec:
  replicas: 5
  selector:
    matchLabels:
      app: skills-service
  template:
    metadata:
      labels:
        app: skills-service
    spec:
      containers:
      - name: api
        image: skills-service:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: skills-secrets
              key: database-url
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: skills-service
spec:
  selector:
    app: skills-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer

---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: skills-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: skills-service
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

## Преимущества этого подхода

✅ **Platform-agnostic**
- Работает с любым LLM
- Claude Code, ChatGPT, Gemini могут подключиться

✅ **Scalability**
- Horizontal scaling
- Load balancing
- Auto-scaling по нагрузке

✅ **Security**
- Sandboxed execution
- Resource limits
- Access control
- Rate limiting

✅ **Monitoring**
- Detailed analytics
- Performance metrics
- Cost attribution
- Error tracking

✅ **Flexibility**
- Новый формат skills (YAML)
- Multiple runtimes (Claude, Python, JS)
- Версионирование
- A/B testing

✅ **Monetization**
- Pay-per-use
- Subscriptions
- Enterprise licenses
- API marketplace

---

(Продолжение следует с Вариантом 2: Skills как база методов...)

FUTURE_EOF

echo "✅ Часть 1 создана: Вариант 1 (Skills как внешний сервис)"

# Вариант 2: Skills как база методов (Pseudo-RAG)

## Концепция

**Skills = База готовых методов**, к которой AI обращается ПЕРЕД решением задачи, чтобы найти подходящие подходы/инструменты.

```
┌─────────────────────────────────────────────────┐
│              AI получает задачу                  │
│  "Organize 1000 files by type and date"         │
└───────────────────┬─────────────────────────────┘
                    │
                    ↓ 1. Query Method DB
┌─────────────────────────────────────────────────┐
│           Skills Method Database                 │
│  • Semantic search для задачи                   │
│  • Находит релевантные методы                   │
│  • Возвращает не ответы, а МЕТОДЫ               │
└───────────────────┬─────────────────────────────┘
                    │
                    ↓ 2. Получает методы
┌─────────────────────────────────────────────────┐
│    [file-organizer, batch-processor,            │
│     backup-creator, progress-tracker]           │
└───────────────────┬─────────────────────────────┘
                    │
                    ↓ 3. AI композирует решение
┌─────────────────────────────────────────────────┐
│           AI решает задачу используя:            │
│  1. backup-creator (создать backup)             │
│  2. file-organizer (organize)                   │
│  3. batch-processor (процессить по batch)       │
│  4. progress-tracker (показать прогресс)        │
└─────────────────────────────────────────────────┘
```

### Ключевое отличие от RAG

**Классический RAG:**
```python
# RAG ищет ОТВЕТЫ/КОНТЕКСТ
query = "What is machine learning?"
documents = vector_db.search(query)
# → Возвращает документы с определениями ML
context = documents[0].content  # "Machine learning is..."
answer = llm.generate(query, context=context)
```

**Skills Method DB (Pseudo-RAG):**
```python
# Method DB ищет МЕТОДЫ/ИНСТРУМЕНТЫ
task = "Train a machine learning model"
methods = method_db.search(task)
# → Возвращает готовые МЕТОДЫ
# methods = [
#   'data-preprocessor',
#   'model-trainer',
#   'hyperparameter-tuner',
#   'model-evaluator'
# ]

# AI использует методы как инструменты
solution = llm.solve_with_methods(task, available_methods=methods)
```

**Аналогия:**
- RAG = Библиотека с книгами (ищем информацию)
- Method DB = Ящик с инструментами (ищем инструменты для работы)

---

## Архитектура Method Database

### High-Level Architecture

```
┌──────────────────────────────────────────────────────┐
│                  AI Agent/LLM                         │
│  • Получает задачу                                   │
│  • Запрашивает релевантные методы                    │
│  • Композирует решение                               │
│  • Выполняет с использованием методов                │
└────────────────────────┬─────────────────────────────┘
                         │
                         ↓ Query Interface
┌──────────────────────────────────────────────────────┐
│              Method Query Engine                      │
│  • Semantic matching (задача ↔ методы)              │
│  • Relevance scoring                                 │
│  • Method ranking                                    │
│  • Composition suggestions                           │
└────────────────────────┬─────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────┐
│           Vector Database (Embeddings)                │
│  • Method embeddings                                 │
│  • Task embeddings                                   │
│  • Capability embeddings                             │
│  • Similar methods clustering                        │
└────────────────────────┬─────────────────────────────┘
                         │
                         ↓
┌──────────────────────────────────────────────────────┐
│              Skills Method Repository                 │
│                                                       │
│  ┌────────────────────────────────────────────────┐ │
│  │  Method Metadata Store (MongoDB)               │ │
│  │  • Method descriptions                         │ │
│  │  • Capabilities                                │ │
│  │  • Prerequisites                               │ │
│  │  • Use cases                                   │ │
│  │  • Success criteria                            │ │
│  └────────────────────────────────────────────────┘ │
│                                                       │
│  ┌────────────────────────────────────────────────┐ │
│  │  Method Implementations (S3)                   │ │
│  │  • Code/instructions                           │ │
│  │  • Examples                                    │ │
│  │  • Test cases                                  │ │
│  └────────────────────────────────────────────────┘ │
│                                                       │
│  ┌────────────────────────────────────────────────┐ │
│  │  Method Relations (Graph DB)                   │ │
│  │  • Dependencies                                │ │
│  │  • Compositions                                │ │
│  │  • Alternatives                                │ │
│  │  • Complementary methods                       │ │
│  └────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

---

## Технические детали

### 1. Method Schema

```yaml
# method.yaml - Формат метода в базе

apiVersion: methods.ai/v1
kind: Method
metadata:
  id: file-organizer-by-type
  name: File Organizer by Type
  version: 1.0.0
  category: file-management
  tags:
    - files
    - organization
    - automation

# Семантическое описание (для векторного поиска)
semantics:
  purpose: |
    Organize files into folders based on their types (extensions).
    Analyzes file extensions and creates appropriate folder structure.

  capabilities:
    - Detect file types by extension
    - Create categorized folder structure
    - Move files to appropriate folders
    - Handle duplicates
    - Generate organization report

  suitable_for:
    - Large number of unsorted files
    - Mixed file types in one location
    - Need for automatic categorization
    - Bulk file organization

  not_suitable_for:
    - Files requiring content analysis
    - Complex business logic sorting
    - Custom naming schemes

  prerequisites:
    - Read/write filesystem access
    - Files to organize are in single directory

  outcomes:
    - Files organized into type-based folders
    - Original files optionally backed up
    - Organization report generated

# Embedding для semantic search
embedding:
  model: text-embedding-3-large
  vector: [0.123, -0.456, 0.789, ...]  # 3072-dim vector
  last_updated: 2026-01-28T10:00:00Z

# Примеры задач, для которых подходит
use_cases:
  - description: Organize cluttered Downloads folder
    input_example: "I have 500 files in Downloads, need to organize them"
    relevance_score: 0.95

  - description: Sort project files by type
    input_example: "Separate images, docs, and code files"
    relevance_score: 0.90

  - description: Clean up desktop files
    input_example: "Desktop has too many files, organize by extension"
    relevance_score: 0.88

# Связи с другими методами
relations:
  complements:
    - method_id: backup-creator
      reason: Good to backup before organizing
      score: 0.85

    - method_id: duplicate-finder
      reason: Find duplicates before organizing
      score: 0.80

  alternatives:
    - method_id: file-organizer-by-date
      reason: Alternative organizing strategy
      when_to_prefer: When chronological order more important

    - method_id: file-organizer-by-content
      reason: More advanced, content-based
      when_to_prefer: When need semantic organization

  depends_on:
    - method_id: file-type-detector
      required: true

  enables:
    - method_id: file-search-optimizer
      reason: Organized files easier to search

# Метрики использования
metrics:
  usage_count: 1543
  success_rate: 0.94
  avg_duration_seconds: 12.5
  user_rating: 4.6
  common_failures:
    - Permission denied: 15%
    - Insufficient disk space: 8%
    - Invalid file names: 3%

# Инструкции для AI
ai_instructions:
  when_to_use: |
    Use this method when user wants to organize files by type/extension.
    Suitable for bulk file organization tasks.
    Not suitable if content-based organization needed.

  how_to_use: |
    1. Verify user has target directory path
    2. Ask if backup needed (recommend yes)
    3. Call method with directory path
    4. Show organization report to user

  parameters:
    source_directory:
      type: path
      required: true
      description: Directory containing files to organize

    create_backup:
      type: boolean
      default: true
      description: Create backup before organizing

    folder_mapping:
      type: object
      optional: true
      description: Custom extension -> folder mappings

  expected_output:
    organized_count: integer
    folder_structure: object
    errors: array

# Реализация
implementation:
  type: claude-skill
  instructions_url: s3://methods/file-organizer-by-type/instructions.md
  examples_url: s3://methods/file-organizer-by-type/examples.json
  code_url: s3://methods/file-organizer-by-type/code.py  # optional
```

### 2. Method Query Engine

```python
# method_query_engine.py

from typing import List, Dict, Any
import numpy as np
from sentence_transformers import SentenceTransformer
import faiss

class MethodQueryEngine:
    """Движок для поиска подходящих методов"""

    def __init__(self):
        # Модель для embeddings
        self.encoder = SentenceTransformer('all-MiniLM-L6-v2')

        # Vector database (FAISS)
        self.index = faiss.IndexFlatL2(384)  # 384-dim embeddings

        # Metadata store
        self.methods_db = MethodsDatabase()

        # Graph для relations
        self.graph = MethodRelationGraph()

        # Загрузить все методы
        self.load_methods()

    def load_methods(self):
        """Загрузить методы в vector DB"""
        methods = self.methods_db.get_all_methods()

        for method in methods:
            # Если embedding уже есть - использовать
            if method.get('embedding'):
                vector = np.array(method['embedding']['vector'])
            else:
                # Иначе создать
                vector = self.create_embedding(method)

            # Добавить в FAISS index
            self.index.add(vector.reshape(1, -1))

    def create_embedding(self, method: Dict) -> np.ndarray:
        """Создать embedding для метода"""
        # Объединить все семантические поля
        text = f"""
        {method['semantics']['purpose']}

        Capabilities: {', '.join(method['semantics']['capabilities'])}

        Suitable for: {', '.join(method['semantics']['suitable_for'])}

        Use cases: {' '.join([uc['description'] for uc in method['use_cases']])}
        """

        embedding = self.encoder.encode(text)

        return embedding

    def search_methods(
        self,
        task_description: str,
        top_k: int = 5,
        min_relevance: float = 0.7
    ) -> List[Dict]:
        """
        Поиск подходящих методов для задачи

        Args:
            task_description: Описание задачи от пользователя
            top_k: Количество методов
            min_relevance: Минимальная релевантность

        Returns:
            List методов с scores
        """

        # 1. Создать embedding задачи
        task_embedding = self.encoder.encode(task_description)

        # 2. Поиск в FAISS
        distances, indices = self.index.search(
            task_embedding.reshape(1, -1),
            top_k * 2  # Ищем больше для фильтрации
        )

        # 3. Получить методы
        candidates = []
        for distance, idx in zip(distances[0], indices[0]):
            # Convert distance to similarity score
            similarity = 1 / (1 + distance)

            if similarity >= min_relevance:
                method = self.methods_db.get_method_by_index(idx)
                candidates.append({
                    'method': method,
                    'similarity_score': similarity,
                    'distance': distance
                })

        # 4. Re-ranking с учетом метрик и контекста
        ranked = self.rerank_methods(
            candidates,
            task_description
        )

        # 5. Добавить комплементарные методы
        enhanced = self.add_complementary_methods(ranked)

        return enhanced[:top_k]

    def rerank_methods(
        self,
        candidates: List[Dict],
        task: str
    ) -> List[Dict]:
        """Re-ranking с учетом дополнительных факторов"""

        for candidate in candidates:
            method = candidate['method']

            # Базовый score - semantic similarity
            base_score = candidate['similarity_score']

            # Качество метода (success rate, rating)
            quality_score = (
                method['metrics']['success_rate'] * 0.6 +
                (method['metrics']['user_rating'] / 5.0) * 0.4
            )

            # Популярность (но не слишком большой вес)
            popularity_score = min(
                method['metrics']['usage_count'] / 1000.0,
                1.0
            )

            # Комбинированный score
            final_score = (
                base_score * 0.60 +
                quality_score * 0.25 +
                popularity_score * 0.15
            )

            candidate['final_score'] = final_score

        # Сортировать по final_score
        ranked = sorted(
            candidates,
            key=lambda x: x['final_score'],
            reverse=True
        )

        return ranked

    def add_complementary_methods(
        self,
        methods: List[Dict]
    ) -> List[Dict]:
        """Добавить комплементарные методы"""

        enhanced = []

        for method_data in methods:
            method = method_data['method']
            enhanced.append(method_data)

            # Найти комплементарные
            complements = method.get('relations', {}).get('complements', [])

            for complement in complements[:2]:  # Топ-2 комплемента
                # Проверить, не добавлен ли уже
                if not any(e['method']['id'] == complement['method_id'] for e in enhanced):
                    complement_method = self.methods_db.get_method(
                        complement['method_id']
                    )

                    enhanced.append({
                        'method': complement_method,
                        'final_score': complement['score'],
                        'relationship': 'complement',
                        'reason': complement['reason']
                    })

        return enhanced

    def suggest_method_composition(
        self,
        task: str,
        methods: List[Dict]
    ) -> Dict:
        """Предложить композицию методов для выполнения задачи"""

        # Использовать LLM для анализа
        prompt = f"""
        Task: {task}

        Available methods:
        {self._format_methods_for_prompt(methods)}

        Suggest a composition (sequence/pipeline) of these methods to solve the task.

        Consider:
        - Method dependencies
        - Logical order
        - Complementary methods
        - Prerequisites and outcomes

        Return JSON:
        {{
            "pipeline": [
                {{
                    "step": 1,
                    "method_id": "...",
                    "reason": "why this method at this step"
                }},
                ...
            ],
            "rationale": "overall explanation"
        }}
        """

        # Call LLM
        composition = llm.generate(prompt)

        return composition

    def _format_methods_for_prompt(self, methods: List[Dict]) -> str:
        """Форматировать методы для промпта"""
        formatted = []

        for m in methods:
            method = m['method']
            formatted.append(f"""
            - {method['name']} (ID: {method['id']})
              Purpose: {method['semantics']['purpose'][:200]}
              Capabilities: {', '.join(method['semantics']['capabilities'][:3])}
              Score: {m.get('final_score', 0):.2f}
            """)

        return '\n'.join(formatted)


class MethodComposer:
    """Композиция методов в pipeline"""

    def __init__(self):
        self.methods_db = MethodsDatabase()

    def create_pipeline(
        self,
        method_ids: List[str]
    ) -> 'MethodPipeline':
        """Создать pipeline из методов"""

        # Загрузить методы
        methods = [
            self.methods_db.get_method(mid)
            for mid in method_ids
        ]

        # Проверить dependencies
        self.validate_dependencies(methods)

        # Создать pipeline
        pipeline = MethodPipeline(methods)

        return pipeline

    def validate_dependencies(self, methods: List[Dict]):
        """Проверить зависимости между методами"""

        for i, method in enumerate(methods):
            depends_on = method.get('relations', {}).get('depends_on', [])

            for dep in depends_on:
                if dep['required']:
                    # Проверить что dependency есть до этого метода
                    dep_found = any(
                        m['id'] == dep['method_id']
                        for m in methods[:i]
                    )

                    if not dep_found:
                        raise ValueError(
                            f"Method {method['name']} requires {dep['method_id']} "
                            f"but it's not in pipeline before this method"
                        )

    def suggest_order(
        self,
        methods: List[Dict]
    ) -> List[Dict]:
        """Предложить оптимальный порядок методов"""

        # Topological sort на основе dependencies
        from collections import defaultdict, deque

        # Build dependency graph
        graph = defaultdict(list)
        in_degree = defaultdict(int)

        for method in methods:
            method_id = method['id']
            in_degree[method_id] = 0

        for method in methods:
            method_id = method['id']
            deps = method.get('relations', {}).get('depends_on', [])

            for dep in deps:
                graph[dep['method_id']].append(method_id)
                in_degree[method_id] += 1

        # Topological sort
        queue = deque([
            mid for mid in in_degree
            if in_degree[mid] == 0
        ])

        ordered = []

        while queue:
            method_id = queue.popleft()
            ordered.append(method_id)

            for neighbor in graph[method_id]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        # Convert back to methods
        ordered_methods = [
            next(m for m in methods if m['id'] == mid)
            for mid in ordered
        ]

        return ordered_methods


class MethodPipeline:
    """Pipeline методов для выполнения"""

    def __init__(self, methods: List[Dict]):
        self.methods = methods
        self.current_step = 0
        self.results = []

    async def execute(self, initial_input: Any):
        """Выполнить весь pipeline"""

        current_data = initial_input

        for i, method in enumerate(self.methods):
            self.current_step = i

            print(f"Executing step {i+1}/{len(self.methods)}: {method['name']}")

            # Выполнить метод
            result = await self.execute_method(method, current_data)

            self.results.append({
                'step': i + 1,
                'method': method['name'],
                'result': result
            })

            # Output этого метода = input следующего
            current_data = result

        return {
            'final_result': current_data,
            'steps': self.results
        }

    async def execute_method(self, method: Dict, input_data: Any):
        """Выполнить один метод"""

        # Load implementation
        implementation = await self.load_implementation(method)

        # Execute
        if method['implementation']['type'] == 'claude-skill':
            result = await self.execute_claude_skill(
                implementation,
                input_data
            )
        elif method['implementation']['type'] == 'python':
            result = await self.execute_python(
                implementation,
                input_data
            )
        # etc.

        return result
```

### 3. Интеграция с AI

```python
# ai_integration.py - Как AI использует Method DB

from typing import List, Dict, Any

class AIMethodAgent:
    """AI агент, использующий Method DB"""

    def __init__(self):
        self.query_engine = MethodQueryEngine()
        self.composer = MethodComposer()
        self.executor = MethodExecutor()

    async def solve_task(self, task_description: str) -> Any:
        """
        Решить задачу используя методы из базы

        Workflow:
        1. Понять задачу
        2. Найти подходящие методы
        3. Скомпоновать pipeline
        4. Выполнить
        5. Вернуть результат
        """

        print(f"📋 Task: {task_description}")

        # 1. Analyze task
        task_analysis = await self.analyze_task(task_description)

        print(f"🔍 Task type: {task_analysis['type']}")
        print(f"🎯 Key requirements: {task_analysis['requirements']}")

        # 2. Search methods
        methods = self.query_engine.search_methods(
            task_description,
            top_k=10
        )

        print(f"🔧 Found {len(methods)} relevant methods")
        for m in methods[:3]:
            print(f"  - {m['method']['name']} (score: {m['final_score']:.2f})")

        # 3. Suggest composition
        composition = self.query_engine.suggest_method_composition(
            task_description,
            methods
        )

        print(f"📐 Suggested pipeline:")
        for step in composition['pipeline']:
            method_name = next(
                m['method']['name']
                for m in methods
                if m['method']['id'] == step['method_id']
            )
            print(f"  {step['step']}. {method_name}")
            print(f"     Reason: {step['reason']}")

        # 4. Ask user for confirmation (optional)
        # confirmed = input("Proceed with this plan? (y/n): ")

        # 5. Execute pipeline
        pipeline = self.composer.create_pipeline([
            step['method_id']
            for step in composition['pipeline']
        ])

        result = await pipeline.execute(
            initial_input=task_analysis['input_data']
        )

        print(f"✅ Task completed!")

        return result

    async def analyze_task(self, task: str) -> Dict:
        """Проанализировать задачу"""

        # Use LLM to understand task
        analysis_prompt = f"""
        Analyze this task:
        "{task}"

        Extract:
        1. Task type (e.g., file_management, data_processing, content_creation)
        2. Key requirements
        3. Input data (what user is starting with)
        4. Expected output
        5. Constraints or preferences

        Return JSON.
        """

        analysis = await llm.generate(analysis_prompt)

        return analysis

# Пример использования

agent = AIMethodAgent()

# Пользователь дает задачу
task = """
I have a folder with 1000 mixed files (images, documents, videos).
I need to:
1. Organize them by type
2. Find and remove duplicates
3. Compress images to save space
4. Create a backup
5. Generate a report
"""

# AI решает используя методы из базы
result = await agent.solve_task(task)

# Output:
# 📋 Task: I have a folder with 1000 mixed files...
# 🔍 Task type: file_management
# 🎯 Key requirements: ['organize', 'deduplicate', 'compress', 'backup', 'report']
# 🔧 Found 10 relevant methods
#   - File Organizer by Type (score: 0.94)
#   - Duplicate Finder (score: 0.89)
#   - Image Compressor (score: 0.87)
# 📐 Suggested pipeline:
#   1. Backup Creator
#      Reason: Create backup before any modifications
#   2. Duplicate Finder
#      Reason: Find duplicates before organizing to avoid moving duplicates
#   3. File Organizer by Type
#      Reason: Main organization task
#   4. Image Compressor
#      Reason: Compress images in organized folders
#   5. Report Generator
#      Reason: Generate final report
# ✅ Task completed!
```

### 4. Интерфейс для добавления методов

```python
# method_indexer.py - Индексирование новых методов

class MethodIndexer:
    """Добавление методов в базу"""

    def __init__(self):
        self.query_engine = MethodQueryEngine()
        self.methods_db = MethodsDatabase()

    async def index_method(self, method: Dict):
        """
        Индексировать новый метод

        1. Валидация
        2. Создание embedding
        3. Сохранение в DB
        4. Добавление в vector index
        5. Обновление relations
        """

        # 1. Validate
        validation = self.validate_method(method)
        if not validation.valid:
            raise ValueError(f"Invalid method: {validation.errors}")

        # 2. Create embedding
        embedding = self.query_engine.create_embedding(method)
        method['embedding'] = {
            'model': 'all-MiniLM-L6-v2',
            'vector': embedding.tolist(),
            'created_at': datetime.now()
        }

        # 3. Save to database
        method_id = await self.methods_db.save_method(method)

        # 4. Add to vector index
        self.query_engine.index.add(embedding.reshape(1, -1))

        # 5. Update relations graph
        await self.update_relations(method)

        print(f"✅ Method '{method['name']}' indexed successfully")
        print(f"   ID: {method_id}")

        return method_id

    async def bulk_index(self, methods: List[Dict]):
        """Массовое индексирование"""

        for method in methods:
            try:
                await self.index_method(method)
            except Exception as e:
                print(f"❌ Failed to index {method.get('name')}: {e}")

    async def reindex_all(self):
        """Переиндексировать все методы (например, после обновления модели)"""

        methods = await self.methods_db.get_all_methods()

        print(f"Reindexing {len(methods)} methods...")

        # Clear index
        self.query_engine.index = faiss.IndexFlatL2(384)

        # Reindex
        await self.bulk_index(methods)

        print("✅ Reindexing complete")

    def find_similar_methods(self, method_id: str, top_k: int = 5):
        """Найти похожие методы"""

        method = self.methods_db.get_method(method_id)

        if not method.get('embedding'):
            raise ValueError("Method not indexed")

        embedding = np.array(method['embedding']['vector'])

        # Search
        distances, indices = self.query_engine.index.search(
            embedding.reshape(1, -1),
            top_k + 1  # +1 because method itself will be in results
        )

        # Filter out the method itself
        similar = []
        for distance, idx in zip(distances[0], indices[0]):
            similar_method = self.methods_db.get_method_by_index(idx)

            if similar_method['id'] != method_id:
                similar.append({
                    'method': similar_method,
                    'similarity': 1 / (1 + distance)
                })

        return similar[:top_k]

    async def suggest_relations(self, method_id: str):
        """Автоматически предложить relations для метода"""

        # Find similar methods
        similar = self.find_similar_methods(method_id, top_k=10)

        suggestions = {
            'complements': [],
            'alternatives': []
        }

        for s in similar:
            similarity = s['similarity']

            if similarity > 0.85:
                # Very similar - probably alternative
                suggestions['alternatives'].append({
                    'method_id': s['method']['id'],
                    'reason': 'High similarity in capabilities',
                    'score': similarity
                })
            elif 0.6 < similarity <= 0.85:
                # Somewhat similar - might complement
                suggestions['complements'].append({
                    'method_id': s['method']['id'],
                    'reason': 'Related but different focus',
                    'score': similarity
                })

        return suggestions
```

---

## Преимущества Pseudo-RAG подхода

✅ **Не изобретаем велосипед**
- AI сначала проверяет готовые методы
- Переиспользование proven solutions
- Faster problem solving

✅ **Композиция методов**
- Комбинирование простых методов для сложных задач
- Flexible pipelines
- Modular approach

✅ **Адаптивность**
- База методов постоянно растет
- Self-improving (новые методы от пользователей)
- AI учится лучше использовать методы

✅ **Эффективность**
- Не нужно генерировать решение с нуля
- Reuse tested methods
- Fewer errors

✅ **Прозрачность**
- Видно какие методы использовались
- Reproducible results
- Easier debugging

✅ **Специализация**
- Методы - это специализированные инструменты
- AI - это universal problem solver
- Best of both worlds

---

## Use Cases

### Use Case 1: Сложная data processing задача

```python
task = """
Process a large CSV file (10GB):
1. Clean invalid rows
2. Normalize dates
3. Extract entities from text columns
4. Join with external data
5. Calculate aggregations
6. Export to multiple formats (CSV, JSON, Parquet)
7. Generate summary report
"""

# AI queries Method DB
methods = method_db.search(task)

# Found methods:
# 1. csv-stream-processor (for large files)
# 2. data-cleaner
# 3. date-normalizer
# 4. entity-extractor
# 5. data-joiner
# 6. aggregation-calculator
# 7. multi-format-exporter
# 8. report-generator

# AI composes pipeline
pipeline = [
    'csv-stream-processor',    # Handle large file
    'data-cleaner',            # Clean
    'date-normalizer',         # Normalize
    'entity-extractor',        # Extract
    'data-joiner',             # Join
    'aggregation-calculator',  # Aggregate
    'multi-format-exporter',   # Export
    'report-generator'         # Report
]

# Execute
result = await execute_pipeline(pipeline, input_file='data.csv')
```

### Use Case 2: Creative content creation

```python
task = """
Create a marketing campaign:
1. Research target audience
2. Generate campaign ideas
3. Write copy for social media
4. Design visuals
5. Schedule posts
"""

# Methods found:
# 1. audience-research-assistant
# 2. campaign-idea-generator
# 3. social-copy-writer
# 4. image-generator
# 5. post-scheduler

# AI composes and executes
```

### Use Case 3: Software development task

```python
task = """
Add a new feature to codebase:
1. Understand existing code
2. Design the feature
3. Write code
4. Write tests
5. Generate documentation
6. Create PR
"""

# Methods:
# 1. codebase-analyzer
# 2. feature-designer
# 3. code-generator
# 4. test-generator
# 5. doc-generator
# 6. pr-creator
```

---

(Продолжение следует с сравнением и гибридным подходом...)


# Сравнение вариантов

## Таблица сравнения

| Аспект | Вариант 1: External Service | Вариант 2: Method DB (Pseudo-RAG) |
|--------|----------------------------|----------------------------------|
| **Архитектура** | Централизованный сервис | База методов + Vector search |
| **Доступ** | API endpoints | Semantic search |
| **Формат** | YAML/JSON skills | Method schemas с embeddings |
| **Execution** | Service выполняет | AI композирует и выполняет |
| **Platform** | Независимый от LLM | Интегрирован с AI |
| **Масштабирование** | Horizontal scaling | Vector DB scaling |
| **Поиск** | By ID/category/tags | Semantic similarity |
| **Композиция** | Manual chaining | AI-driven composition |
| **Монетизация** | API subscriptions | Skill marketplace |
| **Обучение** | Не требуется | AI учится использовать методы |
| **Прозрачность** | API logs | Method pipeline visible |

## Сильные стороны каждого варианта

### Вариант 1: External Service

**Лучше когда:**
- ✅ Нужна независимость от конкретного LLM
- ✅ Важна централизованная monetization
- ✅ Требуется strict security/compliance
- ✅ Необходим контроль execution
- ✅ Enterprise клиенты (SLA, support)

**Примеры use cases:**
- Enterprise platform для компаний
- API для разных LLM providers
- Regulated industries (финансы, медицина)
- Mission-critical applications

### Вариант 2: Method DB (Pseudo-RAG)

**Лучше когда:**
- ✅ AI должен самостоятельно решать задачи
- ✅ Нужна flexibility в композиции методов
- ✅ Важна адаптивность под разные задачи
- ✅ Требуется transparency (видимость процесса)
- ✅ Continuous learning от использования

**Примеры use cases:**
- AI agents с автономностью
- Creative problem solving
- Research & experimentation
- Personalized AI assistants

---

# Гибридный подход

## Концепция

**Объединить лучшее из обоих вариантов:**

```
┌─────────────────────────────────────────────────┐
│                  AI Agent                        │
│  • Анализирует задачу                           │
│  • Выбирает подход                              │
└───────────────────┬─────────────────────────────┘
                    │
        ┌───────────┴────────────┐
        │                        │
        ↓                        ↓
┌──────────────────┐    ┌──────────────────┐
│   Method DB      │    │ External Service │
│  (Pseudo-RAG)    │    │   (API-based)    │
│                  │    │                  │
│ • Semantic       │    │ • Execution      │
│   search         │    │ • Monitoring     │
│ • Composition    │    │ • Billing        │
│ • Planning       │    │ • Security       │
└──────────────────┘    └──────────────────┘
```

## Архитектура

```python
# hybrid_system.py - Гибридная система

class HybridSkillsSystem:
    """Гибридная система - Method DB + External Service"""

    def __init__(self):
        # Method DB для поиска и планирования
        self.method_db = MethodQueryEngine()

        # External Service для выполнения
        self.skills_service = SkillsServiceClient(
            api_url='https://api.skills.com',
            api_key=os.getenv('SKILLS_API_KEY')
        )

    async def solve_task(self, task: str):
        """
        Workflow:
        1. Method DB: найти подходящие методы
        2. Method DB: спланировать композицию
        3. External Service: выполнить skills
        4. Return результаты
        """

        # 1. Search methods в Method DB
        methods = self.method_db.search_methods(task, top_k=10)

        print(f"Found {len(methods)} methods via semantic search")

        # 2. Plan composition
        composition = self.method_db.suggest_method_composition(
            task,
            methods
        )

        print("Planned pipeline:")
        for step in composition['pipeline']:
            print(f"  {step['step']}. {step['method_id']}")

        # 3. Execute через External Service
        results = []

        for step in composition['pipeline']:
            method_id = step['method_id']

            # Получить input для этого шага
            step_input = results[-1]['result'] if results else task

            # Execute через API
            result = await self.skills_service.execute_skill(
                skill_id=method_id,
                input_data={'input': step_input}
            )

            results.append({
                'step': step['step'],
                'method': method_id,
                'result': result['result']
            })

            print(f"✓ Step {step['step']} completed")

        return {
            'final_result': results[-1]['result'],
            'steps': results
        }

# Использование
hybrid = HybridSkillsSystem()

task = "Analyze customer feedback from CSV and create report"

# Method DB найдет методы
# External Service выполнит
result = await hybrid.solve_task(task)
```

## Преимущества гибрида

✅ **Best of both worlds:**
- Method DB для intelligent planning
- External Service для robust execution

✅ **Flexibility:**
- AI может планировать любые композиции
- Service гарантирует качество выполнения

✅ **Scalability:**
- Method DB: vector search scales well
- External Service: horizontal scaling

✅ **Security:**
- Sandboxed execution в service
- Rate limiting и access control

✅ **Monetization:**
- Method DB: бесплатный поиск
- External Service: pay-per-execution

✅ **Learning:**
- Method DB улучшается от feedback
- Service собирает usage analytics

---

# Детальная реализация гибрида

## 1. Method DB с ссылками на External Service

```yaml
# method_hybrid.yaml

apiVersion: methods.ai/v1
kind: Method
metadata:
  id: file-organizer-by-type
  name: File Organizer by Type

# Semantic info для поиска
semantics:
  purpose: Organize files by type
  capabilities: [...]
  suitable_for: [...]

# Ссылка на implementation в External Service
implementation:
  type: external-service
  service_url: https://api.skills.com
  skill_id: file-organizer-by-type
  version: 2.1.0

# Authentication
execution:
  requires_auth: true
  rate_limit: 100/hour
  cost: 0.01  # USD per execution

# Метрики (синхронизируются из service)
metrics:
  usage_count: 1543  # from service
  success_rate: 0.94  # from service
  avg_duration_ms: 2341  # from service
```

## 2. External Service с Method DB интеграцией

```python
# skills_service_with_method_db.py

class SkillsServiceWithMethodDB:
    """External Service с интеграцией Method DB"""

    def __init__(self):
        self.executor = SkillsExecutor()
        self.method_indexer = MethodIndexer()

    async def register_skill(self, skill: Dict):
        """
        Регистрация skill:
        1. В External Service (для execution)
        2. В Method DB (для search)
        """

        # 1. Register в service
        service_id = await self.skills_registry.register(skill)

        # 2. Create method entry для Method DB
        method = {
            'id': service_id,
            'name': skill['name'],
            'semantics': self.extract_semantics(skill),
            'implementation': {
                'type': 'external-service',
                'service_url': self.base_url,
                'skill_id': service_id
            },
            'metrics': {
                'usage_count': 0,
                'success_rate': 1.0,
                'avg_duration_ms': 0
            }
        }

        # 3. Index в Method DB
        await self.method_indexer.index_method(method)

        return service_id

    async def execute_skill_and_update_method_db(
        self,
        skill_id: str,
        input_data: Dict
    ):
        """Execute skill и обновить метрики в Method DB"""

        # Execute
        result = await self.executor.execute(skill_id, input_data)

        # Update metrics в Method DB
        await self.method_indexer.update_metrics(
            method_id=skill_id,
            metrics={
                'usage_count': '+1',
                'success_rate': result['success'],
                'duration_ms': result['duration_ms']
            }
        )

        return result

    def extract_semantics(self, skill: Dict) -> Dict:
        """Извлечь semantic info из skill"""

        # Используем LLM для извлечения semantics
        prompt = f"""
        From this skill definition, extract semantic information:

        Name: {skill['name']}
        Description: {skill['description']}
        Instructions: {skill['instructions'][:500]}
        Examples: {skill.get('examples', [])[:2]}

        Generate:
        1. Purpose (concise description)
        2. Capabilities (list)
        3. Suitable for (use cases)
        4. Prerequisites
        5. Expected outcomes

        Return JSON.
        """

        semantics = llm.generate(prompt)

        return semantics
```

## 3. AI Agent с гибридным доступом

```python
# hybrid_ai_agent.py

class HybridAIAgent:
    """AI Agent использующий Method DB + External Service"""

    def __init__(self):
        self.method_db = MethodQueryEngine()
        self.skills_service = SkillsServiceClient()
        self.cache = MethodCache()  # Local cache

    async def solve_task(
        self,
        task: str,
        execution_mode: str = 'auto'
    ):
        """
        Execution modes:
        - 'auto': AI выбирает best approach
        - 'local': Execute локально если possible
        - 'service': Always use external service
        - 'hybrid': Plan locally, execute remotely
        """

        # 1. Find methods
        methods = await self.method_db.search_methods(task)

        # 2. Choose execution strategy
        if execution_mode == 'auto':
            strategy = self.choose_execution_strategy(methods, task)
        else:
            strategy = execution_mode

        # 3. Execute based on strategy
        if strategy == 'local':
            # Execute locally if methods are simple
            result = await self.execute_locally(methods, task)

        elif strategy == 'service':
            # Use external service
            result = await self.execute_via_service(methods, task)

        elif strategy == 'hybrid':
            # Plan locally, execute parts remotely
            result = await self.execute_hybrid(methods, task)

        return result

    def choose_execution_strategy(
        self,
        methods: List[Dict],
        task: str
    ) -> str:
        """AI выбирает оптимальную стратегию"""

        # Факторы:
        # - Сложность методов
        # - Требования к ресурсам
        # - Стоимость API calls
        # - Latency requirements
        # - Security/privacy

        complexity_score = self.calculate_complexity(methods)
        cost = self.estimate_cost(methods)
        latency_requirement = self.analyze_latency_needs(task)

        if complexity_score < 0.3 and cost < 0.10:
            return 'local'  # Simple and cheap - do locally

        elif complexity_score > 0.7 or cost > 1.00:
            return 'service'  # Complex or expensive - use service

        else:
            return 'hybrid'  # Mix of local and remote

    async def execute_hybrid(
        self,
        methods: List[Dict],
        task: str
    ):
        """Hybrid execution - some local, some remote"""

        composition = self.method_db.suggest_method_composition(
            task,
            methods
        )

        results = []

        for step in composition['pipeline']:
            method = next(
                m for m in methods
                if m['method']['id'] == step['method_id']
            )

            # Decide: local or remote?
            if self.can_execute_locally(method):
                # Execute locally
                result = await self.execute_method_locally(
                    method,
                    input_data=results[-1] if results else task
                )
            else:
                # Execute via service
                result = await self.skills_service.execute_skill(
                    skill_id=method['method']['id'],
                    input_data=results[-1] if results else task
                )

            results.append(result)

        return {
            'final_result': results[-1],
            'steps': results
        }

    def can_execute_locally(self, method: Dict) -> bool:
        """Проверить, можно ли выполнить локально"""

        # Check если есть local implementation
        impl = method['method'].get('implementation', {})

        if impl['type'] == 'claude-skill':
            # Claude skills можем выполнить локально
            return True

        elif impl['type'] == 'python' and self.has_dependencies(method):
            # Python scripts если есть dependencies
            return True

        elif impl['type'] == 'external-service':
            # Нужен external service
            return False

        return False
```

## 4. Кэширование и оптимизация

```python
# method_cache.py

class MethodCache:
    """Cache для результатов execution"""

    def __init__(self):
        self.cache = {}  # In-memory
        self.redis = redis.Redis()  # Persistent

    async def get(
        self,
        method_id: str,
        input_hash: str
    ) -> Optional[Dict]:
        """Получить из cache"""

        cache_key = f"{method_id}:{input_hash}"

        # Try in-memory first
        if cache_key in self.cache:
            return self.cache[cache_key]

        # Try Redis
        cached = self.redis.get(cache_key)
        if cached:
            result = json.loads(cached)
            # Populate in-memory cache
            self.cache[cache_key] = result
            return result

        return None

    async def set(
        self,
        method_id: str,
        input_hash: str,
        result: Dict,
        ttl: int = 3600  # 1 hour
    ):
        """Сохранить в cache"""

        cache_key = f"{method_id}:{input_hash}"

        # In-memory
        self.cache[cache_key] = result

        # Redis with TTL
        self.redis.setex(
            cache_key,
            ttl,
            json.dumps(result)
        )

    def hash_input(self, input_data: Any) -> str:
        """Создать hash input для caching"""
        import hashlib

        # Convert to canonical JSON
        canonical = json.dumps(input_data, sort_keys=True)

        # SHA256 hash
        hash_obj = hashlib.sha256(canonical.encode())

        return hash_obj.hexdigest()

# Usage in agent

class OptimizedHybridAgent(HybridAIAgent):
    """Agent с кэшированием"""

    def __init__(self):
        super().__init__()
        self.cache = MethodCache()

    async def execute_method(
        self,
        method: Dict,
        input_data: Any
    ):
        """Execute с кэшированием"""

        method_id = method['method']['id']
        input_hash = self.cache.hash_input(input_data)

        # Check cache
        cached = await self.cache.get(method_id, input_hash)

        if cached:
            print(f"✓ Cache hit for {method['method']['name']}")
            return cached

        # Execute
        if self.can_execute_locally(method):
            result = await self.execute_method_locally(method, input_data)
        else:
            result = await self.skills_service.execute_skill(
                skill_id=method_id,
                input_data=input_data
            )

        # Cache result
        await self.cache.set(method_id, input_hash, result)

        return result
```

---

# Заключение

## Рекомендации по выбору

### Выбрать Вариант 1 (External Service) если:
- 🎯 Приоритет: Platform-as-a-Service
- 🎯 Нужна независимость от LLM
- 🎯 Enterprise клиенты
- 🎯 Monetization через API
- 🎯 Strict security/compliance

### Выбрать Вариант 2 (Method DB) если:
- 🎯 Приоритет: AI-native solution
- 🎯 Нужна flexibility композиции
- 🎯 Research & experimentation
- 🎯 Personalized AI assistants
- 🎯 Continuous learning

### Выбрать Гибридный подход если:
- 🎯 Нужны преимущества обоих
- 🎯 Разные use cases
- 🎯 Масштабируемость + Flexibility
- 🎯 Готовы к complexity реализации

## Roadmap внедрения

### Phase 1: MVP (2-3 месяца)
1. **Вариант 2 (Method DB)** - быстрее для MVP
   - Vector database setup
   - Basic method indexing
   - Semantic search
   - Simple AI integration

### Phase 2: Scale (3-6 месяцев)
2. **Вариант 1 (External Service)**
   - API infrastructure
   - Skills executor
   - Monitoring & billing
   - Enterprise features

### Phase 3: Optimize (6-12 месяцев)
3. **Гибридный подход**
   - Integrate Method DB + Service
   - Intelligent routing
   - Caching layer
   - Advanced features

## Метрики успеха

**Method DB:**
- Search relevance > 85%
- Method composition quality > 80%
- User satisfaction > 4.5/5

**External Service:**
- Uptime > 99.9%
- API latency < 200ms (p95)
- Success rate > 98%

**Гибридный:**
- Cache hit rate > 60%
- Cost reduction > 40%
- Performance improvement > 30%

---

# Практический пример

## Полный workflow гибридной системы

```python
# complete_example.py - Полный пример

import asyncio

async def main():
    # Initialize гибридная система
    system = HybridSkillsSystem(
        method_db_url='https://methods.ai',
        service_api_url='https://api.skills.com',
        api_key='your-api-key'
    )

    # Пользователь дает задачу
    task = """
    I have a dataset of 10,000 customer reviews.
    I need to:
    1. Clean and preprocess the text
    2. Perform sentiment analysis
    3. Extract key topics
    4. Identify trends over time
    5. Generate executive summary report
    6. Create visualizations
    """

    print("🎯 Task:", task)
    print()

    # 1. Method DB: Semantic search
    print("🔍 Searching Method DB for relevant methods...")
    methods = await system.method_db.search_methods(
        task_description=task,
        top_k=10
    )

    print(f"Found {len(methods)} relevant methods:")
    for m in methods[:5]:
        print(f"  ✓ {m['method']['name']} (score: {m['final_score']:.2f})")
    print()

    # 2. Method DB: Plan composition
    print("📐 Planning pipeline...")
    composition = await system.method_db.suggest_method_composition(
        task=task,
        methods=methods
    )

    print("Planned pipeline:")
    for step in composition['pipeline']:
        print(f"  {step['step']}. {step['method_id']}")
    print()

    # 3. Hybrid execution
    print("⚙️  Executing hybrid pipeline...")

    results = []

    for step in composition['pipeline']:
        method_id = step['method_id']
        method = next(m for m in methods if m['method']['id'] == method_id)

        print(f"Step {step['step']}: {method['method']['name']}...")

        # Get input
        step_input = results[-1]['result'] if results else task

        # Choose execution: local or remote
        if system.can_execute_locally(method):
            print("  → Executing locally")
            result = await system.execute_locally(method, step_input)
        else:
            print("  → Executing via External Service")
            result = await system.execute_via_service(method, step_input)

        results.append({
            'step': step['step'],
            'method': method_id,
            'result': result,
            'execution': 'local' if system.can_execute_locally(method) else 'remote'
        })

        print(f"  ✓ Completed in {result['duration_ms']}ms")
        print()

    # 4. Return final result
    print("✅ Task completed!")
    print()
    print("Summary:")
    print(f"  Total steps: {len(results)}")
    print(f"  Local executions: {sum(1 for r in results if r['execution'] == 'local')}")
    print(f"  Remote executions: {sum(1 for r in results if r['execution'] == 'remote')}")
    print(f"  Total duration: {sum(r['result']['duration_ms'] for r in results)}ms")
    print()
    print("Final result:")
    print(results[-1]['result']['output'][:500] + "...")

if __name__ == '__main__':
    asyncio.run(main())

# Output:
# 🎯 Task: I have a dataset of 10,000 customer reviews...
#
# 🔍 Searching Method DB for relevant methods...
# Found 10 relevant methods:
#   ✓ Text Preprocessor (score: 0.92)
#   ✓ Sentiment Analyzer (score: 0.89)
#   ✓ Topic Extractor (score: 0.87)
#   ✓ Trend Analyzer (score: 0.84)
#   ✓ Report Generator (score: 0.81)
#
# 📐 Planning pipeline...
# Planned pipeline:
#   1. text-preprocessor
#   2. sentiment-analyzer
#   3. topic-extractor
#   4. trend-analyzer
#   5. report-generator
#   6. visualization-creator
#
# ⚙️  Executing hybrid pipeline...
# Step 1: Text Preprocessor...
#   → Executing via External Service
#   ✓ Completed in 2341ms
#
# Step 2: Sentiment Analyzer...
#   → Executing via External Service
#   ✓ Completed in 5678ms
#
# Step 3: Topic Extractor...
#   → Executing locally
#   ✓ Completed in 1234ms
#
# [...]
#
# ✅ Task completed!
#
# Summary:
#   Total steps: 6
#   Local executions: 2
#   Remote executions: 4
#   Total duration: 15432ms
```

---

**Документ создан:** 2026-01-28
**Версия:** 1.0 Complete
**Охват:** 2 варианта + гибридный подход
**Страниц содержания:** ~150

## Ключевые выводы

1. **Вариант 1 (External Service)** - отличный для enterprise и monetization
2. **Вариант 2 (Method DB / Pseudo-RAG)** - революционный для AI-native workflows
3. **Гибридный подход** - best of both worlds, рекомендуется для production

Оба варианта жизнеспособны и могут сосуществовать! 🚀

