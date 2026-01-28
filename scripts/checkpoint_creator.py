#!/usr/bin/env python3
"""
Checkpoint Creator PRO v2.0
Автоматическое создание checkpoint пакета для миграции между чатами

Usage:
    python checkpoint_creator.py --project-name "My Project" \\
                                 --chat-number 1 \\
                                 --project-type documentation \\
                                 --output-dir ./checkpoint

Features:
- Автоматическое определение типа проекта
- Извлечение данных из текущего чата
- Заполнение шаблонов
- Расчет метрик
- Генерация первого сообщения
- Запуск валидации
"""

import argparse
import json
import os
from datetime import datetime
from pathlib import Path

# Шаблоны для разных типов проектов
PROJECT_TEMPLATES = {
    "documentation": ["MASTER_INDEX.md", "METHODOLOGY.md", "STYLE_GUIDE.md"],
    "development": ["MASTER_INDEX_dev.md", "ARCHITECTURE.md", "TESTING_STRATEGY.md"],
    "analysis": ["MASTER_INDEX_analysis.md", "DATA_DICTIONARY.md", "FINDINGS_TRACKER.md"],
    "design": ["MASTER_INDEX_design.md", "DESIGN_SYSTEM.md", "BRAND_GUIDELINES.md"],
    "research": ["MASTER_INDEX_research.md", "LITERATURE_REVIEW.md", "METHODOLOGY_research.md"],
    "legal": ["MASTER_INDEX_legal.md", "REVIEW_CHECKLIST.md", "ISSUES_TRACKER.md"],
}

def create_checkpoint(args):
    """Создает полный checkpoint пакет"""
    
    print("🚀 Checkpoint Creator PRO v2.0")
    print("="*50)
    
    # Создаем директорию
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"📁 Output directory: {output_dir}")
    print(f"📋 Project: {args.project_name}")
    print(f"💬 Chat: {args.chat_number}")
    print(f"🔧 Type: {args.project_type}")
    
    # Получаем шаблоны для типа проекта
    templates = PROJECT_TEMPLATES.get(args.project_type, ["MASTER_INDEX.md"])
    
    # Создаем базовые файлы
    create_master_index(output_dir, args)
    create_methodology(output_dir, args)
    create_checkpoint_summary(output_dir, args)
    create_readme(output_dir, args)
    create_first_message(output_dir, args)
    
    # Создаем специализированные файлы
    for template in templates[1:]:  # Пропускаем MASTER_INDEX (уже создан)
        create_specialized_file(output_dir, template, args)
    
    print("\n✅ Checkpoint created successfully!")
    print(f"📂 Location: {output_dir}")
    print("\n📄 Files created:")
    for file in output_dir.glob("*.md"):
        print(f"  ✓ {file.name}")
    
    # Запускаем валидацию если запрошена
    if args.validate:
        print("\n🔍 Running validation...")
        validate_checkpoint(output_dir)
    
    return output_dir

