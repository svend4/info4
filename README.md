# Коллекция Claude Skills и инструменты миграции контекста (`info4`)

## Назначение проекта

Репозиторий `info4` (**Claude Skills Collection**) представляет собой библиотеку готовых навыков (`.skill`-пакетов) для Claude, сопроводительных каталогов, руководств по установке и разработке собственных skills, а также методологии и утилит для переноса рабочего контекста между чат-сессиями (`Chat Migration Assistant`, `Checkpoint Creator PRO`).

Тематика охватывает файловые и текстовые операции, форматирование, конвертацию форматов, офисную автоматизацию (PDF, Excel, PowerPoint, email), программирование, обработку данных и DevOps/CI-CD.

## Архитектура и основные компоненты

### 1. Коллекция навыков (`skills/`)

Согласно [`skills/README.md`](skills/README.md), организованное дерево содержит **101** `.skill`-файл, распределённый по 6 категориям:

- **`skills/level-1-basic/`** (22 навыка) — повседневные операции: файловые утилиты (`smart-file-organizer.skill`, `batch-file-renamer.skill`, `duplicate-hunter.skill`, `archive-manager.skill`, `smart-backup-assistant.skill`), работа с текстом, форматирование и базовые конвертеры.
- **`skills/level-2-intermediate/`** (11 навыков) — работа с документами, презентациями, шаблонами и email (`pdf-master.skill`, `excel-automation-expert.skill`, `powerpoint-designer.skill`, `smart-email-drafts.skill` и др.).
- **`skills/level-3-advanced/`** (12 навыков) — разработка, Git-процессы, скрапинг, API и работа с данными (`test-generator.skill`, `git-workflow-assistant.skill`, `web-scraper-pro.skill`, `api-integration-helper.skill`, `database-query-builder.skill` и др.).
- **`skills/level-4-professional/`** (12 навыков) — DevOps, CI/CD и администрирование (`docker-helper.skill`, `kubernetes-assistant.skill`, `infrastructure-as-code.skill`, `cicd-pipeline-builder.skill`, `log-analyzer.skill`, `security-scanner.skill`, `system-monitor.skill` и др.).
- **`skills/special/`** (15 навыков) — линейка навыков миграции контекста между чатами (`chat-migration-assistant.skill`, `chat-migration-pro.skill`, `chat-migration-ultimate*.skill`, `v3.6`–`v6.0` `Quantum`/`Bridge`/`Cosmic`/`Infinity`), а также инструменты создания и массовой установки skills (`skill-creator-assistant*.skill`, `skill-batch-installer.skill`).
- **`skills/other/`** (29 навыков) — дополнительные утилиты (AutoML/ML, ETL, хеширование, соответствие требованиям, управление задачами и мультимедиа).

Каждый `.skill`-файл представляет собой ZIP-архив со стандартной структурой (`SKILL.md`, `examples/`, `assets/`, `references/`).

### 2. Скрипты и утилиты (`scripts/` и `checkpoint_creator.py`)

- **[`checkpoint_creator.py`](checkpoint_creator.py)** (также в [`scripts/checkpoint_creator.py`](scripts/checkpoint_creator.py)) — **Checkpoint Creator PRO v2.0**, CLI-утилита на Python 3 (без внешних зависимостей), автоматизирующая подготовку чекпоинт-пакета для переноса прогресса между чатами:
  - поддерживает 6 типов проектов (`documentation`, `development`, `analysis`, `design`, `research`, `legal`) со специализированными шаблонами;
  - генерирует `MASTER_INDEX.md`, `METHODOLOGY.md`, `CHECKPOINT_XX.md`, `README_QUICK_START.md`, `FIRST_MESSAGE.txt` и профильные шаблоны;
  - поддерживает флаги `--validate` (проверка обязательных файлов) и `--git-auto` (автоматический `git add`, `git commit` и тег `chat-N-complete`).
- **[`scripts/organize_skills.sh`](scripts/organize_skills.sh)** — Bash-скрипт для раскладывания корневых `.skill`-файлов по подкаталогам `skills/` (через `cp`, без удаления исходников).
- **[`scripts/organize_docs.sh`](scripts/organize_docs.sh)** — Bash-скрипт для раскладывания документации по языкам и категориям в `docs/` (`en/`, `en/guides/`, `ru/`, `checkpoints/`, `versions/`) и копирования `checkpoint_creator.py` в `scripts/`.

### 3. База документации (`docs/` и корневые `.md`)

