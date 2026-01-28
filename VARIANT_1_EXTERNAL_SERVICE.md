# Вариант 1: Skills как внешний сервис

**Дата:** 2026-01-28
**Тип:** Архитектурное решение - External Service
**Статус:** ✅ Полная документация
**Размер:** 1,267 строк

---

## 📋 Навигация

- **← Обзор всех вариантов:** [ARCHITECTURE_VARIANTS_OVERVIEW.md](ARCHITECTURE_VARIANTS_OVERVIEW.md)
- **→ Вариант 2:** [VARIANT_2_METHOD_DATABASE.md](VARIANT_2_METHOD_DATABASE.md)
- **→ Сравнение:** [COMPARISON_AND_HYBRID.md](COMPARISON_AND_HYBRID.md)

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

