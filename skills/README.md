# Skills Directory

Организованная коллекция из 101 Claude Skills по уровням сложности.

## Структура

```
skills/
├── level-1-basic/         22 skills - Файловые операции, текст, форматирование
├── level-2-intermediate/  11 skills - Документы, презентации, email
├── level-3-advanced/      12 skills - Программирование, дизайн, data
├── level-4-professional/  12 skills - CI/CD, DevOps, системное администрирование
├── special/               15 skills - Миграция чатов, создание skills
└── other/                 29 skills - Дополнительные утилиты
```

## Level 1 - Basic (22 skills)

Базовые операции для повседневной работы:

**Файловые операции:**
- smart-file-organizer.skill
- batch-file-renamer.skill
- duplicate-hunter.skill
- archive-manager.skill
- smart-backup-assistant.skill

**Текстовая обработка:**
- universal-text-transformer.skill
- smart-clipboard-manager.skill
- text-expander-pro.skill
- find-replace-wizard.skill
- text-extraction-engine.skill

**Форматирование:**
- markdown-formatter.skill
- table-beautifier.skill
- code-formatter-universal.skill
- json-yaml-xml-converter.skill
- clean-paste.skill

**Конвертации:**
- unit-converter-pro.skill, unit-converter.skill
- date-time-wizard.skill, date-calculator.skill
- time-zone-converter.skill
- image-format-converter.skill
- currency-converter.skill

## Level 2 - Intermediate (11 skills)

Работа с документами и коммуникацией:

- pdf-master.skill
- excel-automation-expert.skill
- data-entry-automator.skill
- smart-email-drafts.skill
- email-sorter-filter.skill
- email-template-manager.skill
- meeting-scheduler-pro.skill
- powerpoint-designer.skill
- И другие...

## Level 3 - Advanced (12 skills)

Программирование и обработка данных:

- test-generator.skill
- git-workflow-assistant.skill
- web-scraper-pro.skill
- api-integration-helper.skill
- data-validator-pro.skill
- database-query-builder.skill
- И другие...

## Level 4 - Professional (12 skills)

DevOps и системное администрирование:

- docker-helper.skill
- kubernetes-assistant.skill
- infrastructure-as-code.skill
- cicd-pipeline-builder.skill
- log-analyzer.skill
- system-monitor.skill
- security-scanner.skill
- И другие...

## Special Skills (15 skills)

Инструменты для работы с самими skills и миграции чатов:

**Миграция чатов (11 versions):**
- chat-migration-assistant.skill
- chat-migration-ultimate-plus.skill
- chat-migration-quantum-v4.skill
- chat-migration-cosmic-v5.skill
- chat-migration-infinity-v6.skill
- И другие версии...

**Управление skills:**
- skill-creator-assistant.skill
- skill-creator-assistant-extended.skill
- skill-batch-installer.skill

## Использование

1. **Просмотр skill:**
   ```bash
   # Skills это ZIP архивы
   unzip smart-file-organizer.skill -d temp/
   cat temp/SKILL.md
   ```

2. **Установка:**
   - См. основной [SKILLS_INSTALLATION_GUIDE.md](../docs/en/SKILLS_INSTALLATION_GUIDE.md)

3. **Поиск нужного skill:**
   - См. [MASTER_INDEX](../docs/en/00_MASTER_INDEX_Skills_Catalog.md) для полного каталога

## Навигация

- **Главный каталог:** [00_MASTER_INDEX_Skills_Catalog.md](../docs/en/00_MASTER_INDEX_Skills_Catalog.md)
- **Детальное описание:** [claude-skills-detailed-catalog.md](../docs/en/claude-skills-detailed-catalog.md)
- **Руководство (RU):** [КАК_СОЗДАТЬ_СВОЙ_SKILL](../docs/ru/КАК_СОЗДАТЬ_СВОЙ_SKILL_ПОЛНОЕ_РУКОВОДСТВО.md)

## Формат .skill

Каждый `.skill` файл - это ZIP архив со следующей структурой:

```
skill-name.skill (ZIP)
├── SKILL.md              # Основная документация
├── examples/             # Примеры использования
├── assets/               # Ресурсы
└── references/           # Дополнительные материалы
```

---

**Всего skills:** 101
**Последнее обновление:** 2026-01-28
**Версия:** 2.0 (Reorganized)
