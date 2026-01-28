# Детальный каталог Claude Skills: Skills #9-18

## УРОВЕНЬ 1 — БАЗОВЫЕ SKILLS (продолжение)

### КАТЕГОРИЯ 1.2: ТЕКСТОВАЯ ОБРАБОТКА (продолжение)

---

## Skill #9: Find & Replace Wizard
**Уровень сложности:** 🟡 Средний  
**Приоритет реализации:** 🟡 Средний  
**Категория:** Текстовая обработка

### Описание
Многофайловый поиск и замена с использованием естественного языка вместо regex. Понимает контекст и может делать умные замены с учётом смысла.

### Проблема которую решает
- Нужно заменить текст в сотнях файлов
- Regex слишком сложен для обычных пользователей
- Простой Find/Replace меняет слишком много (или слишком мало)
- Нужно заменить с учётом контекста

### Существующие решения и их ограничения

**Grep + sed (Linux/Mac):**
```bash
# Найти все файлы с "oldname" и заменить на "newname"
grep -rl "oldname" . | xargs sed -i 's/oldname/newname/g'
```
❌ Проблемы:
- Нужно знать синтаксис grep и sed
- Трудно предварительно просмотреть изменения
- Легко сломать файлы неправильным regex
- Не понимает контекст

**VS Code Multi-file Replace:**
![Find in Files dialog]
```
Find: old_function_name
Replace: new_function_name
Files to include: src/**/*.js
```
✅ Хорошо:
- Визуальный интерфейс
- Preview изменений
- Regex support

❌ Проблемы:
- Ограничен только текстовыми файлами, открытыми в VS Code
- Regex остаётся сложным
- Нет контекстного понимания

**PowerGREP (Windows, $159):**
✅ Мощный инструмент с GUI
✅ Preview и backup
❌ Дорогой
❌ Всё равно нужно знать regex

**Python script (программистский подход):**
```python
import os
import re

for root, dirs, files in os.walk('.'):
    for file in files:
        if file.endswith('.py'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            content = content.replace('old', 'new')
            with open(filepath, 'w') as f:
                f.write(content)
```
❌ Нужны навыки программирования
❌ Нет preview
❌ Опасно (легко сломать файлы)

### Как Claude улучшает это

**Естественный язык вместо regex:**

**Традиционный подход:**
```regex
Найти: \b(\d{3})-(\d{3})-(\d{4})\b
Заменить: +1-$1-$2-$3
```
Что это делает? Нужно понимать regex.

**Claude подход:**
```
Команда: "Найди все американские номера телефонов и добавь +1 в начало"

Claude понимает:
- Паттерн: XXX-XXX-XXXX
- Действие: добавить префикс +1
- Применяет к: всем совпадениям

Результат:
415-555-0123 → +1-415-555-0123
202-555-7890 → +1-202-555-7890
```

**Контекстная замена:**

**Пример задачи:**
```
Заменить "Apple" на "Orange", но:
- Не в названиях компаний (Apple Inc.)
- Не в названиях продуктов (Apple iPhone)
- Только когда это фрукт
```

**Традиционный regex:** Практически невозможно написать точное правило

**Claude:**
```
Команда: "Замени слово 'Apple' на 'Orange' только когда речь о фруктах"

Claude анализирует контекст каждого вхождения:

"I like to eat an apple." → "I like to eat an orange." ✓
"Apple Inc. released a new iPhone." → Без изменений ✓
"An apple a day keeps the doctor away." → "An orange a day..." ✓
"The Apple Store is open." → Без изменений ✓
```

### Конкретные Use Cases

**Use Case 1: Миграция кодовой базы**
```
Ситуация: Переименование класса в 50+ файлах

Традиционный подход:
Find: OldClassName
Replace: NewClassName
Проблема: Может заменить в комментариях, строках, где не нужно

Claude подход:
Команда: "Переименуй класс OldClassName в NewClassName во всех .java файлах,
         но сохрани старое имя в комментариях для истории"

Claude:
public class OldClassName { 
  → public class NewClassName {

// Using OldClassName pattern
  → // Using OldClassName pattern (без изменений)

"OldClassName config"
  → "NewClassName config" (в строках тоже меняет)

git commit message: "Refactored OldClassName"
  → Без изменений (git history сохраняется)
```

**Use Case 2: Обновление контактной информации**
```
Ситуация: Компания сменила номер телефона, нужно обновить везде

Старый: +1-415-555-0100
Новый: +1-415-555-9999

Проблема: Номер указан в разных форматах:
- 415-555-0100
- (415) 555-0100
- +1.415.555.0100
- 415.555.0100
- 4155550100

Claude команда: "Замени все вхождения старого номера офиса на новый"

Claude находит все варианты форматов:
415-555-0100 → 415-555-9999
(415) 555-0100 → (415) 555-9999
+1.415.555.0100 → +1.415.555.9999
...

Сохраняет формат оригинала!
```

**Use Case 3: Локализация контента**
```
Ситуация: Перевод сайта с USD на EUR

Команда: "Замени все цены в долларах на евро по курсу 1.1"

Claude находит:
$99.99 → €90.90
Price: $149 → Price: €135
USD 1,299.00 → EUR 1,180.91

Учитывает:
- Разные форматы валюты
- Пересчёт по курсу
- Округление до центов
- Не трогает числа, которые не являются ценами
```

