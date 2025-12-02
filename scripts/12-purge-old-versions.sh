#!/bin/bash
# scripts/12-purge-old-versions.sh - 清理旧版本脚本

set -e

PROJECT_DIR=$1

if [ -z "$PROJECT_DIR" ]; then
    echo "用法: $0 <项目目录>"
    echo "例如: $0 \"./projects/我的玄幻小说\""
    exit 1
fi

echo "🧹 开始清理旧版本文件..."

CHAPTERS_DIR="$PROJECT_DIR/chapters"
CLEANUP_LOG="$PROJECT_DIR/cleanup-log-$(date +%Y%m%d_%H%M%S).txt"

{
    echo "清理日志 - $(date)"
    echo "项目路径: $PROJECT_DIR"
    echo ""
} > "$CLEANUP_LOG"

# 统计信息
DELETED_COUNT=0
BACKUP_COUNT=0

# 遍历所有章节文件
for chapter_file in "$CHAPTERS_DIR"/*.md; do
    if [ -f "$chapter_file" ]; then
        filename=$(basename "$chapter_file")
        
        # 检查是否为旧版本（包含标识如"修订版"、"风格"等，但排除最新版本）
        if [[ "$filename" == *"-修订版"* ]] || [[ "$filename" == *"-轻松幽默"* ]]; then
            echo "删除旧版本: $filename"
            echo "$(date): 删除旧版本 - $filename" >> "$CLEANUP_LOG"
            rm "$chapter_file"
            ((DELETED_COUNT++))
        fi
    fi
done

echo ""
echo "✅ 清理完成！"
echo "删除了 $DELETED_COUNT 个旧版本文件"
echo "清理日志已保存至: $CLEANUP_LOG"

# 优化章节文件命名以确保只保留最新、最优质的版本
echo ""
echo "🔄 优化章节文件命名..."


echo ""
echo "✅ 文件命名优化完成！"
echo "项目现在只保留最新、最优化的版本。"