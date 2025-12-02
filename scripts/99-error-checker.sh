#!/bin/bash
# scripts/99-error-checker.sh - 项目错误检查和修复脚本

set -e

echo "🔍 开始检查项目错误..."

# 检查所有脚本的语法
echo "📝 检查脚本语法..."
for script in scripts/*.sh; do
    if [[ -f "$script" ]]; then
        echo "  检查 $script..."
        bash -n "$script" || echo "    ❌ 语法错误: $script"
    fi
done

# 检查Python脚本的语法
echo "🐍 检查Python脚本语法..."
for py_script in tools/*.py; do
    if [[ -f "$py_script" ]]; then
        echo "  检查 $py_script..."
        python -m py_compile "$py_script" || echo "    ❌ 语法错误: $py_script"
    fi
done

# 检查配置文件的格式
echo "⚙️  检查配置文件格式..."
for config in config/*.json; do
    if [[ -f "$config" ]]; then
        echo "  检查 $config..."
        python -m json.tool "$config" > /dev/null || echo "    ❌ JSON格式错误: $config"
    fi
done

# 检查必要的目录结构
echo "📁 检查项目目录结构..."
NEEDED_DIRS=("scripts" "tools" "config" "prompts" "projects" "docs")
for dir in "${NEEDED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "  ⚠️  目录不存在，创建: $dir"
        mkdir -p "$dir"
    else
        echo "  ✅ 目录存在: $dir"
    fi
done

# 检查必要文件
echo "📄 检查必要文件..."
NEEDED_FILES=(
    "scripts/01-init-project.sh"
    "scripts/02-create-outline.sh"
    "scripts/03-batch-create.sh"
    "scripts/11-unified-workflow.sh"
    "scripts/20-sandbox-creation.sh"
    "scripts/21-combined-revision.sh"
    "scripts/25-chapter-by-chapter-analyzer.sh"
    "tools/diagnostic.js"
    "tools/token-manager.js"
    "tools/memory-enhancer.js"
    "tools/quality-analyzer.js"
    "config/qwen-settings.json"
)

for file in "${NEEDED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "  ❌ 文件不存在: $file"
    else
        echo "  ✅ 文件存在: $file"
    fi
done

# 检查脚本权限
echo "🔒 检查脚本执行权限..."
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x tools/*.py 2>/dev/null || true

# 检查Qwen CLI可用性
echo "🤖 检查Qwen CLI可用性..."
if command -v qwen &> /dev/null; then
    echo "  ✅ Qwen CLI可用"
else
    echo "  ❌ Qwen CLI不可用，请先安装"
fi

# 检查Node.js可用性
echo "🟢 检查Node.js可用性..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "  ✅ Node.js可用: $NODE_VERSION"

    # 检查版本是否满足要求
    MAJOR_VERSION=$(echo $NODE_VERSION | sed 's/v//' | cut -d. -f1)
    if [ "$MAJOR_VERSION" -ge 20 ]; then
        echo "  ✅ Node.js版本满足要求"
    else
        echo "  ❌ Node.js版本过低，需要≥20.0"
    fi
else
    echo "  ❌ Node.js不可用，请先安装"
fi

# 检查依赖安装
echo "📦 检查依赖安装..."
if [ -f "package.json" ] && [ -f "package-lock.json" ]; then
    echo "  📁 package.json和package-lock.json存在"
else
    echo "  ⚠️  package.json或package-lock.json不存在"
fi

# 检查项目完整性
echo "📋 检查项目完整性..."
if [ -f "README.md" ] && [ -f "LICENSE" ] && [ -f "INSTALL.md" ]; then
    echo "  ✅ 核心文档存在"
else
    echo "  ⚠️  缺少核心文档"
fi

echo "✅ 错误检查完成"