**Use Case 4: Рефакторинг переменных**
```
Ситуация: Приведение к code style (camelCase → snake_case)

Файлы: 200+ Python файлов

Команда: "Переименуй все переменные из camelCase в snake_case"

Claude анализирует код:
userName → user_name
emailAddress → email_address
createdAt → created_at

НО сохраняет без изменений:
- Названия классов (класс UserProfile остаётся UserProfile)
- Импорты библиотек (import CamelCaseLib)
- Константы (MAX_VALUE остаётся MAX_VALUE)
- Строки ("Display userName" → "Display user_name")
```

**Use Case 5: Чистка резюме от личной информации**
```
Ситуация: Нужно анонимизировать резюме перед публикацией

Команда: "Замени все личные данные на плейсхолдеры"

Claude находит и заменяет:
- Email: john.doe@email.com → [EMAIL_ADDRESS]
- Телефон: +1-415-555-0123 → [PHONE_NUMBER]
- Адрес: 123 Main St, San Francisco → [ADDRESS]
- LinkedIn: linkedin.com/in/johndoe → [LINKEDIN_PROFILE]

НО сохраняет:
- Навыки: Python, JavaScript (это не личные данные)
- Названия компаний: работал в Google
- Образование: Stanford University
```

### Технические требования

**MCP серверы:**
- `mcp-filesystem` — чтение/запись файлов
- `mcp-git` (опционально) — для безопасной замены с возможностью rollback

**Базовая структура:**
```python
import os
import re
from pathlib import Path

class FindReplaceWizard:
    def __init__(self):
        self.changes = []  # История изменений для preview/undo
    
    def find_and_replace(self, directory, instruction):
        """
        Главная функция поиска и замены
        """
        # 1. Claude парсит инструкцию
        parsed = self.parse_instruction(instruction)
        # parsed = {
        #     'find_pattern': 'phone numbers',
        #     'replace_with': '+1 prefix',
        #     'file_patterns': ['*.txt', '*.md'],
        #     'context_rules': ['not in quotes']
        # }
        
        # 2. Сканируем файлы
        files = self.scan_files(directory, parsed['file_patterns'])
        
        # 3. Для каждого файла находим совпадения
        for filepath in files:
            content = self.read_file(filepath)
            matches = self.find_matches(content, parsed)
            
            # 4. Claude анализирует каждое совпадение
            replacements = []
            for match in matches:
                context = self.get_context(content, match.position)
                should_replace = claude_should_replace(match, context, parsed['context_rules'])
                
                if should_replace:
                    new_value = claude_generate_replacement(match, parsed['replace_with'])
                    replacements.append({
                        'position': match.position,
                        'old': match.text,
                        'new': new_value
                    })
            
            # 5. Сохраняем для preview
            if replacements:
                self.changes.append({
                    'file': filepath,
                    'replacements': replacements
                })
        
        # 6. Preview перед применением
        return self.show_preview()
```

**Интеллектуальный поиск паттернов:**
```python
def find_matches(content, parsed_instruction):
    """
    Находит совпадения на основе инструкции (не regex!)
    """
    
    # Claude определяет что искать
    pattern_type = parsed_instruction['find_pattern']
    
    if pattern_type == 'phone numbers':
        # Claude знает разные форматы телефонов
        patterns = [
            r'\d{3}-\d{3}-\d{4}',  # 415-555-0123
            r'\(\d{3}\)\s*\d{3}-\d{4}',  # (415) 555-0123
            r'\+1[\s.-]?\d{3}[\s.-]?\d{3}[\s.-]?\d{4}',  # +1 415 555 0123
        ]
    elif pattern_type == 'email addresses':
        patterns = [r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b']
    elif pattern_type == 'dates':
        patterns = [
            r'\d{4}-\d{2}-\d{2}',  # 2024-01-27
            r'\d{2}/\d{2}/\d{4}',  # 01/27/2024
            r'\d{2}\.\d{2}\.\d{4}',  # 27.01.2024
        ]
    else:
        # Для кастомных паттернов используем Claude
        patterns = claude_generate_patterns(pattern_type)
    
    matches = []
    for pattern in patterns:
        matches.extend(re.finditer(pattern, content))
    
    return matches
```

**Контекстный анализ:**
```python
def get_context(content, position, window=100):
    """
    Получает контекст вокруг найденного совпадения
    """
    start = max(0, position - window)
    end = min(len(content), position + window)
    
    return {
        'before': content[start:position],
        'match': content[position:position+match_length],
        'after': content[position+match_length:end],
        'line_number': content[:position].count('\n') + 1,
        'file_type': detect_file_type(content)
    }

def claude_should_replace(match, context, rules):
    """
    Claude решает применять ли замену в данном контексте
    """
    prompt = f"""
    Should we replace this match based on the context?
    
    Match: {match.text}
    Context before: ...{context['before'][-50:]}
    Context after: {context['after'][:50]}...
    
    Rules: {rules}
    File type: {context['file_type']}
    
    Return: yes/no with brief reason
    """
    
    decision = claude_api(prompt)
    return "yes" in decision.lower()
```

### Preview интерфейс