Согласно [`docs/README.md`](docs/README.md), документация включает 80+ файлов:
- **`docs/en/`** (и `docs/en/guides/`) — мастер-индекс (`00_MASTER_INDEX_Skills_Catalog.md` с учётом 87+ навыков по 4 уровням и 16 категориям), детальные каталоги (`claude-skills-detailed-catalog*.md`), руководства по установке (`SKILLS_INSTALLATION_GUIDE.md`, `ONE_BUTTON_INSTALL_GUIDE.md`, `DOWNLOAD_GUIDE_Complete.md`), стандарты описания (`METHODOLOGY_Skill_Description_Standard.md`), стратегия контекста и миграции (`CONTEXT_STRATEGY_AND_MIGRATION_GUIDE.md`), `ROADMAP.md`, `CHANGELOG.md`, отчёты по батчам.
- **`docs/ru/`** — русскоязычные руководства (`КАК_СОЗДАТЬ_СВОЙ_SKILL_ПОЛНОЕ_РУКОВОДСТВО.md`, `QUICK_REFERENCE_СОЗДАНИЕ_SKILLS.md`, `КАТАЛОГ_89_SKILLS.md`), сравнения версий (`v1`–`v6`) и итоговые сводки.
- **`docs/checkpoints/` и `docs/versions/`** — история развития проекта и чекпоинты поколений `v1.0`–`v6.0`.

### 4. Релизные архивы (`releases/`)

Готовые пакеты для скачивания, включая `MEGA_ARCHIVE_102_SKILLS_COMPLETE.zip`, `all-88-claude-skills.zip`, `ALL_SKILLS_COMPLETE_v1_to_v6_PLUS_4_New.zip`, `ALL_CHECKPOINTS_v1_to_v6_COMPLETE.zip`, `EVOLUTION_COMPLETE_PACKAGE.zip`, `ULTIMATE_COMPLETE_PACKAGE.zip` и пакеты отдельных версий миграции.

## Стек технологий и структура каталогов

- **Языки и инструменты:** Python 3 (стандартная библиотека: `argparse`, `json`, `os`, `datetime`, `pathlib`), Bash (`scripts/*.sh`), Markdown, ZIP-архивы (`.skill`, `.zip`).
- **Внешние пакеты и сборка:** не требуются (`requirements.txt` и `package.json` отсутствуют).

Структура ветки `main`:

```text
info4/
├── checkpoint_creator.py             # CLI-генератор checkpoint-пакетов (Python 3)
├── 00_MASTER_INDEX_Skills_Catalog.md # Главный индекс навыков
├── SKILLS_INSTALLATION_GUIDE.md      # Инструкция по установке skills
├── README.md                         # Обзор репозитория
├── LICENSE                           # Текст лицензии GNU AGPLv3
├── skills/                           # 101 .skill-файл по 6 уровням/категориям
│   ├── level-1-basic/                # 22 базовых навыка
│   ├── level-2-intermediate/         # 11 навыков среднего уровня
│   ├── level-3-advanced/             # 12 продвинутых навыков
│   ├── level-4-professional/         # 12 профессиональных DevOps-навыков
│   ├── special/                      # 15 специальных навыков (миграция и создание skills)
│   └── other/                        # 29 дополнительных утилит
├── docs/                             # Структурированная документация (80+ файлов)
│   ├── en/                           # Англоязычные каталоги, методология и guides/
│   ├── ru/                           # Русскоязычные руководства и обзоры версий
│   ├── checkpoints/                  # Чекпоинты поколений v2.0–v6.0
│   └── versions/                     # Исторические версии индексов
├── scripts/                          # Утилиты организации и генерации чекпоинтов
│   ├── checkpoint_creator.py
│   ├── organize_docs.sh
│   └── organize_skills.sh
├── releases/                         # Архивные сборки пакетов (.zip)
├── _archive/                         # Архивные материалы
└── *.skill / *.zip / *.md            # Корневые исходные файлы, сохранённые при реорганизации
```

### Пример запуска `checkpoint_creator.py`

```bash
python checkpoint_creator.py --project-name "My Project" \
                             --chat-number 1 \
                             --project-type documentation \
                             --items-total 20 \
                             --items-complete 5 \
                             --output-dir ./checkpoint \
                             --validate
```

## Ветки и статус разработки

- **`main`** — основная ветка с реорганизованной структурой (`skills/`, `docs/`, `scripts/`, `releases/`, `_archive/`), исходными файлами в корне и актуальной лицензией `LICENSE`.
- **`claude/review-repository-7aBtE`** — ветка с результатами аудита репозитория (содержит также `REPOSITORY_REVIEW.md`, `PR_DESCRIPTION.md`, `README_NEW.md`, `CONTRIBUTING.md`).
- **`svend4-patch-1`** — ветка с частичной выборкой `.skill`-пакетов, `MEGA_ARCHIVE_102_SKILLS_COMPLETE.zip` и русскоязычных справочников.
- **`svend4-patch-2`** — ветка с расширенным корневым набором файлов (до или параллельно реорганизации в `main`).
- **Открытые Pull Requests:** отсутствуют.

## Лицензия

В ветке `main` проект распространяется под лицензией **GNU Affero General Public License v3.0 (AGPL-3.0)** — см. файл [`LICENSE`](LICENSE). (В ветках `claude/review-repository-7aBtE` и `svend4-patch-2` сохранён более ранний файл `LICENSE` размером 1 075 байт.)