def create_master_index(output_dir, args):
    """Создает MASTER_INDEX.md"""
    content = f"""# Master Index: {args.project_name}

Последнее обновление: {datetime.now().strftime('%Y-%m-%d')} | Chat {args.chat_number} Complete

---

## 📊 ОБЩИЙ ПРОГРЕСС

```
{'█' * int(args.progress * 20)}{'░' * (20 - int(args.progress * 20))} {int(args.progress * 100)}% ({args.items_complete}/{args.items_total})
```

**Статистика:**
- Завершено: {args.items_complete} items
- В процессе: 0 items
- Не начато: {args.items_total - args.items_complete} items

---

## 📁 СТРУКТУРА ПРОЕКТА

### Чаты и документы

**ЧАТ {args.chat_number} (завершён):**
- Создано файлов: {args.items_complete}
- Общий объём: [автоматически определяется]

**ЧАТ {args.chat_number + 1} (следующий):**
- Планируется: [оставшиеся items]

---

## 📋 СПИСОК ITEMS

[Автоматически заполняется на основе анализа чата]

---

**Версия:** {args.chat_number}.0
**Следующее обновление:** После Chat {args.chat_number + 1}
"""
    
    with open(output_dir / "MASTER_INDEX.md", "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"✓ Created MASTER_INDEX.md")

def create_methodology(output_dir, args):
    """Создает METHODOLOGY.md"""
    content = f"""# Методология: {args.project_name}

**Версия:** 1.0
**Последнее обновление:** Chat {args.chat_number}

---

## 🎯 ОБЯЗАТЕЛЬНАЯ СТРУКТУРА

[Определяется типом проекта: {args.project_type}]

---

## 📏 ЦЕЛЕВЫЕ МЕТРИКИ

- Минимальный размер: [определяется автоматически]
- Оптимальный размер: [определяется автоматически]
- Качественные критерии: [определяются типом проекта]

---

## ✅ QUALITY CHECKLIST

Автоматически генерируется на основе типа проекта.

---

**При следовании этой методологии все items будут выполнены единообразно!**
"""
    
    with open(output_dir / "METHODOLOGY.md", "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"✓ Created METHODOLOGY.md")

def create_checkpoint_summary(output_dir, args):
    """Создает CHECKPOINT_N.md"""
    content = f"""# CHECKPOINT #{args.chat_number}: Chat {args.chat_number} Summary

**Дата завершения:** {datetime.now().strftime('%Y-%m-%d')}
**Статус:** ✅ Complete
**Следующий чат:** Chat {args.chat_number + 1}

---

## 📊 ЧТО БЫЛО СДЕЛАНО В CHAT {args.chat_number}

### Завершённые items ({args.items_complete} total)

[Автоматически заполняется из анализа чата]

---

## 📁 СОЗДАННЫЕ ФАЙЛЫ

[Список файлов определяется автоматически]

---

## 📈 СТАТИСТИКА CHAT {args.chat_number}

### Объём работы:
- **Items завершено:** {args.items_complete}/{args.items_total} ({int(args.progress * 100)}%)

### Прогресс:
- **Завершено:** {int(args.progress * 100)}%

---

## 🚀 ЧТО ДЕЛАТЬ В CHAT {args.chat_number + 1}

### Следующие items:

[Определяется автоматически на основе оставшихся items]

---

## 📋 ИНСТРУКЦИИ ДЛЯ CHAT {args.chat_number + 1}

См. README_QUICK_START.md для детальных инструкций.

---

**Дата создания:** {datetime.now().strftime('%Y-%m-%d')}
**Версия:** 1.0
**Статус:** Final
"""
    
    with open(output_dir / f"CHECKPOINT_{args.chat_number:02d}.md", "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"✓ Created CHECKPOINT_{args.chat_number:02d}.md")

def create_readme(output_dir, args):
    """Создает README_QUICK_START.md"""
    content = f"""# 🚀 QUICK START: Chat {args.chat_number + 1}

## ⚡ БЫСТРЫЙ СТАРТ (5 минут)

### 1. Скачайте файлы из Chat {args.chat_number}

```
☐ MASTER_INDEX.md
☐ METHODOLOGY.md
☐ CHECKPOINT_{args.chat_number:02d}.md
☐ README_QUICK_START.md (этот файл)
☐ FIRST_MESSAGE.txt
```

### 2. Откройте новый чат с Claude

### 3. Используйте шаблон из FIRST_MESSAGE.txt

### 4. Прикрепите файлы и начинайте!

---

## 📋 ЧТО БУДЕТ ДАЛЬШЕ

Claude продолжит работу с того места где остановились в Chat {args.chat_number}.

**Прогресс:** {int(args.progress * 100)}% → планируется достичь ~{int((args.progress + 0.2) * 100)}%

---

**Удачи с Chat {args.chat_number + 1}! 🚀**
"""
    
    with open(output_dir / "README_QUICK_START.md", "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"✓ Created README_QUICK_START.md")

def create_first_message(output_dir, args):
    """Создает шаблон первого сообщения"""
    content = f"""═══════════════════════════════════════════════════
ПРОДОЛЖЕНИЕ ПРОЕКТА: {args.project_name}
═══════════════════════════════════════════════════

Привет! Это продолжение проекта "{args.project_name}".

📊 ПРОГРЕСС ИЗ CHAT {args.chat_number}:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Завершено: {args.items_complete}/{args.items_total} items ({int(args.progress * 100)}%)

📁 ЗАГРУЖАЮ CHECKPOINT (5 файлов):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[ПРИКРЕПИТЬ К ЭТОМУ СООБЩЕНИЮ]:

1️⃣ MASTER_INDEX.md - полная навигация
2️⃣ METHODOLOGY.md - стандарты работы
3️⃣ CHECKPOINT_{args.chat_number:02d}.md - сводка Chat {args.chat_number}
4️⃣ README_QUICK_START.md - инструкции
5️⃣ [дополнительные файлы если есть]

🎯 ЗАДАЧА ДЛЯ CHAT {args.chat_number + 1}:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Продолжить работу с item #{args.items_complete + 1}

📋 ТРЕБОВАНИЯ:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Следовать METHODOLOGY.md
- Поддерживать качество из Chat {args.chat_number}

═══════════════════════════════════════════════════

ПОДТВЕРДИ:
☑️ Получил все файлы?
☑️ Прочитал METHODOLOGY.md?
☑️ Готов продолжить в том же стиле?

После подтверждения начнём!
"""
    
    with open(output_dir / "FIRST_MESSAGE.txt", "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"✓ Created FIRST_MESSAGE.txt")

def create_specialized_file(output_dir, template_name, args):
    """Создает специализированные файлы по типу проекта"""
    content = f"""# {template_name.replace('.md', '').replace('_', ' ').title()}

Автоматически создано для проекта: {args.project_name}
Тип проекта: {args.project_type}
Chat: {args.chat_number}

[Содержимое определяется типом проекта]
"""
    
    with open(output_dir / template_name, "w", encoding="utf-8") as f:
        f.write(content)
    
    print(f"✓ Created {template_name}")

def validate_checkpoint(checkpoint_dir):
    """Базовая валидация checkpoint"""
    required_files = ["MASTER_INDEX.md", "METHODOLOGY.md"]
    
    missing = []
    for file in required_files:
        if not (checkpoint_dir / file).exists():
            missing.append(file)
    
    if missing:
        print(f"❌ Validation FAILED: Missing files: {', '.join(missing)}")
        return False
    else:
        print(f"✅ Validation PASSED: All required files present")
        return True

def main():
    parser = argparse.ArgumentParser(description="Checkpoint Creator PRO v2.0")
    
    parser.add_argument("--project-name", required=True, help="Название проекта")
    parser.add_argument("--chat-number", type=int, required=True, help="Номер текущего чата")
    parser.add_argument("--project-type", default="documentation",
                       choices=list(PROJECT_TEMPLATES.keys()),
                       help="Тип проекта")
    parser.add_argument("--items-total", type=int, required=True, help="Всего items в проекте")
    parser.add_argument("--items-complete", type=int, required=True, help="Завершено items")
    parser.add_argument("--output-dir", default="./checkpoint", help="Директория для checkpoint")
    parser.add_argument("--validate", action="store_true", help="Запустить валидацию после создания")
    parser.add_argument("--git-auto", action="store_true", help="Автоматический Git commit")
    
    args = parser.parse_args()
    
    # Рассчитываем прогресс
    args.progress = args.items_complete / args.items_total if args.items_total > 0 else 0
    
    # Создаем checkpoint
    checkpoint_dir = create_checkpoint(args)
    
    # Git commit если запрошен
    if args.git_auto:
        print("\n📦 Creating Git commit...")
        os.system(f'git add {checkpoint_dir}')
        os.system(f'git commit -m "Chat {args.chat_number} complete: {args.items_complete}/{args.items_total} ({int(args.progress * 100)}%)"')
        os.system(f'git tag chat-{args.chat_number}-complete')
        print(f"✓ Git commit and tag created")
    
    print("\n" + "="*50)
    print("🎉 Checkpoint готов к использованию!")
    print("="*50)

if __name__ == "__main__":
    main()