```
Find & Replace Wizard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Instruction: "Replace all phone numbers with format +1-XXX-XXX-XXXX"

Scanning: /home/user/documents/
Found: 47 files with potential matches
Analyzed: 156 phone number instances
Suggested replacements: 142 (14 skipped due to context)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PREVIEW OF CHANGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📄 contacts.txt (5 changes)
───────────────────────────────────────────────────
Line 15:
  - Office: 415-555-0100
  + Office: +1-415-555-0100

Line 23:
  - Mobile: (415) 555-0200
  + Mobile: +1-415-555-0200

Line 45:
  - Support: 415.555.0300
  + Support: +1-415-555-0300

[View all 5 changes]

📄 website/index.html (12 changes)
───────────────────────────────────────────────────
Line 156:
  - <a href="tel:4155550100">Call us</a>
  + <a href="tel:+14155550100">Call us</a>

Line 203:
  - Contact: 415-555-0100
  + Contact: +1-415-555-0100

[View all 12 changes]

⚠️  SKIPPED (14 instances)
───────────────────────────────────────────────────
📄 old_logs/2023-archive.txt (8 skipped)
  Reason: Historical data, should preserve original format

📄 test_data.json (6 skipped)
  Reason: Test fixtures, might break tests

[View details]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total files affected: 45
Total changes: 142
Skipped: 14
Backup: Enabled (stored in .findreplace_backup/)

[Apply changes] [Save as script] [Adjust settings] [Cancel]

⚙️  Advanced options:
  ☑ Create backup before replacing
  ☑ Use git for version control (if available)
  ☐ Dry run only (don't modify files)
  ☐ Generate undo script
```

### Безопасность и откат

**1. Automatic backup:**
```python
def apply_changes_safely(changes):
    # Создаём backup перед изменениями
    backup_dir = Path('.findreplace_backup') / datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_dir.mkdir(parents=True)
    
    for change in changes:
        filepath = change['file']
        
        # Backup оригинального файла
        backup_path = backup_dir / Path(filepath).name
        shutil.copy2(filepath, backup_path)
        
        # Применяем изменения
        try:
            apply_replacements(filepath, change['replacements'])
        except Exception as e:
            # Rollback при ошибке
            print(f"Error in {filepath}, rolling back...")
            shutil.copy2(backup_path, filepath)
            raise
    
    # Создаём undo script
    create_undo_script(backup_dir, changes)
```

**2. Git integration:**
```python
def apply_with_git(changes):
    # Проверяем что мы в git репозитории
    if not is_git_repo():
        return apply_changes_safely(changes)
    
    # Создаём feature branch
    branch_name = f"findreplace_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    subprocess.run(['git', 'checkout', '-b', branch_name])
    
    # Применяем изменения
    apply_changes_safely(changes)
    
    # Коммитим
    subprocess.run(['git', 'add', '.'])
    subprocess.run(['git', 'commit', '-m', 'Find & Replace: <description>'])
    
    print(f"""
    Changes applied in branch: {branch_name}
    
    To review: git diff main
    To merge: git checkout main && git merge {branch_name}
    To undo: git checkout main && git branch -D {branch_name}
    """)
```

**3. Undo script generation:**
```bash
#!/bin/bash
# Undo script generated on 2024-01-27 15:30:45
# This script will revert all changes made by Find & Replace

echo "Reverting changes..."

# Restore files from backup
cp .findreplace_backup/20240127_153045/contacts.txt ./contacts.txt
cp .findreplace_backup/20240127_153045/index.html ./website/index.html

# Or apply reverse replacements
sed -i 's/+1-415-555-0100/415-555-0100/g' contacts.txt

echo "Done! Changes reverted."
```

### Расширенные возможности

**1. Интерактивный режим (как git add -p):**
```
📄 contacts.txt
Line 15: Office: 415-555-0100
Replace with: +1-415-555-0100

[y]es, [n]o, [e]dit, [a]ll, [q]uit? y

Line 23: Mobile: (415) 555-0200
Replace with: +1-415-555-0200

[y]es, [n]o, [e]dit, [a]ll, [q]uit? e
Enter new replacement: +1 (415) 555-0200

Updated replacement: +1 (415) 555-0200
Apply? [y/n] y
```

**2. Сохранение как reusable script:**
```python
# После успешного find-replace:
Command: "Save this as a reusable script"

Generated script: update_phone_formats.py
"""
#!/usr/bin/env python3
# Generated by Find & Replace Wizard
# Purpose: Update phone numbers to +1-XXX-XXX-XXXX format

def update_phones(directory):
    # ... generated code based on your replacements
    pass

if __name__ == '__main__':
    update_phones('.')
"""

Usage: ./update_phone_formats.py /path/to/directory
```

**3. Batch operations:**
```
Команда: "Выполни несколько замен:
         1. Обнови телефоны на новый формат
         2. Замени старый email на новый
         3. Обнови адрес компании"

Claude создаёт pipeline:
Step 1: Find & Replace phone numbers
Step 2: Find & Replace emails  
Step 3: Find & Replace addresses

Показывает combined preview всех изменений
```

**4. AI suggestions:**
```
После применения изменений:

Claude: "Я заметил что в этих файлах также есть:
        - Факсы в старом формате (12 instances)
        - Номера мобильных без кода страны (5 instances)
        
        Хотите обновить их тоже? [Yes/No/Show me]"
```

---

## Skill #10: Text Extraction Engine
**Уровень сложности:** 🟡 Средний  
**Приоритет реализации:** 🔴 Высокий  
**Категория:** Текстовая обработка

### Описание
Универсальный движок для извлечения структурированных данных из неструктурированного текста. Вместо regex — понимание смысла.

### Проблема которую решает
- Нужно вытащить email'ы, телефоны, адреса из документов
- Парсинг резюме для HR
- Извлечение данных из email'ов для CRM
- Обработка OCR-результатов (отсканированные документы)
- Извлечение сумм, дат, имён из счетов и договоров

### Существующие решения и их ограничения

**Regex (традиционный подход):**
```python
import re

# Извлечение email
emails = re.findall(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', text)

# Извлечение телефонов
phones = re.findall(r'\+?1?\d{9,15}', text)
```
❌ Проблемы:
- Regex становится очень сложным для сложных паттернов
- Много false positives (находит что не нужно)
- Не понимает контекст
- Нужно писать отдельный regex для каждого паттерна

