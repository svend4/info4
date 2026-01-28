#!/bin/bash
# Скрипт для организации документации по языкам
# Копирует файлы в структурированные папки docs/

echo "📚 Организация документации по языкам..."

# Английские документы
EN_DOCS=(
    "00_MASTER_INDEX_Skills_Catalog.md"
    "claude-skills-detailed-catalog.md"
    "claude-skills-detailed-catalog-part2.md"
    "claude-skills-catalog-12-18.md"
    "CHANGELOG.md"
    "ROADMAP.md"
    "METHODOLOGY_Skill_Description_Standard.md"
    "SKILLS_INSTALLATION_GUIDE.md"
    "DOWNLOAD_GUIDE_Complete.md"
    "DOWNLOAD_INSTRUCTIONS.md"
    "ONE_BUTTON_INSTALL_GUIDE.md"
    "CHAT_MIGRATION_ASSISTANT_README.md"
    "README_CHECKPOINT_FILES.md"
    "README_EVOLUTION_PACKAGE.md"
    "README_MEGA_ARCHIVE_102_SKILLS.md"
    "README_ALL_11_SKILLS.md"
    "SKILLS_OPTIMIZED.md"
    "SKILL.md"
    "4_SKILLS_READY.md"
    "VERSION_COMPARISON.md"
    "CONTEXT_STRATEGY_AND_MIGRATION_GUIDE.md"
    "STRATEGY_Context_Management_Complete.md"
    "EXECUTIVE_SUMMARY_v3.md"
    "EXECUTIVE_SUMMARY_Future.md"
    "RELEASE_NOTES_v3.5_ULTIMATE_PLUS.md"
)

# Русские документы
RU_DOCS=(
    "КАК_СОЗДАТЬ_СВОЙ_SKILL_ПОЛНОЕ_РУКОВОДСТВО.md"
    "КАТАЛОГ_89_SKILLS.md"
    "ПОЛНАЯ_ИНСТРУКЦИЯ_3_ВЕРСИИ.md"
    "ПРАКТИЧЕСКОЕ_РУКОВОДСТВО_СОЗДАНИЕ_В_ЧАТЕ.md"
    "ПРАКТИЧЕСКИЙ_ПЛАН_v3.5_v4.0.md"
    "QUICK_REFERENCE_СОЗДАНИЕ_SKILLS.md"
    "СРАВНЕНИЕ_ВЕРСИЙ_v1_vs_v2.md"
    "ВИЗУАЛЬНОЕ_СРАВНЕНИЕ_v1_v2_v3.md"
    "АНАЛИЗ_И_V3_ULTIMATE.md"
    "АНАЛИЗ_И_БУДУЩИЕ_ВЕРСИИ_v4_v5_v6.md"
    "СЕССИЯ_ЗАВЕРШЕНА_ULTIMATE_COLLECTION.md"
    "ФИНАЛ_v3.5_COMPLETE.md"
    "ФИНАЛ_ALL_6_VERSIONS_COMPLETE.md"
    "ФИНАЛЬНЫЙ_MASTER_SUMMARY.md"
)

# Checkpoint файлы
CHECKPOINTS=(
    "CHECKPOINT_01_Chat1_Summary.md"
    "CHECKPOINT_ANALYSIS.md"
    "COMPREHENSIVE_CHECKPOINT_Final.md"
    "v2.0_CHECKPOINT_AUTO.md"
    "v3.0_ENHANCED_CHECKPOINT.md"
    "v3.5_ULTIMATE_PLUS_CHECKPOINT.md"
    "v3.6_REFINED_CHECKPOINT.md"
    "v4.0_QUANTUM_CHECKPOINT.md"
    "v4.5_BRIDGE_CHECKPOINT.md"
    "v5.0_COSMIC_CHECKPOINT.md"
    "v6.0_INFINITY_CHECKPOINT.md"
)

# Batch/Chat файлы (английские)
BATCH_DOCS=(
    "BATCH_3_COMPLETE_33_SKILLS.md"
    "BATCH_4_COMPLETE_38_SKILLS.md"
    "BATCH_6_COMPLETE_48_SKILLS.md"
    "BATCH_7_COMPLETE_53_SKILLS.md"
    "BATCH_8_COMPLETE_58_SKILLS_TWO_THIRDS.md"
    "BATCH_9_COMPLETE_63_SKILLS_72_PERCENT.md"
    "BATCH_10_COMPLETE_68_SKILLS_78_PERCENT.md"
    "BATCH_12_COMPLETE_78_SKILLS_90_PERCENT.md"
    "CHAT_1_COMPLETE_18_SKILLS.md"
    "CHAT_2_COMPLETE_43_SKILLS_FINAL.md"
    "CHAT_2_PROGRESS_28_SKILLS.md"
    "CHAT_2_STRATEGY.md"
    "CHAT_3_STRATEGY.md"
    "PROJECT_COMPLETE_87_SKILLS_100_PERCENT.md"
    "MAJOR_UPDATE_14_SKILLS.md"
)

# Version files
VERSION_DOCS=(
    "v1.0_MASTER_INDEX.md"
)

# Копирование с созданием папок
copy_docs() {
    local target_dir=$1
    shift
    local docs=("$@")
    local count=0

    for doc in "${docs[@]}"; do
        if [ -f "$doc" ]; then
            cp "$doc" "$target_dir/"
            echo "  ✓ $doc"
            ((count++))
        fi
    done

    echo "  → Скопировано: $count файлов"
}

# Копируем английские документы
echo ""
echo "🇬🇧 Английская документация..."
copy_docs "docs/en" "${EN_DOCS[@]}"
copy_docs "docs/en/guides" "${BATCH_DOCS[@]}"

# Копируем русские документы
echo ""
echo "🇷🇺 Русская документация..."
copy_docs "docs/ru" "${RU_DOCS[@]}"

# Копируем checkpoints
echo ""
echo "✅ Checkpoint файлы..."
copy_docs "docs/checkpoints" "${CHECKPOINTS[@]}"

# Копируем версии
echo ""
echo "🔢 Version файлы..."
copy_docs "docs/versions" "${VERSION_DOCS[@]}"

# Переместим checkpoint_creator.py в scripts
if [ -f "checkpoint_creator.py" ]; then
    cp checkpoint_creator.py scripts/
    echo ""
    echo "🐍 Python скрипт..."
    echo "  ✓ checkpoint_creator.py → scripts/"
fi

echo ""
echo "✅ Организация документации завершена!"
echo ""
echo "Структура docs/:"
echo "  ├── en/          ($(ls -1 docs/en/*.md 2>/dev/null | wc -l) файлов)"
echo "  │   └── guides/  ($(ls -1 docs/en/guides/*.md 2>/dev/null | wc -l) файлов)"
echo "  ├── ru/          ($(ls -1 docs/ru/*.md 2>/dev/null | wc -l) файлов)"
echo "  ├── checkpoints/ ($(ls -1 docs/checkpoints/*.md 2>/dev/null | wc -l) файлов)"
echo "  └── versions/    ($(ls -1 docs/versions/*.md 2>/dev/null | wc -l) файлов)"
