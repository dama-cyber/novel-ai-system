#!/bin/bash
# scripts/05-compress-session.sh - 会话压缩

set -e

PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
    echo "用法: $0 <项目目录>"
    echo "例如: $0 \"./projects/我的玄幻小说\""
    exit 1
fi

echo "🔧 开始压缩会话历史..."

# 读取项目元数据
METADATA_FILE="$PROJECT_DIR/metadata.json"
if [ -f "$METADATA_FILE" ]; then
    CURRENT_CHAPTER=$(grep -o '"currentChapter":[^,]*' "$METADATA_FILE" | cut -d: -f2 | xargs)
    TOTAL_WORDS=$(grep -o '"totalWords":[^,]*' "$METADATA_FILE" | cut -d: -f2 | xargs)
    PROJECT_TITLE=$(grep -o '"title":[^,]*' "$METADATA_FILE" | cut -d: -f2 | sed 's/^[[:space:]]*"//' | sed 's/"[[:space:]]*,$//')
else
    echo "⚠️  未找到项目元数据文件，跳过压缩"
    exit 0
fi

# 创建总结引擎JS工具的路径
SUMMARY_ENGINE_PATH="./scripts/utils/summary-engine.js"

if [ ! -f "$SUMMARY_ENGINE_PATH" ]; then
    echo "⚠️  未找到总结引擎工具，运行基础压缩"
    qwen /compress
    exit 0
fi

# 使用Node.js工具来分析并生成摘要
node "$SUMMARY_ENGINE_PATH" "$PROJECT_DIR" "$CURRENT_CHAPTER"

echo "✅ 会话压缩完成！"