**Пример сложности regex:**
```python
# Попытка извлечь суммы денег с учётом валют и форматов
money_regex = r'(?:USD|EUR|GBP|[$€£])\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)'
# Это ещё простой случай! А как быть с:
# - "Five thousand dollars"
# - "2.5K USD"
# - "approximately $2,000-$3,000"
```

**Named Entity Recognition (NER) библиотеки:**
```python
import spacy

nlp = spacy.load("en_core_web_sm")
doc = nlp(text)

for ent in doc.ents:
    if ent.label_ == "PERSON":
        print(ent.text)  # Извлекает имена
```
✅ Хорошо для стандартных entity (люди, места, организации)
❌ Ограничения:
- Не извлекает custom data (invoice numbers, reference codes)
- Нужно обучать модель для специфических паттернов
- Плохо работает с неструктурированным текстом (OCR errors)

**Commercial solutions (Rosoka, Textract от AWS):**
✅ Мощные, точные
❌ Дорогие
❌ Не настраиваемые под специфичные нужды
❌ API calls = $$$

### Как Claude улучшает это

**Понимание контекста:**

**Задача:** Извлечь цены из текста

**Традиционный regex:** Найдёт все числа с $ или USD
```python
# Проблема с regex:
text = """
The iPhone costs $999. 
Stock price: AAPL $150.23 per share.
Transfer $500 to account #12345.
"""

# Regex найдёт: $999, $150.23, $500
# Но это разные типы "денег"!
```

**Claude подход:**
```
Команда: "Извлеки цены товаров (не акции, не переводы)"

Claude понимает контекст:
✓ $999 — это цена товара (iPhone)
✗ $150.23 — это цена акции (не товар)
✗ $500 — это сумма перевода (не цена)

Результат: $999
```

**Извлечение с нормализацией:**

**Задача:** Извлечь даты из текста
```
Text: "The meeting is scheduled for next Tuesday, Jan 30th.
       Invoice due by end of February.
       Contract expires in 2 years."

Команда: "Извлеки все даты и приведи к формату YYYY-MM-DD"

Claude:
"next Tuesday" → 2024-01-30 (вычисляет относительно текущей даты)
"Jan 30th" → 2024-01-30
"end of February" → 2024-02-29 (последний день февраля)
"in 2 years" → 2026-01-27 (относительно сегодня)
```

**Традиционный regex не может:**
- Понять "next Tuesday"
- Вычислить "end of February"
- Обработать относительные даты

### Конкретные Use Cases

**Use Case 1: HR — Парсинг резюме**
```
Input: Resume.pdf (конвертирован в текст)

Команда: "Извлеки из резюме: имя, email, телефон, навыки, 
         опыт работы (компания, должность, даты)"

Claude анализирует:

Name: John Doe
Email: john.doe@email.com
Phone: +1-415-555-0123

Skills:
- Python (5 years)
- JavaScript (3 years)
- SQL (4 years)
- AWS (2 years)

Work Experience:
1. Google - Senior Software Engineer (2020-2024)
   - Led team of 5 engineers
   - Developed cloud infrastructure
   
2. Startup Inc - Software Engineer (2018-2020)
   - Built e-commerce platform
   - Technologies: React, Node.js

Education:
- Stanford University - BS Computer Science (2014-2018)

Claude не только извлекает, но и структурирует!
```

**Use Case 2: Финансовый отдел — Парсинг счетов**
```
Input: Invoice.pdf (scan, могут быть OCR ошибки)

Raw OCR text:
"""
lNVOlCE #12345
Date: 27/O1/2O24  <- OCR ошибка: O вместо 0
Amount: $1,5OO.OO  <- OCR ошибка: O вместо 0

Client: Acme Corp
Account: 987-654-321

Items:
Consulting services  $1,2OO
Travel expenses      $   3OO
---------------------------------
Total:               $1,5OO
"""

Команда: "Извлеки invoice number, date, total amount, client name, 
         исправляя OCR ошибки"

Claude:
Invoice Number: 12345 (исправил lNVOlCE на INVOICE)
Date: 2024-01-27 (исправил 27/O1/2O24, нормализовал формат)
Total Amount: $1,500.00 (исправил $1,5OO.OO)
Client: Acme Corp ✓
Account Number: 987-654-321 ✓

Line Items:
- Consulting services: $1,200.00 (исправил $1,2OO)
- Travel expenses: $300.00 (исправил $   3OO)
```

**Use Case 3: Sales — Извлечение лидов из email'ов**
```
Input: Inbox с 100+ email'ами от потенциальных клиентов

Sample email:
"""
Subject: Interested in your service

Hi,

We're a 50-person company in healthcare sector looking for 
cloud solutions. Our budget is around $50K annually.

Contact me at jane.smith@healthcorp.com or +1-650-555-7890.

Best,
Jane Smith
Director of IT
HealthCorp Inc.
"""

Команда: "Из всех emails извлеки: имя, компанию, позицию, отрасль, 
         бюджет, контакты, уровень интереса"

Claude извлекает structured data:
{
  "name": "Jane Smith",
  "company": "HealthCorp Inc.",
  "position": "Director of IT",
  "industry": "Healthcare",
  "company_size": "50 employees",
  "budget": "$50,000/year",
  "email": "jane.smith@healthcorp.com",
  "phone": "+1-650-555-7890",
  "interest_level": "High",  <- Claude анализирует тон письма
  "needs": ["cloud solutions"],
  "decision_maker": true  <- Director-level = decision maker
}

Можно сразу экспортировать в CRM!
```

