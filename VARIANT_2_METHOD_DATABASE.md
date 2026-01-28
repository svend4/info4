# Вариант 2: Skills как база методов (Pseudo-RAG)

**Дата:** 2026-01-28
**Тип:** Архитектурное решение - Method Database
**Статус:** ✅ Полная документация
**Размер:** 1,090 строк

---

## 📋 Навигация

- **← Обзор всех вариантов:** [ARCHITECTURE_VARIANTS_OVERVIEW.md](ARCHITECTURE_VARIANTS_OVERVIEW.md)
- **← Вариант 1:** [VARIANT_1_EXTERNAL_SERVICE.md](VARIANT_1_EXTERNAL_SERVICE.md)
- **→ Сравнение:** [COMPARISON_AND_HYBRID.md](COMPARISON_AND_HYBRID.md)

---

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


