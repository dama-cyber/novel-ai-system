#!/bin/bash
# scripts/09-full-workflow.sh - 完整工作流自动化脚本
# 在Qwen Coder CLI中运行，自动执行整个小说创作流程

set -e

PROJECT_NAME=$1
CHAPTER_COUNT=$2
GENRE=$3

if [ -z "$PROJECT_NAME" ] || [ -z "$CHAPTER_COUNT" ]; then
    echo "用法: $0 <项目名称> <章节数> [类型]"
    echo "例如: $0 \"我的玄幻小说\" 100 \"玄幻\""
    exit 1
fi

if [ -z "$GENRE" ]; then
    GENRE="小说"
fi

echo "🚀 开始完整小说创作工作流..."

# 步骤1: 初始化项目
echo "📝 步骤1: 初始化项目..."
./scripts/01-init-project.sh "$PROJECT_NAME" "$CHAPTER_COUNT"

# 步骤2: 生成大纲
echo "📋 步骤2: 生成大纲..."
echo "请输入小说的基本信息："
echo -n "主角: "
read PROTAGONIST
echo -n "主要冲突: "
read CONFLICT

# 创建大纲提示
cat > /tmp/outline_prompt.txt << EOF
请为$GENRE小说《$PROJECT_NAME》生成一个详细大纲。

主角: $PROTAGONIST
主要冲突: $CONFLICT
章节数: $CHAPTER_COUNT

要求：
- 每章有一个吸引人的标题
- 每章有简短的情节概要
- 确保情节连贯，伏笔和回收合理
- 控制在$CHAPTER_COUNT章完成主要故事线

现在生成大纲：
EOF

# 调用Qwen生成大纲
cat /tmp/outline_prompt.txt | qwen > "./projects/$PROJECT_NAME/outline.md"

# 步骤3: 批量创作章节 (分批进行以避免令牌限制)
echo "✍️  步骤3: 批量创作章节..."
PROJECT_DIR="./projects/$PROJECT_NAME"

# 检查大纲是否生成
if [ ! -f "$PROJECT_DIR/outline.md" ]; then
    echo "❌ 大纲未生成，跳过章节创作"
    exit 1
fi

echo "开始分批创作章节..."

# 按每批10章进行创作
BATCH_SIZE=10
TOTAL_CHAPTERS=$CHAPTER_COUNT
CURRENT_CHAPTER=1

while [ $CURRENT_CHAPTER -le $TOTAL_CHAPTERS ]; do
    END_CHAPTER=$((CURRENT_CHAPTER + BATCH_SIZE - 1))
    if [ $END_CHAPTER -gt $TOTAL_CHAPTERS ]; then
        END_CHAPTER=$TOTAL_CHAPTERS
    fi
    
    echo "创作第$CURRENT_CHAPTER章到第$END_CHAPTER章..."
    ./scripts/03-batch-create.sh "$PROJECT_DIR" $CURRENT_CHAPTER $END_CHAPTER
    
    CURRENT_CHAPTER=$((END_CHAPTER + 1))
    
    # 每批完成后暂停一下，避免过于频繁的API调用
    if [ $CURRENT_CHAPTER -le $TOTAL_CHAPTERS ]; then
        echo "批次完成，暂停10秒..."
        sleep 10
    fi
done

# 步骤4: 质量检查
echo "🔍 步骤4: 进行质量检查..."
./scripts/04-quality-check.sh "$PROJECT_DIR"

# 步骤5: 生成总结
echo "📊 步骤5: 生成项目总结..."
SUMMARY_FILE="$PROJECT_DIR/summary.md"

cat > "$SUMMARY_FILE" << EOF
# 《$PROJECT_NAME》项目总结

## 项目信息
- 项目名称: $PROJECT_NAME
- 小说类型: $GENRE
- 章节数: $CHAPTER_COUNT
- 创建时间: $(date -Iseconds)

## 章节列表
EOF

# 添加章节列表到总结
for file in "$PROJECT_DIR/chapters/"*.md; do
    if [ -f "$file" ]; then
        CHAPTER_TITLE=$(basename "$file" | sed 's/chapter_[0-9]*_\(.*\)\.md/\1/')
        CHAPTER_NUM=$(basename "$file" | sed 's/chapter_\([0-9]*\).*/\1/')
        echo "- 第${CHAPTER_NUM}章: $CHAPTER_TITLE" >> "$SUMMARY_FILE"
    fi
done

echo "✅ 完整工作流完成！"
echo "📁 项目位置: $PROJECT_DIR"
echo "📋 总结文件: $SUMMARY_FILE"