**Use Case 4: Legal — Извлечение ключевых условий из договоров**
```
Input: 50-page contract.pdf

Команда: "Извлеки ключевые условия: стороны, сумма, срок действия, 
         условия расторжения, штрафы"

Claude сканирует весь документ:

Parties:
- Party A: Acme Corporation (Seller)
- Party B: ClientCorp LLC (Buyer)

Contract Value: $2,500,000
Payment Terms: 30% upfront, 70% upon delivery

Effective Date: January 15, 2024
Expiration Date: January 15, 2027 (3 years)

Termination Clauses:
1. Either party may terminate with 90 days written notice
2. Immediate termination for breach of confidentiality
3. Termination for cause with 30 days cure period

Penalties:
- Late payment: 2% per month
- Early termination by Buyer: 20% of remaining contract value
- Non-delivery: $10,000 per week delay

Governing Law: State of California
```

**Use Case 5: E-commerce — Извлечение продуктов из описаний**
```
Input: Supplier catalog (unstructured text)

Text:
"""
We offer premium laptops:
- MacBook Pro 16" M3 chip, 32GB RAM, 1TB SSD for $2,999
- Dell XPS 15 Intel i7, 16GB, 512GB starting at $1,799
- ThinkPad X1 Carbon with i5 processor around $1,450

All include 1 year warranty. Bulk discounts available 
for orders over 10 units (10% off).
"""

Команда: "Извлеки список продуктов со всеми характеристиками и ценами"

Claude:
[
  {
    "product": "MacBook Pro 16\"",
    "specs": {
      "processor": "M3 chip",
      "ram": "32GB",
      "storage": "1TB SSD"
    },
    "price": 2999.00,
    "currency": "USD"
  },
  {
    "product": "Dell XPS 15",
    "specs": {
      "processor": "Intel i7",
      "ram": "16GB",
      "storage": "512GB"
    },
    "price": 1799.00,
    "price_type": "starting at",
    "currency": "USD"
  },
  {
    "product": "ThinkPad X1 Carbon",
    "specs": {
      "processor": "Intel i5"
    },
    "price": 1450.00,
    "price_type": "approximate",
    "currency": "USD"
  }
]

Additional Info:
- Warranty: 1 year (all products)
- Bulk Discount: 10% for 10+ units
```

### Технические требования

**MCP серверы:**
- `mcp-filesystem` — чтение файлов
- `mcp-document-readers` — PDF, DOCX, images (OCR)

**Базовая архитектура:**
```python
class TextExtractionEngine:
    def __init__(self):
        # Pre-defined extractors для common patterns
        self.extractors = {
            'email': EmailExtractor(),
            'phone': PhoneExtractor(),
            'date': DateExtractor(),
            'money': MoneyExtractor(),
            'address': AddressExtractor(),
        }
    
    def extract(self, text, instruction):
        """
        Main extraction function
        """
        # Claude парсит инструкцию
        extraction_plan = claude_parse_instruction(instruction)
        # plan = {
        #     'entities': ['email', 'phone', 'dates'],
        #     'custom_fields': ['invoice_number', 'client_name'],
        #     'output_format': 'structured_json',
        #     'normalization': True,
        #     'ocr_correction': True
        # }
        
        # OCR correction если нужно
        if extraction_plan['ocr_correction']:
            text = self.correct_ocr_errors(text)
        
        # Извлекаем standard entities
        results = {}
        for entity_type in extraction_plan['entities']:
            if entity_type in self.extractors:
                results[entity_type] = self.extractors[entity_type].extract(text)
            else:
                # Custom extraction через Claude
                results[entity_type] = claude_extract(text, entity_type)
        
        # Custom fields extraction
        for field in extraction_plan['custom_fields']:
            results[field] = claude_extract_custom(text, field)
        
        # Нормализация если нужна
        if extraction_plan['normalization']:
            results = self.normalize_results(results)
        
        return results
```

**OCR error correction:**
```python
def correct_ocr_errors(text):
    """
    Исправляет типичные OCR ошибки
    """
    # Типичные замены
    corrections = {
        'O': '0',  # O вместо 0 в числах
        'l': '1',  # l вместо 1 в числах
        '|': '1',
        'S': '5',  # в некоторых контекстах
    }
    
    # Claude делает умную коррекцию
    # Не просто replace, а с учётом контекста
    
    prompt = f"""
    This text likely has OCR errors. Fix obvious mistakes:
    - O → 0 in numbers
    - l → 1 in numbers
    - Malformed words
    
    Text: {text}
    
    Return corrected text.
    """
    
    return claude_api(prompt)
```

