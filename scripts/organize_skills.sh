#!/bin/bash
# Скрипт для организации .skill файлов по уровням
# Копирует файлы (НЕ перемещает) в структурированные папки

echo "🚀 Организация Claude Skills по уровням..."

# Level 1 - Basic (Файловые операции, текст, форматирование, конвертации)
LEVEL1=(
    "smart-file-organizer.skill"
    "batch-file-renamer.skill"
    "duplicate-hunter.skill"
    "archive-manager.skill"
    "smart-backup-assistant.skill"
    "universal-text-transformer.skill"
    "smart-clipboard-manager.skill"
    "text-expander-pro.skill"
    "find-replace-wizard.skill"
    "text-extraction-engine.skill"
    "markdown-formatter.skill"
    "table-beautifier.skill"
    "code-formatter-universal.skill"
    "json-yaml-xml-converter.skill"
    "clean-paste.skill"
    "unit-converter-pro.skill"
    "unit-converter.skill"
    "date-time-wizard.skill"
    "date-calculator.skill"
    "time-zone-converter.skill"
    "image-format-converter.skill"
    "currency-converter.skill"
)

# Level 2 - Intermediate (Документы, презентации, email, шаблоны)
LEVEL2=(
    "pdf-master.skill"
    "excel-automation-expert.skill"
    "data-entry-automator.skill"
    "smart-email-drafts.skill"
    "email-sorter-filter.skill"
    "email-template-manager.skill"
    "email-template-builder.skill"
    "meeting-scheduler-pro.skill"
    "calendar-meeting-assistant.skill"
    "powerpoint-designer.skill"
    "documentation-generator.skill"
)

# Level 3 - Advanced (Программирование, дизайн, data, API)
LEVEL3=(
    "test-generator.skill"
    "git-workflow-assistant.skill"
    "color-palette-generator.skill"
    "image-optimizer.skill"
    "csv-power-tools.skill"
    "data-merger.skill"
    "data-validator-pro.skill"
    "database-query-builder.skill"
    "dataset-analyzer.skill"
    "web-scraper-pro.skill"
    "api-integration-helper.skill"
    "api-tester.skill"
)

# Level 4 - Professional (CI/CD, DevOps, Enterprise)
LEVEL4=(
    "cicd-pipeline-builder.skill"
    "docker-helper.skill"
    "kubernetes-assistant.skill"
    "infrastructure-as-code.skill"
    "log-analyzer.skill"
    "log-aggregator.skill"
    "system-monitor.skill"
    "performance-analyzer.skill"
    "security-scanner.skill"
    "health-check-system.skill"
    "environment-manager.skill"
    "load-tester.skill"
)

# Специальные skills (миграция, создание, управление)
SPECIAL=(
    "chat-migration-assistant.skill"
    "chat-migration-pro.skill"
    "chat-migration-ultimate.skill"
    "chat-migration-ultimate-plus.skill"
    "chat-migration-quantum-v4.skill"
    "chat-migration-refined-v36-compact.skill"
    "chat-migration-refined-v36-extended.skill"
    "chat-migration-bridge-v45-compact.skill"
    "chat-migration-bridge-v45-extended.skill"
    "chat-migration-cosmic-v5.skill"
    "chat-migration-infinity-v6.skill"
    "skill-creator-assistant.skill"
    "skill-creator-assistant-compact.skill"
    "skill-creator-assistant-extended.skill"
    "skill-batch-installer.skill"
)

# Остальные skills
OTHER=(
    "access-control-manager.skill"
    "alert-manager.skill"
    "automl-assistant.skill"
    "barcode-scanner.skill"
    "code-coverage-analyzer.skill"
    "compliance-checker.skill"
    "etl-pipeline-designer.skill"
    "feature-engineering-assistant.skill"
    "file-format-converter.skill"
    "hash-calculator.skill"
    "media-library-manager.skill"
    "meeting-notes-assistant.skill"
    "message-formatter.skill"
    "ml-model-manager.skill"
    "model-evaluator.skill"
    "notification-center.skill"
    "password-manager.skill"
    "qr-code-generator.skill"
    "report-generator-pro.skill"
    "resource-allocator.skill"
    "screenshot-automator.skill"
    "sprint-planner.skill"
    "task-manager-pro.skill"
    "team-communication-helper.skill"
    "timeline-generator.skill"
    "uuid-generator.skill"
    "video-processor.skill"
    "workflow-automation.skill"
    "audio-toolkit.skill"
)

# Функция копирования
copy_skills() {
    local level=$1
    shift
    local skills=("$@")
    local count=0

    for skill in "${skills[@]}"; do
        if [ -f "$skill" ]; then
            cp "$skill" "skills/$level/"
            echo "  ✓ $skill → skills/$level/"
            ((count++))
        fi
    done

    echo "  Скопировано: $count файлов"
}

# Копируем по уровням
echo ""
echo "📁 Level 1 - Basic..."
copy_skills "level-1-basic" "${LEVEL1[@]}"

echo ""
echo "📁 Level 2 - Intermediate..."
copy_skills "level-2-intermediate" "${LEVEL2[@]}"

echo ""
echo "📁 Level 3 - Advanced..."
copy_skills "level-3-advanced" "${LEVEL3[@]}"

echo ""
echo "📁 Level 4 - Professional..."
copy_skills "level-4-professional" "${LEVEL4[@]}"

# Создаем папку для специальных skills
mkdir -p skills/special
echo ""
echo "📁 Special Skills (миграция, управление)..."
copy_skills "special" "${SPECIAL[@]}"

# Создаем папку для остальных
mkdir -p skills/other
echo ""
echo "📁 Other Skills..."
copy_skills "other" "${OTHER[@]}"

echo ""
echo "✅ Организация завершена!"
echo ""
echo "Структура:"
echo "skills/"
echo "  ├── level-1-basic/         ($(ls -1 skills/level-1-basic/ 2>/dev/null | wc -l) файлов)"
echo "  ├── level-2-intermediate/  ($(ls -1 skills/level-2-intermediate/ 2>/dev/null | wc -l) файлов)"
echo "  ├── level-3-advanced/      ($(ls -1 skills/level-3-advanced/ 2>/dev/null | wc -l) файлов)"
echo "  ├── level-4-professional/  ($(ls -1 skills/level-4-professional/ 2>/dev/null | wc -l) файлов)"
echo "  ├── special/               ($(ls -1 skills/special/ 2>/dev/null | wc -l) файлов)"
echo "  └── other/                 ($(ls -1 skills/other/ 2>/dev/null | wc -l) файлов)"
