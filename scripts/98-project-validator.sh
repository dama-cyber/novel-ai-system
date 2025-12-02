#!/bin/bash
# scripts/98-project-validator.sh - 项目完整性验证脚本

set -e

echo "🔍 开始验证项目完整性..."

ERRORS=0
WARNINGS=0

# 验证必要目录
echo "📁 验证必要目录..."
REQUIRED_DIRS=("scripts" "tools" "config" "prompts" "projects" "docs" "templates" "examples")

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ $dir/ - 缺失"
        ((ERRORS++))
    fi
done

echo ""

# 验证核心脚本
echo "📜 验证核心脚本..."
CORE_SCRIPTS=(
    "scripts/01-init-project.sh"
    "scripts/02-create-outline.sh"
    "scripts/03-batch-create.sh"
    "scripts/04-quality-check.sh"
    "scripts/11-unified-workflow.sh"
    "scripts/20-sandbox-creation.sh"
    "scripts/21-combined-revision.sh"
    "scripts/25-chapter-by-chapter-analyzer.sh"
    "scripts/98-project-validator.sh"
    "scripts/99-error-checker.sh"
)

for script in "${CORE_SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "  ✅ $script"
    else
        echo "  ❌ $script - 缺失"
        ((ERRORS++))
    fi
done

echo ""

# 验证核心工具
echo "🛠️  验证核心工具..."
CORE_TOOLS=(
    "tools/diagnostic.js"
    "tools/token-manager.js"
    "tools/memory-enhancer.js"
    "tools/quality-analyzer.js"
    "tools/validation-checker.js"
)

for tool in "${CORE_TOOLS[@]}"; do
    if [ -f "$tool" ]; then
        echo "  ✅ $tool"
    else
        echo "  ❌ $tool - 缺失"
        ((ERRORS++))
    fi
done

echo ""

# 验证配置文件
echo "⚙️  验证配置文件..."
CONFIG_FILES=(
    "config/qwen-settings.json"
    "config/novel-template.json"
    "config/prompt-library.json"
)

for config in "${CONFIG_FILES[@]}"; do
    if [ -f "$config" ]; then
        echo "  ✅ $config"
    else
        echo "  ❌ $config - 缺失"
        ((ERRORS++))
    fi
done

echo ""

# 验证文档文件
echo "📄 验证文档文件..."
DOC_FILES=(
    "README.md"
    "INSTALL.md"
    "LICENSE"
    "QUICK_START.md"
    "QUICK_GUIDE.md"
)

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ]; then
        echo "  ✅ $doc"
    else
        echo "  ⚠️  $doc - 缺失"
        ((WARNINGS++))
    fi
done

echo ""

# 检查package文件
echo "📦 验证包文件..."
PKG_FILES=(
    "package.json"
    "package-lock.json"
)

for file in "${PKG_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ⚠️  $file - 缺失"
        ((WARNINGS++))
    fi
done

echo ""

# 验证prompts目录结构
echo "💬 验证prompts目录结构..."
PROMPT_DIRS=(
    "prompts/outline"
    "prompts/chapter"
    "prompts/character"
    "prompts/worldview"
)

for prompt_dir in "${PROMPT_DIRS[@]}"; do
    if [ -d "$prompt_dir" ]; then
        echo "  ✅ $prompt_dir/"
    else
        echo "  ⚠️  $prompt_dir/ - 缺失"
        ((WARNINGS++))
    fi
done

echo ""

# 汇总结果
echo "📊 验证结果汇总:"
echo "- 错误数量: $ERRORS"
echo "- 警告数量: $WARNINGS"

if [ $ERRORS -eq 0 ]; then
    echo ""
    echo "🎉 系统完整性验证通过！"
    echo "所有核心组件均已找到，系统可以正常运行。"
else
    echo ""
    echo "❌ 系统完整性验证失败！发现 $ERRORS 个错误。"
    echo "请检查上述缺失的文件或目录。"
fi

if [ $WARNINGS -gt 0 ]; then
    echo ""
    echo "⚠️  发现 $WARNINGS 个警告。"
    echo "虽然系统可以运行，但建议修复这些警告以获得完整功能。"
fi

if [ $ERRORS -eq 0 ]; then
    exit 0
else
    exit 1
fi