**Smart extractors:**
```python
class MoneyExtractor:
    def extract(self, text):
        """
        Извлекает денежные суммы с контекстом
        """
        # Базовые паттерны
        patterns = [
            r'[$€£¥]\s*(\d+(?:,\d{3})*(?:\.\d{2})?)',  # $1,000.00
            r'(\d+(?:,\d{3})*(?:\.\d{2})?)\s*(USD|EUR|GBP)',  # 1000.00 USD
            r'(\d+(?:,\d{3})*(?:\.\d{2})?)\s*dollars?',  # 1000 dollars
        ]
        
        matches = []
        for pattern in patterns:
            for match in re.finditer(pattern, text, re.IGNORECASE):
                # Получаем контекст
                context = self.get_context(text, match.start(), match.end())
                
                # Claude анализирует: это цена товара? сумма перевода? зарплата?
                money_type = claude_classify_money_context(match.group(), context)
                
                matches.append({
                    'amount': self.parse_amount(match.group()),
                    'currency': self.extract_currency(match.group()),
                    'type': money_type,
                    'context': context
                })
        
        return matches

class DateExtractor:
    def extract(self, text):
        """
        Извлекает даты (включая относительные)
        """
        # Absolute dates
        absolute_patterns = [
            r'\d{4}-\d{2}-\d{2}',  # 2024-01-27
            r'\d{2}/\d{2}/\d{4}',  # 01/27/2024
            r'\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{1,2},?\s+\d{4}',  # January 27, 2024
        ]
        
        # Relative dates
        relative_patterns = [
            r'next (Monday|Tuesday|Wednesday|...)',
            r'in (\d+) (days?|weeks?|months?|years?)',
            r'(yesterday|today|tomorrow)',
            r'end of (this )?(month|quarter|year)',
        ]
        
        dates = []
        
        # Extract absolute
        for pattern in absolute_patterns:
            for match in re.finditer(pattern, text):
                dates.append({
                    'text': match.group(),
                    'normalized': self.normalize_date(match.group()),
                    'type': 'absolute'
                })
        
        # Extract relative (нужен Claude для вычисления)
        for pattern in relative_patterns:
            for match in re.finditer(pattern, text):
                absolute_date = claude_resolve_relative_date(match.group())
                dates.append({
                    'text': match.group(),
                    'normalized': absolute_date,
                    'type': 'relative'
                })
        
        return dates
```

### Пример интерфейса

```
Text Extraction Engine
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Input: resume.pdf (uploaded)

Quick extractions:
[Emails] [Phone Numbers] [Dates] [Addresses] [Custom...]

Or describe what to extract:
┌────────────────────────────────────────────────┐
│ Extract name, skills, work experience          │
│                                                │
└────────────────────────────────────────────────┘
                                        [Extract]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RESULTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Extraction complete (2.3 seconds)

📋 Structured Data:
{
  "name": "John Doe",
  "email": "john.doe@email.com",
  "phone": "+1-415-555-0123",
  "skills": [
    {"name": "Python", "years": 5},
    {"name": "JavaScript", "years": 3}
  ],
  "work_experience": [
    {
      "company": "Google",
      "position": "Senior Software Engineer",
      "start_date": "2020-01-01",
      "end_date": "2024-01-01",
      "duration_years": 4
    }
  ]
}

[Export as JSON] [Export to CSV] [Send to CRM] [Copy]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Confidence scores:
Name: 100% ████████████████████████████████
Email: 100% ████████████████████████████████
Phone: 95% ██████████████████████████████░░
Skills: 90% ████████████████████████████░░░░
```

### Batch processing

```python
def extract_from_multiple_files(files, instruction):
    """
    Извлечение из нескольких файлов
    """
    results = []
    
    for filepath in files:
        # Read file
        if filepath.endswith('.pdf'):
            text = pdf_to_text(filepath)
        elif filepath.endswith('.docx'):
            text = docx_to_text(filepath)
        elif filepath.endswith(('.jpg', '.png')):
            text = ocr_image(filepath)
        else:
            text = open(filepath).read()
        
        # Extract
        extracted = extract(text, instruction)
        results.append({
            'file': filepath,
            'data': extracted
        })
    
    return results

# Usage
files = glob.glob('resumes/*.pdf')
instruction = "Extract name, email, phone, skills, experience"

results = extract_from_multiple_files(files, instruction)

# Export to CSV
df = pd.DataFrame([r['data'] for r in results])
df.to_csv('extracted_resumes.csv')
```

### Расширенные возможности

**1. Template-based extraction:**
```
Сохраняем extraction как template:

Template name: "Invoice Extraction"
Fields:
- invoice_number
- date
- amount
- client_name
- line_items[]

Reuse:
command: "Extract using Invoice template"
→ Применяет к новому документу
```

**2. Validation rules:**
```
instruction: "Extract email and validate it"

Validation:
- Format: xxx@xxx.xxx
- Domain exists (DNS check)
- Not a disposable email (temporary-mail.net, etc.)

Result:
✓ john@company.com (valid, MX records found)
✗ invalid@temp-mail.com (disposable email service)
⚠ john@noexist.com (domain not found)
```

**3. Confidence scoring:**
```
Extracted data with confidence:

Name: "John Doe" (confidence: 100%)
  ✓ Found in header
  ✓ Capitalized properly
  ✓ Common name pattern

Email: "john.doe@email.com" (confidence: 100%)
  ✓ Valid format
  ✓ MX records exist

Phone: "4155550123" (confidence: 75%)
  ⚠ Missing country code
  ⚠ Could be confused with account number
  ℹ Suggest: +1-415-555-0123

Salary: "$120K" (confidence: 60%)
  ⚠ Ambiguous: could be current or expected
  ℹ Context: near "currently earning"
  ℹ Interpreted as: current salary
```

---

### КАТЕГОРИЯ 1.3: БАЗОВОЕ ФОРМАТИРОВАНИЕ

## Skill #11: Markdown Formatter
**Уровень сложности:** 🟢 Базовый  
**Приоритет реализации:** 🟡 Средний  
**Категория:** Базовое форматирование

### Описание
Конвертация между форматами разметки (Markdown, HTML, RTF, plain text) с сохранением семантики и умным форматированием.

### Проблема которую решает
- Нужно конвертировать Markdown → HTML для сайта
- Текст из Word нужен в Markdown для GitHub
- HTML email нужен в plain text
- Очистка от лишнего форматирования при copy-paste

### Существующие решения и их ограничения

**Pandoc (командная строка):**
```bash
pandoc document.md -o document.html
pandoc document.docx -o document.md
```
✅ Мощный, поддерживает множество форматов
❌ Командная строка (не для всех)
❌ Нужно помнить синтаксис
❌ Не всегда правильно обрабатывает форматирование

**Online converters (markdowntohtml.com и т.д.):**
✅ Простые в использовании
❌ Нужен интернет
❌ Загрузка файлов на сторонние серверы (privacy)
❌ Базовая конвертация без умного форматирования

**VS Code / Typora / Marked:**
✅ WYSIWYG editors для Markdown
❌ Только для Markdown
❌ Не умные преобразования

### Как Claude улучшает это

**Семантическое форматирование:**

**Задача:** Преобразовать неструктурированный текст в Markdown

**Input:**
```
Getting Started with Python

Python is a programming language. Here are the basics:

Variables: You can store data in variables like x = 5

Functions: Define reusable code with def my_function():

Loops: Repeat code with for i in range(10):
```

**Традиционный конвертер:** Просто добавит # перед заголовком

**Claude:**
```markdown
# Getting Started with Python

Python is a programming language. Here are the basics:

## Core Concepts

### Variables
You can store data in variables:
```python
x = 5
```

### Functions
Define reusable code:
```python
def my_function():
    pass
```

### Loops
Repeat code:
```python
for i in range(10):
    pass
```
```

Claude:
- Распознал структуру (заголовки разных уровней)
- Обернул код в code blocks с правильным языком
- Сделал правильную иерархию (#, ##, ###)

**Умная очистка форматирования:**

**Input:** Скопировано из Word
```html
<p style="margin: 0px; font-family: Times New Roman; font-size: 12pt;">
  <span style="font-weight: bold; color: #FF0000;">Important:</span>
  This is <em style="font-style: italic;">important</em> text.
</p>
```

**Команда:** "Очисти это для Markdown, сохранив только важное форматирование"

**Claude:**
```markdown
**Important:** This is *important* text.
```

Убрал:
- Inline styles
- Font specifications
- Margin/spacing
- HTML tags

Сохранил:
- Bold (**Important:**)
- Italic (*important*)

### Конкретные Use Cases

**Use Case 1: Документация из Word в GitHub**
```
Ситуация: Техническая документация написана в Word, 
         нужна на GitHub в Markdown

Input: technical_guide.docx
- Заголовки разных уровней
- Код примеры
- Таблицы
- Изображения
- Нумерованные списки

Команда: "Конвертируй в GitHub-flavored Markdown"

Claude:
1. Конвертирует заголовки (Heading 1 → #, Heading 2 → ##)
2. Code примеры оборачивает в ```language
3. Таблицы конвертирует в Markdown tables
4. Изображения экспортирует отдельно и вставляет ![alt](path)
5. Списки форматирует правильно

Output: technical_guide.md + images/
```

**Use Case 2: Блог пост: Markdown → HTML**
```
Input: blog_post.md

Команда: "Конвертируй в HTML для блога, добавь meta tags и SEO"

Claude генерирует:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Getting Started with Python - My Blog</title>
    
    <!-- SEO meta tags -->
    <meta name="description" content="Learn Python basics...">
    <meta name="keywords" content="Python, programming, tutorial">
    
    <!-- Open Graph для social media -->
    <meta property="og:title" content="Getting Started with Python">
    <meta property="og:description" content="Learn Python basics...">
    
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <article>
        <h1>Getting Started with Python</h1>
        <p>Python is a programming language...</p>
        <!-- ... -->
    </article>
</body>
</html>
```

**Use Case 3: Email: HTML → Plain Text**
```
Input: Marketing email (HTML)

Команда: "Конвертируй HTML email в plain text, сохрани читаемость"

HTML:
<h1 style="color: blue">Special Offer!</h1>
<p>Get <strong>50% off</strong> on all products.</p>
<ul>
  <li>Product A</li>
  <li>Product B</li>
</ul>
<a href="http://example.com">Shop Now</a>

Claude Plain Text:
━━━━━━━━━━━━━━━━━━━━━━━
SPECIAL OFFER!
━━━━━━━━━━━━━━━━━━━━━━━

Get **50% OFF** on all products.

Products:
• Product A
• Product B

Shop Now: http://example.com

Claude:
- Добавил ASCII borders для заголовка
- Сохранил emphasis (**50% OFF**)
- Конвертировал <ul> в bullet list
- Извлёк URL из ссылки
```

**Use Case 4: Confluence → Markdown**
```
Ситуация: Миграция wiki с Confluence на GitHub Wiki

Input: Confluence страницы (экспорт в HTML)

Команда: "Конвертируй Confluence HTML в GitHub Markdown, 
         сохрани все макросы как code blocks"

Claude обрабатывает:
- Confluence tables → Markdown tables
- {code:python} макросы → ```python code blocks
- {info} макросы → > Note: blockquotes
- Page links → [Page Title](page-title.md)
- Attachments → Downloads + links
```

### Технические требования

**MCP серверы:**
- `mcp-filesystem` — чтение/запись файлов
- `mcp-document-readers` — для Word, PDF

**Python библиотеки:**
```python
import markdown  # MD → HTML
from bs4 import BeautifulSoup  # HTML parsing
import pypandoc  # Universal converter
from markdownify import markdownify as md  # HTML → MD
```

**Базовая архитектура:**
```python
class MarkdownFormatter:
    def convert(self, input_file, output_format, options=None):
        """
        Универсальная конвертация
        """
        # Определяем входной формат
        input_format = self.detect_format(input_file)
        
        # Читаем контент
        if input_format == 'docx':
            content = self.read_docx(input_file)
        elif input_format == 'html':
            content = self.read_html(input_file)
        elif input_format == 'md':
            content = self.read_markdown(input_file)
        
        # Claude анализирует структуру
        structure = claude_analyze_structure(content)
        
        # Конвертируем с учётом структуры
        if output_format == 'md':
            output = self.to_markdown(content, structure, options)
        elif output_format == 'html':
            output = self.to_html(content, structure, options)
        elif output_format == 'txt':
            output = self.to_plaintext(content, structure, options)
        
        return output
    
    def to_markdown(self, content, structure, options):
        """
        Конвертация в Markdown
        """
        md_output = []
        
        for element in structure['elements']:
            if element['type'] == 'heading':
                # Heading 1 → #, Heading 2 → ##, etc.
                level = '#' * element['level']
                md_output.append(f"{level} {element['text']}\n")
            
            elif element['type'] == 'paragraph':
                # Обрабатываем inline formatting
                text = self.process_inline_formatting(element['text'])
                md_output.append(f"{text}\n")
            
            elif element['type'] == 'code':
                # Code block
                language = element.get('language', '')
                md_output.append(f"```{language}\n{element['code']}\n```\n")
            
            elif element['type'] == 'list':
                # Bullet or numbered list
                for item in element['items']:
                    prefix = '-' if element['style'] == 'bullet' else f"{item['number']}."
                    md_output.append(f"{prefix} {item['text']}\n")
            
            elif element['type'] == 'table':
                # Markdown table
                md_output.append(self.format_table_markdown(element['data']))
        
        return '\n'.join(md_output)
```

**Smart inline formatting:**
```python
def process_inline_formatting(text, format='md'):
    """
    Обрабатывает bold, italic, code, links
    """
    # Claude анализирует какие части текста форматированы
    formatted = claude_identify_formatting(text)
    
    result = text
    for item in formatted:
        if item['type'] == 'bold':
            if format == 'md':
                result = result.replace(item['text'], f"**{item['text']}**")
            elif format == 'html':
                result = result.replace(item['text'], f"<strong>{item['text']}</strong>")
        
        elif item['type'] == 'italic':
            if format == 'md':
                result = result.replace(item['text'], f"*{item['text']}*")
            elif format == 'html':
                result = result.replace(item['text'], f"<em>{item['text']}</em>")
        
        elif item['type'] == 'code':
            if format == 'md':
                result = result.replace(item['text'], f"`{item['text']}`")
            elif format == 'html':
                result = result.replace(item['text'], f"<code>{item['text']}</code>")
    
    return result
```

### Пример интерфейса

```
Markdown Formatter
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Input: [Choose file...] technical_guide.docx

Convert to:
  ( ) Markdown (.md)
  (•) HTML (.html)
  ( ) Plain Text (.txt)
  ( ) Rich Text Format (.rtf)

Options:
  ☑ Preserve code blocks
  ☑ Generate table of contents
  ☑ Add syntax highlighting (HTML only)
  ☑ Optimize for GitHub
  ☐ Include meta tags (HTML only)
  ☐ Export images separately

Preview:
┌────────────────────────────────────────────────┐
│ # Technical Guide                              │
│                                                │
│ ## Introduction                                │
│ This guide covers...                           │
│                                                │
│ ```python                                      │
│ def example():                                 │
│     pass                                       │
│ ```                                            │
└────────────────────────────────────────────────┘

[Convert] [Save settings] [Batch convert...]
```

### Расширенные возможности

**1. Batch conversion:**
```bash
Команда: "Конвертируй все .docx файлы в папке docs/ в Markdown"

Claude:
Processing...
✓ introduction.docx → introduction.md
✓ chapter1.docx → chapter1.md
✓ chapter2.docx → chapter2.md
✓ appendix.docx → appendix.md

Created:
  docs_markdown/
    ├── introduction.md
    ├── chapter1.md
    ├── chapter2.md
    ├── appendix.md
    └── images/  (extracted images)
```

**2. Template-based conversion:**
```
Создаём template для blog posts:

Template: blog_post_template.html
- Includes header, footer, navigation
- SEO meta tags
- Structured data markup
- Social media cards

Usage:
command: "Convert blog_post.md using blog_post_template"

Claude вставляет MD content в template:
<!DOCTYPE html>
<html>
  <head>
    <!-- Meta tags from template -->
  </head>
  <body>
    <header><!-- From template --></header>
    <article>
      <!-- blog_post.md content here -->
    </article>
    <footer><!-- From template --></footer>
  </body>
</html>
```

**3. Custom formatting rules:**
```yaml
# formatting_rules.yaml

markdown:
  headings:
    style: 'atx'  # Use # instead of underlines
    add_ids: true  # Add {#heading-id} for anchors
  
  code_blocks:
    fence_style: 'backtick'  # ``` instead of ~~~
    show_language: always
    line_numbers: true
  
  lists:
    bullet_char: '-'  # Use - instead of *
    indent_size: 2
  
  links:
    style: 'inline'  # [text](url) instead of [text][ref]
    
  tables:
    alignment: 'auto'  # Align columns automatically
    
html:
  semantic_tags: true  # Use <article>, <section>, <nav>
  minify: false
  pretty_print: true
  indent: 2
```

---

*Продолжение следует с Skill #12: Table Beautifier...*

*Хотите чтобы я продолжил с остальными skills (#12-#18)?*
